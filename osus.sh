https://docs.openshift.com/container-platform/4.13/updating/updating-restricted-network-cluster/restricted-network-update-osus.html#update-service-install-cli_updating-restricted-network-cluster-osus



1. Build and mirror graph-data container image to local registry as Non-Root User
# podman build -f ./Dockerfile -t ${DIS_REGISTRY}/rh-osbs/cincinnati-graph-data-container:v4.6.0
# podman push ${DIS_REGISTRY}/rh-osbs/cincinnati-graph-data-container:v4.6.0


oc get catalogsource -n openshift-marketplace


# Create UpdateService resouce
# cat cincy.yaml 
apiVersion: cincinnati.openshift.io/v1beta1
kind: UpdateService
metadata:
  name: my-cincy
  namespace: osus
spec:
  replicas: 1
  releases: "quay.io/openshift-release-dev/ocp-release"
  graphDataImage: "quay.io/openshifttest/graph-data:v5.0.0"

# oc411 create -f cincy.yaml 
cincinnati.cincinnati.openshift.io/my-cincy created



oc create ns osus

cat <<EOF > og.yaml 
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: osus-og
  namespace: osus
spec:
  targetNamespaces:
  - osus
EOF

oc create -f og.yaml 

cat <<EOF > sub.yaml 
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: osus-sub
  namespace: osus
spec:
  channel: v1
  name: cincinnati-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  startingCSV: update-service-operator.v5.0.0
  installPlanApproval: Manual
EOF
oc create -f sub.yaml 

# manual 的operator需要在UI上approve

# Automatic
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: update-service-subscription
spec:
  channel: v1
  installPlanApproval: "Automatic"
  source: "redhat-operators" 
  sourceNamespace: "openshift-marketplace"
  name: "cincinnati-operator"


# oc delete sub osus-sub -n osus
# oc delete csv update-service-operator.v4.6.0 -n osus
# oc delete og osus-og -n osus


oc get route my-cincy-policy-engine-route -o jsonpath='{.spec.host}' -n osus
curl -skH 'Accept:application/json' "https://$url/api/upgrades_info/v1/graph?channel=stable-4.10" -o /dev/null -w "status: %{http_code}\n"

[root@localhost ~]# curl -skH 'Accept:application/json' "$url?channel=candidate-4.13"|jq .
{
  "version": 1,
  "nodes": [
    {
      "version": "4.13.5",
      "payload": "ec2-18-217-180-0.us-east-2.compute.amazonaws.com:5000/ocp-release@sha256:af19e94813478382e36ae1fa2ae7bbbff1f903dded6180f4eb0624afe6fc6cd4",
      "metadata": {
        "io.openshift.upgrades.graph.release.channels": "candidate-4.13,candidate-4.14",
        "io.openshift.upgrades.graph.release.manifestref": "sha256:af19e94813478382e36ae1fa2ae7bbbff1f903dded6180f4eb0624afe6fc6cd4",
        "url": "https://access.redhat.com/errata/RHSA-2023:4091"
      }
    }
  ],
  "edges": [],
  "conditionalEdges": []
}


# graph-data
https://quay.io/openshifttest/graph-data:latest


# Disconnected 
# Mirror osus operator and index image to local registry
skopeo copy docker://registry-proxy.engineering.redhat.com/rh-osbs/openshift-update-service-openshift-update-service-operator:v4.6.0 docker://${DIS_REGISTRY}/rh-osbs/openshift-update-service-openshift-update-service-operator:v4.6.0 --src-tls-verify=false

podman push ${DIS_REGISTRY}/rh-osbs/osus-index:1.1
# Note: if image is available, skip the step.



# Create osus-ca cm and add it to trusted ca of proxy for cluster to access the osus route
(refer to
https://docs.openshift.com/container-platform/4.6/networking/enable-cluster-wide-proxy.html)

oc get -n openshift-ingress-operator secret router-ca -o jsonpath="{.data.tls\.crt}" | base64 -d >ca-bundle.crt
oc -n openshift-config create configmap osus-ca --from-file=ca-bundle.crt
oc patch proxy cluster --type json -p '[{"op": "add", "path": "/spec/trustedCA/name", "value": "osus-ca"}]'