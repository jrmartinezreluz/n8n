# Secrets

Before deploying, create env files from the examples:

```bash
cp postgres.env.example postgres.env
cp n8n.env.example n8n.env
# Edit both files — use strong passwords and: openssl rand -hex 32 for N8N_ENCRYPTION_KEY
```

Kustomize generates `postgres-secret` and `n8n-secret` from these files. They are **gitignored**.
