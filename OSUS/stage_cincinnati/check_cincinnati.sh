#!/bin/bash

# function send_slack() {
# 	local url token="$1" channel="$2" message="$3"
# 	url="https://jenkins-csb-openshift-qe-mastern.dno.corp.redhat.com/job/any-test-jobs-go-there/job/jianl_slack_demo/buildWithParameters"

# 	curl -k --get \
# 		--data-urlencode "token=${token}" \
# 		--data-urlencode "channel=${channel}" \
# 		--data-urlencode "message=${message}" \
# 		"${url}"
# }

version="4.16.1"
digest_channel="fast-4.16"
if command -v ./oc >/dev/null 2>&1
then
	alias OC=./oc
else
	alias OC=oc
fi
digest=$(OC image info quay.io/openshift-release-dev/ocp-release:${version}-x86_64 -ojson | jq -r ".digest")
echo "Expected digest is: ${digest}"

host="https://api.stage.openshift.com"

digest_retry=0
graph_retry=0
invalid_graph_retry=0
while sleep 10; 
do 
	echo "=================check if Cincinnati can get correct digest================="
	url="${host}/api/upgrades_info/v1/graph?arch=amd64&channel=${digest_channel}"
	echo "Cincinnati URL: ${url}"
	PAYLOAD="$(curl -skH 'Accept:application/json' "${url}" | jq -r '.nodes[] | select(.version == "'${version}'").payload')"; 
	
	DATE="$(date --iso=s --utc)"; 
	if [[ "${PAYLOAD}" =~ ${digest} ]]; then
		# file_name=$(date '+%Y-%m-%d')
		echo "${DATE}" "${PAYLOAD}"
		# send_slack "osus" "jianl_demo" "${DATE} - ${PAYLOAD}"
		digest_retry=0
	else
		echo "${DATE}" "Error: digest in payload is confusing: ${PAYLOAD}"
		# send_slack "osus" "jianl_demo" "${DATE} Error: PAYLOAD: ${PAYLOAD}"
		((digest_retry += 1))

		if [[ $digest_retry -gt 2 ]]; then
			return 1
		fi
	fi

	echo -e "\n\n"
	echo "=================check if graph API can get corrent data================="
	url="${host}/api/upgrades_info/v1/graph?"
	for accept in "application/json" application/vnd.redhat.cincinnati.v1+json 
	do
		echo "------------------Accept is ${accept}------------------"
		echo "1. Get data from a valid URL"
		test_url="${url}arch=amd64&channel=fast-4.16&version=4.16.1"
		echo "Valid url: ${test_url}"
		graph="$(curl -skH "Accept: ${accept}" "${test_url}")"
		nodes="$(echo "${graph}" | jq -r ".nodes[0].version")"
		edges="$(echo "${graph}" | jq -r ".edges[0]")"
		conditionalEdges="$(echo "${graph}" | jq -r ".conditionalEdges[0]")"
		
		DATE="$(date --iso=s --utc)"
		if [[ -n "${nodes}" ]] && [[ -n "${edges}" ]]; then
			echo "${DATE}" "get graph data with ${accept} passed"
			graph_retry=0
		else
			echo "${DATE}" "Error: failed to get graph data with ${accept}"
			echo "${nodes}"
			echo "${edges}"
			echo "${conditionalEdges}"
			((graph_retry += 1))

			if [[ $graph_retry -gt 2 ]]; then
				return 1
			fi
		fi
		
		echo -e "\n"
		echo "2. Get data from an invalid URL"
		for param in "channel=stable-a" "arch=amd64&channel=stable-a" "arch=amd64&channel=stable-a&id=ceb3b0bb-c689-4db9-bb6a-0122237e33fd" "arch=amd64&channel=stable-a&version=4.999.999"
		do
			test_url="${url}${param}"
			echo "invalid URL: ${test_url}"
			graph="$(curl -skH "Accept: ${accept}" "${test_url}")"
			nodes="$(echo "${graph}" | jq -r ".nodes[0]")"
			edges="$(echo "${graph}" | jq -r ".edges[0]")"
			conditionalEdges="$(echo "${graph}" | jq -r ".conditionalEdges[0]")"

			if [[ "${nodes}" != "[]" ]] || [[ "${edges}" != "[]" ]] || [[ "${conditionalEdges}" != "[]" ]]; then
				echo "${DATE}" "get graph data with invalid url passed"
				invalid_graph_retry=0
			else
				echo "${DATE}" "Error: failed to get graph data with invalid url"
				echo -e "Get graph data: \n ${graph}"
				((invalid_graph_retry += 1))

				if [[ $invalid_graph_retry -gt 2 ]]; then
					return 1
				fi
			fi
		done
	done
	
	echo -e "\n"
	echo "=================check openapi================="
	openapi="https://api.stage.openshift.com/api/upgrades_info/openapi"
	for accept in "application/json" application/vnd.redhat.cincinnati.v1+json 
	do
		openapi="https://api.stage.openshift.com/api/upgrades_info/openapi"
		param=$(curl -sH "Accept: ${accept}" "${openapi}" | jq '.paths."/api/upgrades_info/graph".parameters')
		openapi_id=$(echo "$param" | jq -r ".[] | select(.name==\"id\")")
		if [[ -z "${openapi_id}" ]] ; then
			echo "${DATE}" "Error: failed to get parameter id from openapi"
			echo -e "Get graph data: \n ${param}"
			return 1
		fi
		openapi_channel=$(echo "$param" | jq -r ".[] | select(.name==\"channel\")")
		if [[ -z "${openapi_channel}" ]] ; then
			echo "${DATE}" "Error: failed to get parameter channel from openapi"
			echo -e "Get graph data: \n ${param}"
			return 1
		fi
		openapi_arch=$(echo "$param" | jq -r ".[] | select(.name==\"arch\")")
		if [[ -z "${openapi_arch}" ]] ; then
			echo "${DATE}" "Error: failed to get parameter arch from openapi"
			echo -e "Get graph data: \n ${param}"
			return 1
		fi
		openapi_version=$(echo "$param" | jq -r ".[] | select(.name==\"version\")")
		if [[ -z "${openapi_version}" ]] ; then
			echo "${DATE}" "Error: failed to get parameter version from openapi"
			echo -e "Get graph data: \n ${param}"
			return 1
		fi
		echo "${DATE}" "Check openapi with ${accept} passed"
	done

	echo -e "\n\n"
done
