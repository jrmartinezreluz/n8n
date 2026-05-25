# Architecture diagrams

Visual reference for **n8n** on Kubernetes (`n8n-dev.arkhadia.com`).

---

## Cluster layout

```mermaid
flowchart TB
    Users[Users / Webhooks]

    subgraph Ingress_Layer["Ingress NGINX"]
        ING[Ingress<br/>n8n-dev.arkhadia.com]
    end

    subgraph NS["Namespace: n8n"]
        SVC[n8n-service :80]
        N8N[n8n Deployment<br/>n8nio/n8n:1.108.2]
        PVC1[n8n-pvc 2Gi]
        PG[(postgres Deployment<br/>postgres:16)]
        PVC2[postgresql-pv 100Gi]
        CM[n8n-config ConfigMap]
        SEC1[n8n-secret]
        SEC2[postgres-secret]
    end

    Users --> ING
    ING --> SVC --> N8N
    N8N --> PVC1
    N8N --> CM & SEC1
    N8N -->|postgresdb :5432| PG
    PG --> PVC2 & SEC2
```

---

## Traffic paths

```mermaid
flowchart LR
    Browser[Browser] -->|HTTPS| Ingress
    Webhook[External systems] -->|POST /webhook/*| Ingress
    Ingress --> n8n[n8n pod :5678]
    n8n --> DB[(PostgreSQL)]
```

| Path | Purpose |
|------|---------|
| `/` | Editor UI |
| `/webhook/` | Workflow webhooks |
| `/form/` | n8n forms |
| `/healthz` | Liveness |
| `/healthz/readiness` | Readiness (DB migrated + ready) |

---

## Secrets and configuration

```mermaid
flowchart TB
    subgraph Git["Git repo"]
        EX1[postgres.env.example]
        EX2[n8n.env.example]
        CMF[n8n-configmap.yaml]
    end

    subgraph Local["Local only gitignored"]
        E1[postgres.env]
        E2[n8n.env]
    end

    subgraph K8s["Generated at apply"]
        PS[postgres-secret]
        NS[n8n-secret]
        CM[n8n-config]
    end

    EX1 -.-> E1 --> PS
    EX2 -.-> E2 --> NS
    CMF --> CM
```

| Secret / Config | Keys |
|-----------------|------|
| `postgres-secret` | `POSTGRES_USER`, `POSTGRES_PASSWORD`, `POSTGRES_DB` |
| `n8n-secret` | `N8N_ENCRYPTION_KEY`, `N8N_BASIC_AUTH_*` |
| `n8n-config` | Host, URLs, DB host, feature flags |

---

## Deployment flow

```mermaid
flowchart TD
    A[cp secrets/*.env.example] --> B[Edit postgres.env + n8n.env]
    B --> C[kubectl apply -k kubernetes/]
    C --> D[Wait: postgres ready]
    D --> E[n8n init: wait-for-postgres]
    E --> F[n8n pod ready]
    F --> G[https://n8n-dev.arkhadia.com]
```

---

## Related

- [README.md](../README.md) — deploy steps
- [kubernetes/secrets/README.md](../kubernetes/secrets/README.md) — credential files
