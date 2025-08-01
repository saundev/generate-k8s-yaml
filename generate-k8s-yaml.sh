#!/bin/bash
###############
### SaunDev ###
###############
### Generate Kubernetes YAML files for all cluster and namespaced resources. Note: ComponentStatus (cs) is deprecated.
### Suitable for Bash Version 3.0+ (Note associative arrays on Bash Version 4.0+ could combine array / map with name and type).
namespaceObjects=(app appproj appset cj cm controllerrevisions deploy ds endpointslices event hpa ing jobs leases limits localsubjectaccessreviews netpol pdb pod podtemplates pvc quota rc rolebindings roles rs sa secrets sts svc)
clusterObjects=(apiservices clusterrolebindings clusterroles crd csidrivers csinodes csr flowschemas ingressclasses ip mutatingwebhookconfigurations node ns pc prioritylevelconfigurations pv runtimeclasses sc selfsubjectaccessreviews selfsubjectreviews selfsubjectrulesreviews servicecidrs subjectaccessreviews tokenreviews validatingadmissionpolicies validatingadmissionpolicybindings validatingwebhookconfigurations volumeattachments)

generate_yaml() {
  for resource in "${namespaceObjects[@]}"; do
    for ns in $(kubectl get ns -o=jsonpath='{.items[*].metadata.name}' | tr ' ' '\n'); do
      outdir="$ns"
      mkdir -p "$outdir"
      if kubectl get "$resource" -n="$ns" &>/dev/null; then
        echo "Generating YAML for $resource in namespace $ns"
        kubectl get "$resource" -n="$ns" -o=yaml > "$outdir/$resource.yaml" &
      fi
    done
    wait
  done
  outdir="cluster"
  mkdir -p "$outdir"
  for resource in "${clusterObjects[@]}"; do
    if kubectl get "$resource" &>/dev/null; then
      echo "Generating YAML for cluster-wide resource: $resource"
      kubectl get "$resource" -o=yaml > "$outdir/$resource.yaml" &
    fi
  done
  wait
}

generate_yaml
