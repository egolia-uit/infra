# Egolia Infra

Include kubernetes manifest. This repo only contains mostly app, not kubernetes infrastructure. The infrastructure is managed in another repo, so this repo only a necessary extends to the infrastructure repo

## Stack

- This repo contains CRDs: FluxCD, CNPG, Istio
  > Mostly config for dataplane, not control plane
- The infra repo contains Authentik, cert-manager, monitoring (grafana, prometheus, alloy, tempo, loki), Istio controller

## Structure

### Kubernetes

- The ingress gateway is not declared in this repo, only waypoint is. Both live inside istio-system
