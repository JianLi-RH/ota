FROM registry.access.redhat.com/ubi9/ubi:latest

# RUN curl -L -o cincinnati-graph-data.tar.gz https://api.openshift.com/api/upgrades_info/graph-data

COPY cincinnati-graph-data.tar.gz .
RUN mkdir -p /var/lib/cincinnati-graph-data && tar xvzf cincinnati-graph-data.tar.gz -C /var/lib/cincinnati-graph-data/ --no-overwrite-dir --no-same-owner

# CMD ["/bin/bash", "-c" ,"exec cp -rp /var/lib/cincinnati-graph-data/* /var/lib/cincinnati/graph-data"]
# COPY cincinnati-graph-data /var/lib/
CMD ["/bin/bash", "-c" ,"exec cp -rp /var/lib/cincinnati-graph-data/cincinnati-graph-data/* /var/lib/cincinnati/graph-data"]
RUN ls /var/lib/cincinnati-graph-data/cincinnati-graph-data



# 下面是原始的Dockerfile
# https://docs.openshift.com/container-platform/4.18/disconnected/updating/disconnected-update-osus.html

# FROM registry.access.redhat.com/ubi9/ubi:latest

# RUN curl -L -o cincinnati-graph-data.tar.gz https://api.openshift.com/api/upgrades_info/graph-data

# RUN mkdir -p /var/lib/cincinnati-graph-data && tar xvzf cincinnati-graph-data.tar.gz -C /var/lib/cincinnati-graph-data/ --no-overwrite-dir --no-same-owner

# CMD ["/bin/bash", "-c" ,"exec cp -rp /var/lib/cincinnati-graph-data/* /var/lib/cincinnati/graph-data"]