#!/bin/bash

function send_slack() {
	local message="$1"
	url="https://hooks.slack.com/triggers/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"
	curl -X POST "${url}" -d '{"msg": "'"${message}"'"}'
}

version="4.16.1"
digest_channel="fast-4.16"
host="https://api.stage.openshift.com"

digest=$(oc image info "quay.io/openshift-release-dev/ocp-release:${version}-x86_64" -ojson | jq -r ".digest")
echo "Expected digest is: ${digest}"


digest_retry=0
while sleep 10; 
do 
	echo "=================check if Cincinnati can get correct digest================="
	if [[ $digest_retry -lt 2 ]]; then
		for url in "${host}/api/upgrades_info/v1/graph?arch=amd64&channel=${digest_channel}" "${host}/api/upgrades_info/graph?arch=amd64&channel=${digest_channel}"
		do
			echo "Cincinnati URL: ${url}"
			PAYLOAD="$(curl -skH 'Accept:application/json' "${url}" | jq -r '.nodes[] | select(.version == "'${version}'").payload')"; 
			
			DATE="$(date --iso=s --utc)"; 
			if [[ "${PAYLOAD}" =~ ${digest} ]]; then
				echo "${DATE}" "${PAYLOAD}"
				digest_retry=0
			else
				echo "${DATE} Error: digest in payload is confusing: ${PAYLOAD}"
				((digest_retry += 1))
			fi
		done
	fi
	if [[ $digest_retry -eq 2 ]]; then
		DATE="$(date --iso=s --utc)"; 
		send_slack "${DATE} Error: digest in payload is confusing"
        break
	fi
done