# https://docs.openshift.com/container-platform/4.15/installing/disconnected_install/installing-mirroring-installation-images.html


# get pull secret (config.json) from https://console.redhat.com/openshift/install/pull-secret

# Download image to local folder
oc adm release mirror --from=quay.io/openshift-release-dev/ocp-release:4.16.0-ec.5-x86_64 --to-dir=/home/cloud-user/jianl/data --to=file://test -a config.json

# Upload image to registry
oc image mirror --from-dir=/home/cloud-user/jianl/data 'file://test:4.16.0-ec.5-x86_64*' quay.io/rhn_support_jianl/release -a config.json


oc image mirror --from-dir=/tmp/OCP-30833/data 'file://test:4.13.7-x86_64*' jianl072801.mirror-registry.qe.azure.devcluster.openshift.com:5000/ocp-release


# Directly push the release images to the local registry by using following command:
oc adm release mirror -a config.json \
    --from=quay.io/openshift-release-dev/ocp-release:4.16.0-ec.5-x86_64 \
    --to=quay.io/rhn_support_jianl/release \
    --to-release-image=quay.io/rhn_support_jianl/release:4.16.0-ec.5-x86_64

oc413 adm release mirror -a config.json --from=quay.io/openshift-release-dev/ocp-release:4.13.7-x86_64 --to-dir=/tmp/OCP-30833/data --to=file://test
oc413 adm release mirror -a config.json --to-dir=/mnt/mirror-to-disk quay.io/openshift-release-dev/ocp-release:4.13.7-x86_64
oc413 adm release mirror --dry-run --from=quay.io/openshift-release-dev/ocp-release:4.13.7-x86_64 --to-dir=/tmp/OCP-30833/data --to=file://test -a config.json