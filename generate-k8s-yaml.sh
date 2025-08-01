#!/bin/bash
###############
### SaunDev ###
###############
### Note ComponentStatus (cs) as it's deprecated - Also while (k get all) is shorter it does not get all resources such as secrets, etc.
for ns in $(k get ns -o=jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')
do
  for resource in $(k get cj,cm,clusterroles,crd,csr,deploy,ds,hpa,ingress,ip,job,mutatingwebhookconfigurations,node,pod,pv,pvc,roles,sa,sc,secret,statefulset,svc,validatingwebhookconfigurations -o=name -n=$ns)
  do
    outdir=$(dirname $ns/$resource)
    mkdir -p "$outdir"
    k get $resource -n=$ns -o=yaml > "$ns/$resource.yaml"
  done
done
