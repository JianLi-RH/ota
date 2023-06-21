oc patch clusterversion version --type json -p '[{"op": "add", "path": "/spec/channel", "value": "stable-4.13"}, {"op": "add", "path": "/spec/upstream", "value": "https://raw.githubusercontent.com/JianLi-RH/ota/main/patch.json"}]'


oc patch clusterversion version --type=merge -p '{"spec": {"overrides":[{"kind": "Deployment", "name": "network-operator", "namespace": "openshift-network-operator", "unmanaged": true, "group": "apps"}]}}'
oc patch clusterversion version --type=json -p '[{"op": "remove","path":"/spec/overrides"}]'


oc -n openshift-config-managed patch configmap admin-gates --type=json -p='[{"op": "remove", "path": "/data/ack-4.8-dummy"}]'


oc patch clusterversion version --type=json -p '[{"op": "remove","path":"/spec/channel"}]'


oc413 adm upgrade channel candidate-4.9
[root@localhost ~]# oc413 adm upgrade channel
warning: Clearing channel "candidate-4.9"; cluster will no longer request available update recommendations.


token=`oc -n openshift-monitoring create token prometheus-k8s`
url=`oc get route prometheus-k8s -n openshift-monitoring --no-headers|awk '{print $2}'`
curl -s -k -H "Authorization: Bearer $token" https://$url/api/v1/label/reason/values|grep 'FeatureGates_RestrictedFeatureGates_TechPreviewNoUpgrade'

token=`oc -n openshift-monitoring create token prometheus-k8s`
route=`oc get route prometheus-k8s -n openshift-monitoring -ojsonpath='{.status.ingress[].host}'`
echo $route
prometheus-k8s-openshift-monitoring.apps.jianl062101.qe.devcluster.openshift.com
curl -s -k -H "Authorization: Bearer $token" https://$route/api/v1/alerts | jq -r '.data.alerts[]| select(.labels.alertname == "ClusterOperatorDown")|.state'
