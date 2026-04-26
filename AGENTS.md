# Egolia Infra

Include kubernetes manifest. This repo only contains mostly app, not kubernetes infrastructure. The infrastructure is managed in another repo, so this repo only a necessary extends to the infrastructure repo

## Stack

- This repo contains CRDs: FluxCD, CNPG, Istio
  > Mostly config for dataplane, not control plane
- The infra repo contains Authentik, cert-manager, monitoring (grafana, prometheus, alloy, tempo, loki), Istio controller, RustFS (S3 compatible)
- Services written in go, has well designed health conform the kubernetes health check
- Services has grpc and http route, and a separate health check route
- Web app written in NextJS

## Structure

### Kubernetes

- The ingress gateway is not declared in this repo, only waypoint is. Both live inside istio-system

```
kubernetes
├── app                     # app
│   ├── base                # base app
│   │   ├── billing         # billing service
│   │   │   ├── billing
│   │   │   └── cnpg
│   │   ├── blog            # blog service
│   │   │   ├── blog
│   │   │   └── cnpg
│   │   ├── course          # course service
│   │   │   ├── cnpg
│   │   │   └── course
│   │   └── web             # web app
│   │       └── web
│   └── kevinnitrohomelab   # overlay
│       ├── billing
│       │   ├── billing
│       │   └── cnpg
│       ├── blog
│       │   ├── blog
│       │   └── cnpg
│       ├── course
│       │   ├── cnpg
│       │   └── course
│       └── web
│           └── web
├── cluster                 # cluster
│   └── kevinnitrohomelab   # cluster for kevinnitrohomelab, used for applying to flux
│       ├── app
│       ├── clustersetting
│       └── infra
└── infra                   # infrastructure
    └── kevinnitrohomelab   # infra config for kevinnitrohomelab
        ├── flux-system
        │   └── egolia
        └── istio-system
            └── egolia
```

- Each app base contains deployment, service, secret, configmap, no labels, namespace, and the cnpg cluster (postgres)
- App overlay:
  - Patch the app image for specific version, updated by renovate
  - Label istio waypoint
- Cluster:
  - Contains namespaces, with istio label for ambient mode
  - There are some variable for Flux to substitute while applying manifest, in `clustersetting`
- Infra:
  - Flux system: webhook
  - istio system: waypoint, authorization policy, authentication request, which map JWT claims to request, verify JWT from authentik. It is scoped inside egolia section
- Most organised as folder by namespace, so, each folder only for 1 namespace
