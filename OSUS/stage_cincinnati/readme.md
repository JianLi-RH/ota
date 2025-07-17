podman build -t quay.io/rhn_support_jianl/monitor:latest -f Dockerfile

podman push quay.io/rhn_support_jianl/monitor:latest

oc apply -f deployment.yaml