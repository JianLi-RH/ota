####################################### 安装Subscription #############################################
# OCP-35869 - install/uninstall osus operator from OperatorHub through CLI	
# https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-35869
# https://docs.openshift.com/container-platform/4.15/updating/updating_a_cluster/updating_disconnected_cluster/disconnected-update-osus.html#update-service-install-cli_updating-restricted-network-cluster-osus

# 创建namespace
oc create ns osus

# 创建OperatorGroup
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

# 查看已安装的CatalogSource
oc get catalogsource -n openshift-marketplace

# 安装subscription
## 安装最新版本（默认）subscription (Operator)
cat <<EOF > sub.yaml 
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: osus-sub
  namespace: osus
spec:
  channel: v1
  name: cincinnati-operator 
  source: 上面的source
  sourceNamespace: openshift-marketplace
EOF

## 安装指定版本subscription


oc create -f sub.yaml 


####################################### 创建 graph data container image #############################################
# 使用Dokckerfile
podman build -f ./Dockerfile -t registry.example.com/openshift/graph-data:latest
podman push registry.example.com/openshift/graph-data:latest

# For example:
# DIS_REGISTRY可以在cluster_info.yaml里查看
DIS_REGISTRY=jianl042301.mirror-registry.qe.gcp.devcluster.openshift.com:5000
podman build -f ./Dockerfile -t ${DIS_REGISTRY}/openshift/graph-data:latest
podman login ${DIS_REGISTRY}
podman push ${DIS_REGISTRY}/openshift/graph-data:latest



####################################### 将 payload mirror 到registry #############################################
DIS_REGISTRY=jianl042301.mirror-registry.qe.gcp.devcluster.openshift.com:5000
oc adm release mirror --from=quay.io/openshift-release-dev/ocp-release:4.16.0-ec.5-x86_64 \
    --to=${DIS_REGISTRY}/openshift-release-dev/ocp-release \
    --to-release-image=${DIS_REGISTRY}/ocp-release:4.16.0-ec.5-x86_64

oc adm release mirror --from=quay.io/openshift-release-dev/ocp-release:4.16.0-ec.5-x86_64 \
    --to=${DIS_REGISTRY}/openshift-release-dev/ocp-release \
    --to-release-image=${DIS_REGISTRY}/ocp-release:4.16.0-ec.5-x86_64

####################################### 安装 Update Service Instance #############################################
# https://docs.openshift.com/container-platform/4.15/updating/updating_a_cluster/updating_disconnected_cluster/disconnected-update-osus.html#update-service-create-service-cli_updating-restricted-network-cluster-osus
#
# https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-35944
# OCP-35944 - [disconnect] Create/delete updateservice instance from operator through cli and build graph-data image as non-root user	

# OCP-62641 - create/delete updateservice instance from operator through cli and build graph-data image using oc-mirror	
# https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-62641

# 使用前面方法安装完subscription / osus operator之后，可以安装Update Service

# 安装证书
oc -n openshift-config extract cm/user-ca-bundle --confirm
oc create -n openshift-config cm trusted-ca --from-file=updateservice-registry=ca-bundle.crt
oc patch image.config.openshift.io cluster -p '{"spec":{"additionalTrustedCA":{"name":"trusted-ca"}}}' --type merge


# 创建update service 实例
cat <<EOF > cincy.yaml
apiVersion: updateservice.operator.openshift.io/v1
kind: UpdateService
metadata:
  name: service
  namespace: openshift-update-service
spec:
  replicas: 1
  releases: "$DIS_REGISTRY/ocp-release"
  graphDataImage: "$DIS_REGISTRY/openshift/graph-data:latest"
EOF

oc -n openshift-update-service create -f cincy.yaml



oc get ClusterServiceVersion -n openshift-update-service
oc -n openshift-update-service get pods