#!/bin/bash
###############
### SaunDev ###
###############
### Note that ComponentStatus (cs) is deprecated so removed from list - Also while (k get all) is shorter it does not get all resources such as secrets, etc.
for ns in $(k get ns -o=jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')
do
  for resource in $(k get cj,cm,crd,deploy,ds,hpa,ingress,ip,job,node,pod,pv,pvc,sa,sc,secret,statefulset,svc -o=name -n=$ns)
  do
    outdir=$(dirname $ns/$resource)
    mkdir -p "$outdir"
    k get $resource -n=$ns -o=yaml > "$ns/$resource.yaml"
  done
done
