#!/bin/bash
###############
### SaunDev ###
###############
### Generate Kubernetes YAML files for all resources in all namespaces & cluster-wide resources.
### Note: ComponentStatus (cs) is deprecated and removed from clusterObject array.
### Suitable for Bash Version 3.0+ (Note associative arrays on Bash Version 4.0+ could combine array / map with name and type).
namespaceObjects=(app appproj appset cj cm controllerrevisions deploy ds endpointslices event hpa ing jobs leases limits localsubjectaccessreviews netpol pdb pod podtemplates pvc quota rc rolebindings roles rs sa secrets sts svc)
clusterObjects=(apiservices clusterrolebindings clusterroles crd csidrivers csinodes csr flowschemas ingressclasses ip mutatingwebhookconfigurations node ns pc prioritylevelconfigurations pv runtimeclasses sc selfsubjectaccessreviews selfsubjectreviews selfsubjectrulesreviews servicecidrs subjectaccessreviews tokenreviews validatingadmissionpolicies validatingadmissionpolicybindings validatingwebhookconfigurations volumeattachments)

ensure_k8s_alias() {
  if ! command -v k &> /dev/null; then
    alias k=kubectl
  fi
}

generate_namespace_yaml() {
  for ns in $(k get ns -o=jsonpath='{.items[*].metadata.name}' | tr ' ' '\n')
  do
    for resource in "${namespaceObjects[@]}"
    do
      outdir="$ns"
      echo "Generating YAML for resource: $resource in namespace: $ns"
      mkdir -p "$outdir"
      k get $resource -n=$ns -o=yaml > "$ns/$resource.yaml" &
    done
    wait
  done
}

generate_cluster_yaml() {
  outdir="cluster"
  mkdir -p "$outdir"
  for resource in "${clusterObjects[@]}"
  do
    echo "Generating YAML for cluster-wide resource: $resource"
    k get $resource -o=yaml > "$outdir/$resource.yaml" &
  done
  wait
}

ensure_k8s_alias
generate_namespace_yaml
generate_cluster_yaml
