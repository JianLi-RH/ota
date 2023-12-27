# 查看scc属性
oc explain scc.allowPrivilegeEscalation
KIND:     SecurityContextConstraints
VERSION:  security.openshift.io/v1

DESCRIPTION:
     AllowPrivilegeEscalation determines if a pod can request to allow privilege
     escalation. If unspecified, defaults to true.