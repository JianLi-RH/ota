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
channel="fast-4.16"
digest=$(./oc image info quay.io/openshift-release-dev/ocp-release:${version}-x86_64 -ojson | jq -r ".digest")
echo "Expected digest is: ${digest}"

url="https://api.stage.openshift.com/api/upgrades_info/v1/graph?arch=amd64&channel=${channel}"
echo "Cincinnati URL: ${url}"
retry=0
while sleep 30; 
do 
	PAYLOAD="$(curl -skH 'Accept:application/json' "${url}" | jq -r '.nodes[] | select(.version == "'${version}'").payload')"; 
	if [[ "${PAYLOAD}" =~ ${digest} ]]; then
		DATE="$(date --iso=s --utc)"; 
		# file_name=$(date '+%Y-%m-%d')
		echo "${DATE}" "${PAYLOAD}"
		# send_slack "osus" "jianl_demo" "${DATE} - ${PAYLOAD}"
		retry=0
	else
		echo "${DATE}" "Error: PAYLOAD: ${PAYLOAD}"
		# send_slack "osus" "jianl_demo" "${DATE} Error: PAYLOAD: ${PAYLOAD}"
		((retry += 1))

		if [[ $retry -gt 2 ]]; then
			return 1
		fi
	fi
done

