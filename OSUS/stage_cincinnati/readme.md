podman build -t quay.io/rhn_support_jianl/monitor:latest -f Dockerfile.cincy
podman push quay.io/rhn_support_jianl/monitor:latest

podman build -t quay.io/rhn_support_jianl/monitor_digest:latest -f Dockerfile.digest
podman push quay.io/rhn_support_jianl/monitor_digest:latest

podman build -t quay.io/rhn_support_jianl/monitor_spec:latest -f Dockerfile.spec
podman push quay.io/rhn_support_jianl/monitor_spec:latest

oc apply -f deployment.yaml

oc replace -f deployment.yaml

oc scale --replicas 1 deployments/cincinnati-monitor