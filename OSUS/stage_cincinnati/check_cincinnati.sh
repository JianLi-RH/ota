#!/bin/bash

function send_slack() {
	local message="$1"
	# slack-url is coming from secret slack-workflow
	curl -X POST "${slack-url}" -d '{"msg": "'"${message}"'"}'
}

host="https://api.stage.openshift.com"
graph_retry=0
invalid_graph_retry=0
while sleep 10; 
do 
	echo "=================check if graph API can get corrent data================="
	if [[ $graph_retry -lt 2 ]]; then
		for url in "${host}/api/upgrades_info/graph?" "${host}/api/upgrades_info/v1/graph?"
		do
			for accept in "application/json" "application/vnd.redhat.cincinnati.v1+json"
			do
				echo "------------------Accept is ${accept}------------------"
				echo "1. Get data from a valid URL"
				test_url="${url}arch=amd64&channel=fast-4.16&version=4.16.1"
				echo "Valid url: ${test_url}"
				graph="$(curl -skH "Accept: ${accept}" "${test_url}")"
				version="$(echo "${graph}" | jq -r ".version")"
				nodes="$(echo "${graph}" | jq -r ".nodes[0].version")"
				edges="$(echo "${graph}" | jq -r ".edges[0]")"
				conditionalEdges="$(echo "${graph}" | jq -r ".conditionalEdges[0]")"
				
				DATE="$(date --iso=s --utc)"
				if [[ "${version}" == "1" ]] && [[ -n "${nodes}" ]] && [[ -n "${edges}" ]] && [[ -n "${conditionalEdges}" ]]; then
					echo "${DATE}" "get graph data with ${accept} passed"
					graph_retry=0
				else
					echo "${DATE} Error: failed to get graph data with ${accept}"
					echo -e "version: \n ${version}"
					echo -e "nodes: \n ${nodes}"
					echo -e "edges: \n ${edges}"
					echo -e "conditionalEdges: \n ${conditionalEdges}"
					((graph_retry += 1))
				fi
			done
		done
	fi
	if [[ $graph_retry -eq 2 ]]; then
		DATE="$(date --iso=s --utc)"; 
		send_slack "${DATE} Error: failed to get graph data"
		break
	fi
	

	echo -e "\n\n"
	echo "=================check if graph API can get corrent data with invalid parameters================="
	if [[ $invalid_graph_retry -lt 2 ]]; then
		for url in "${host}/api/upgrades_info/graph?" "${host}/api/upgrades_info/v1/graph?"
		do
			echo "------------------Accept is ${accept}------------------"
			echo "2. Get data from an invalid URL"
			test_url="${url}arch=amd64"
			echo "Missing required parameter: ${test_url}"
			res="$(curl -skH "Accept: ${accept}" "${test_url}")"
			kind="$(echo "${res}" | jq -r ".kind")"
			value="$(echo "${res}" | jq -r ".value")"
			if [[ "${kind}" != "missing_params" ]] || [[ "${value}" != "mandatory client parameters missing: channel" ]]; then
				echo "${DATE}" "The response is not correct when missing required parameter: channel"
				((invalid_graph_retry += 1))
			fi

			for param in "channel=stable-a" "arch=amd64&channel=stable-a" "arch=amd64&channel=stable-a&id=ceb3b0bb-c689-4db9-bb6a-0122237e33fd" "arch=amd64&channel=stable-a&version=4.999.999"
			do
				test_url="${url}${param}"
				echo "invalid URL: ${test_url}"
				graph="$(curl -skH "Accept: ${accept}" "${test_url}")"
				version="$(echo "${graph}" | jq -r ".version")"
				nodes="$(echo "${graph}" | jq -r ".nodes[0]")"
				edges="$(echo "${graph}" | jq -r ".edges[0]")"
				conditionalEdges="$(echo "${graph}" | jq -r ".conditionalEdges[0]")"

				DATE="$(date --iso=s --utc)"; 
				if [[ "${version}" == "1" ]] && [[ "${nodes}" != "[]" ]] || [[ "${edges}" != "[]" ]] || [[ "${conditionalEdges}" != "[]" ]]; then
					echo "${DATE}" "get graph data with invalid url passed"
					invalid_graph_retry=0
				else
					echo "${DATE} Error: failed to get graph data with invalid url"
					echo -e "Get graph data: \n ${graph}"
					((invalid_graph_retry += 1))
				fi
			done
		done
	fi
	if [[ $invalid_graph_retry -ge 2 ]]; then
		DATE="$(date --iso=s --utc)"; 
		send_slack "${DATE} Error: failed to get graph data with invalid parameters"
		break
	fi
	echo -e "\n\n"
done
