# get pull secret (config.json) from https://console.redhat.com/openshift/install/pull-secret

# Download image to local folder
oc adm release mirror --from=quay.io/openshift-release-dev/ocp-release:4.12.19-x86_64 --to-dir=/tmp/OCP-30833/data --to=file://test -a config.json

# Upload image to registry
oc image mirror --from-dir=/tmp/OCP-30833/data 'file://test:4.12.19-x86_64*' quay.io/repository/rhn_support_jianl/jianl_test -a config.json 

