
docker pull quay.io/openshift-release-dev/ocp-release:4.16.0-ec.1-x86_64
docker tag quay.io/openshift-release-dev/ocp-release:4.16.0-ec.1-x86_64 quay.io/openshift-qe-optional-operators/prow-test-results-classfier:4.16.0-ec.1-x86_64
docker push quay.io/openshift-qe-optional-operators/prow-test-results-classfier:4.16.0-ec.1-x86_64

