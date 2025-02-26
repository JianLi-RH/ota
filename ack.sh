# ack
[root@localhost ~]# oc -n openshift-config-managed get configmap admin-gates -o json | jq -r '.data|keys[]'
ack-4.11-kube-1.25-api-removals-in-4.12
[root@localhost ~]# 

oc -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.8-kube-1.22-api-removals-in-4.9":"true"}}' --type=merge

oc -n openshift-config get cm admin-acks

# 没patch的情况
[root@localhost ~]# oc413 -n openshift-config get cm admin-acks -o json
{
    "apiVersion": "v1",
    "kind": "ConfigMap",
    "metadata": {
        "annotations": {
            "include.release.openshift.io/ibm-cloud-managed": "true",
            "include.release.openshift.io/self-managed-high-availability": "true",
            "kubernetes.io/description": "Record administrator acknowledgments of update gates defined in the admin-gates ConfigMap in the openshift-config-managed namespace.",
            "release.openshift.io/create-only": "true"
        },
        "creationTimestamp": "2023-08-04T05:39:13Z",
        "name": "admin-acks",
        "namespace": "openshift-config",
        "resourceVersion": "1664",
        "uid": "a8d9f7a2-d597-47e4-be10-508975866b3c"
    }
}
[root@localhost ~]# 
