#!/usr/bin/env bash
set -euo pipefail

SECRETS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../kubernetes/secrets" && pwd)"

for f in postgres.env n8n.env; do
  example="$SECRETS_DIR/${f}.example"
  target="$SECRETS_DIR/$f"
  if [[ ! -f $target ]]; then
    cp "$example" "$target"
    echo "Created $target — edit before kubectl apply"
  else
    echo "Exists: $target"
  fi
done
