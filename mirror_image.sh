# get pull secret (config.json) from https://console.redhat.com/openshift/install/pull-secret

# Download image to local folder
oc adm release mirror --from=quay.io/openshift-release-dev/ocp-release:4.12.19-x86_64 --to-dir=/tmp/OCP-30833/data --to=file://test -a config.json

# Upload image to registry
oc image mirror --from-dir=/tmp/OCP-30833/data 'file://test:4.12.19-x86_64*' quay.io/repository/rhn_support_jianl/jianl_test -a config.json 


oc413 image mirror --from-dir=/tmp/OCP-30833/data 'file://test:4.13.7-x86_64*' jianl072801.mirror-registry.qe.azure.devcluster.openshift.com:5000/ocp-release


oc413 adm release mirror -a config.json --from=quay.io/openshift-release-dev/ocp-release:4.13.7-x86_64 --to-dir=/tmp/OCP-30833/data --to=file://test
oc413 adm release mirror -a config.json --to-dir=/mnt/mirror-to-disk quay.io/openshift-release-dev/ocp-release:4.13.7-x86_64
oc413 adm release mirror --dry-run --from=quay.io/openshift-release-dev/ocp-release:4.13.7-x86_64 --to-dir=/tmp/OCP-30833/data --to=file://test -a config.json