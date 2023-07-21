# ack
[root@localhost ~]# oc411 -n openshift-config-managed get configmap admin-gates -o json | jq -r '.data|keys[]'
ack-4.11-kube-1.25-api-removals-in-4.12
[root@localhost ~]# 

oc413 -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.13-kube-1.27-api-removals-in-4.14":"true"}}' --type=merge

