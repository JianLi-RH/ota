#!/bin/bash

function send_slack() {
	local message="$1"
	url="https://hooks.slack.com/triggers/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"
	curl -X POST "${url}" -d '{"msg": "'"${message}"'"}'
}

function check_parameter() {
    local parameter="$1" path="$2" res="$3" 

    DATE="$(date --iso=s --utc)"; 
    param=$(echo "${res}" | jq "${path}.parameters")
    value=$(echo "$param" | jq -r '.[] | select(.name=="'"${parameter}"'")')
    if [[ -z "${value}" ]] ; then
        echo -e "${DATE} Error: failed to get ${parameter} from openapi \n ${param}"
        return 1
    fi

    echo "The parameter's spec from graph API is correct: ${parameter}"

    return 0
}

function check_response() {
    local http_code="$1" path="$2" res="$3" 

    DATE="$(date --iso=s --utc)"; 
    responses=$(echo "${res}" | jq "${path}.get.responses")
    content=$(echo "${responses}" | jq '."'"${http_code}"'"' | jq ".content")
    responses_ref=$(echo "$content" | jq -r '."application/json".schema."$ref"')

    if [[ "${http_code}" == "200" ]]; then
        if [[ "${responses_ref}" != "#/components/schemas/Graph" ]] ; then
            echo -e "${DATE} Error: failed to get responses/200/content/application/json from openapi: ref \n ${responses}"
            return 1
        fi
        responses_new_ref=$(echo "$responses" | jq -r '."application/vnd.redhat.cincinnati.v1+json".schema."$ref"')
        if [[ "${responses_new_ref}" != "#/components/schemas/Graph" ]] ; then
            echo -e "${DATE} Error: failed to get responses/200/content/application/vnd.redhat.cincinnati.v1+json from openapi: ref \n ${responses}"
            return 1
        fi
    else
        if [[ "${responses_ref}" != "#/components/schemas/GraphError" ]] ; then
            echo -e "${DATE} Error: failed to get responses/${http_code}/content/application/json from openapi: ref \n ${responses}"
            return 1
        fi
    fi

    echo "The responce spec from graph API is correct: ${http_code}"

    return 0
}

openapi_retry=0
while sleep 60; 
do 
	echo -e "\n\n"
	echo "=================check openapi================="
	if [[ $openapi_retry -lt 2 ]]; then
		openapi="https://api.stage.openshift.com/api/upgrades_info/openapi"
        res=$(curl -s "${openapi}")

        DATE="$(date --iso=s --utc)"; 
        openapi_version=$(echo "${res}" | jq ".components.schemas.Version")
        openapi_version_example=$(echo "$openapi_version" | jq -r ".example")
        if [[ -z "${openapi_version_example}" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Version from openapi: example"
            ((openapi_retry += 1))
            continue
        fi
        openapi_version_description=$(echo "$openapi_version" | jq -r ".description")
        if [[ "${openapi_version_description}" != "The version of an OpenShift release" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Version from openapi: description"
            ((openapi_retry += 1))
            continue
        fi
        openapi_version_type=$(echo "$openapi_version" | jq -r ".type")
        if [[ "${openapi_version_type}" != "string" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Version from openapi: type"
            ((openapi_retry += 1))
            continue
        fi
        echo "components.schemas.Version spec from graph API is correct"

        openapi_properties_version=$(echo "${res}" | jq ".components.schemas.Graph.properties.version")
        openapi_properties_version_example=$(echo "$openapi_properties_version" | jq -r ".example")
        if [[ "${openapi_properties_version_example}" != "1" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/version from openapi: example"
            ((openapi_retry += 1))
            continue
        fi
        openapi_properties_version_example=$(echo "$openapi_properties_version" | jq -r ".type")
        if [[ "${openapi_properties_version_example}" != "integer" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/version from openapi: type"
            ((openapi_retry += 1))
            continue
        fi
        echo "components.schemas.Graph.properties.version spec from graph API is correct"

        openapi_properties_nodes=$(echo "${res}" | jq ".components.schemas.Graph.properties.nodes")
        openapi_properties_nodes_type=$(echo "$openapi_properties_nodes" | jq -r ".type")
        if [[ "${openapi_properties_nodes_type}" != "array" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/nodes from openapi: type"
            ((openapi_retry += 1))
            continue
        fi
        openapi_properties_nodes_items=$(echo "$openapi_properties_nodes" | jq -r '.items."$ref"')
        if [[ "${openapi_properties_nodes_items}" != "#/components/schemas/Node" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/nodes/items from openapi: items"
            ((openapi_retry += 1))
            continue
        fi
        echo "components.schemas.Graph.properties.nodes spec from graph API is correct"

        openapi_properties_edges=$(echo "${res}" | jq ".components.schemas.Graph.properties.edges")
        openapi_properties_edges_type=$(echo "$openapi_properties_edges" | jq -r ".type")
        if [[ "${openapi_properties_edges_type}" != "array" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/edges from openapi: type"
            ((openapi_retry += 1))
            continue
        fi
        openapi_properties_edges_items=$(echo "$openapi_properties_edges" | jq -r '.items."$ref"')
        if [[ "${openapi_properties_edges_items}" != "#/components/schemas/Edge" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/edges/items from openapi: ref"
            ((openapi_retry += 1))
            continue
        fi
        echo "components.schemas.Graph.properties.edges spec from graph API is correct"

        openapi_properties_conditionalEdges=$(echo "${res}" | jq ".components.schemas.Graph.properties.conditionalEdges")
        openapi_properties_conditionalEdges_type=$(echo "$openapi_properties_conditionalEdges" | jq -r ".type")
        if [[ "${openapi_properties_conditionalEdges_type}" != "array" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/edges from openapi: type"
            ((openapi_retry += 1))
            continue
        fi
        openapi_properties_conditionalEdges_items=$(echo "$openapi_properties_conditionalEdges" | jq -r '.items."$ref"')
        if [[ "${openapi_properties_conditionalEdges_items}" != "#/components/schemas/ConditionalEdges" ]] ; then
            echo "${DATE}" "Error: failed to get schemas' Graph/properties/conditionalEdges/items from openapi: ref"
            ((openapi_retry += 1))
            continue
        fi
        echo "components.schemas.Graph.properties.conditionalEdges spec from graph API is correct"

		for path in '.paths."/api/upgrades_info/graph"' '.paths."/api/upgrades_info/v1/graph"'
		do
			echo "------------------Check path ${path}------------------"
            if ! check_parameter "id" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_parameter "channel" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_parameter "arch" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_parameter "version" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi

            if ! check_response "200" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_response "400" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_response "406" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_response "500" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
            if ! check_response "default" "${path}" "${res}"; then
                ((openapi_retry += 1))
                continue
            fi
		done
	fi
	if [[ $openapi_retry -eq 2 ]]; then
        DATE="$(date --iso=s --utc)"; 
        echo "${DATE} Error: failed to check response schema of openapi"
		send_slack "${DATE} Error: failed to check response schema of openapi"
		break
	fi
done