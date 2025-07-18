FROM registry.ci.openshift.org/ci/tests-private:4.20

WORKDIR /

COPY . .

RUN wget https://openshift-release-artifacts.apps.ci.l2s4.p1.openshiftapps.com/4.20.0-0.nightly-2025-07-15-083124/openshift-client-linux-amd64-rhel9-4.20.0-0.nightly-2025-07-15-083124.tar.gz && \
    tar -xvzf openshift-client-linux-amd64-rhel9-4.20.0-0.nightly-2025-07-15-083124.tar.gz

RUN chmod +x ./check_cincinnati.sh

USER root
CMD ./check_cincinnati.sh
