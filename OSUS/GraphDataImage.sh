# Creating the OpenShift Update Service graph data container image
# https://docs.openshift.com/container-platform/4.15/updating/updating_a_cluster/updating_disconnected_cluster/disconnected-update-osus.html#update-service-graph-data_updating-restricted-network-cluster-osus

podman build -f ./Dockerfile -t registry.example.com/openshift/graph-data:latest
podman push registry.example.com/openshift/graph-data:latest

# 可以自己build一个Graph Data Image
# https://polarion.engineering.redhat.com/polarion/#/project/OSE/workitem?id=OCP-37858
# 可以下载 curl -L -o cincinnati-graph-data.tar.gz https://api.openshift.com/api/upgrades_info/graph-data
# 然后编辑里面的内容，如 添加blocked version, 修改 channel