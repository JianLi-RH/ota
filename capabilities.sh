https://docs.openshift.com/container-platform/4.15/updating/understanding_updates/intro-to-updates.html

[root@localhost ~]# oc411 edit clusterversion version
clusterversion.config.openshift.io/version edited
[root@localhost ~]# oc411 get clusterversion version -o json | jq '.spec.capabilities'
{
  "additionalEnabledCapabilities": [
    "marketplace",
    "baremetal"
  ],
  "baselineCapabilitySet": "None"
}
