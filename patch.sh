oc patch clusterversion version --type json -p '[{"op": "add", "path": "/spec/channel", "value": "stable-4.13"}, {"op": "add", "path": "/spec/upstream", "value": "https://raw.githubusercontent.com/JianLi-RH/ota/main/patch.json"}]'


oc patch clusterversion version --type=merge -p '{"spec": {"overrides":[{"kind": "Deployment", "name": "network-operator", "namespace": "openshift-network-operator", "unmanaged": true, "group": "apps"}]}}'
oc patch clusterversion version --type=json -p '[{"op": "remove","path":"/spec/overrides"}]'


oc -n openshift-config-managed patch configmap admin-gates --type=json -p='[{"op": "remove", "path": "/data/ack-4.8-dummy"}]'