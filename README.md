# AQAssessment

## OpenRouter secret

The API key is injected at runtime and must never be committed, copied into a
Dockerfile, or stored in a Kubernetes manifest.

Create or update the Secret in the local Kind cluster:

```bash
export OPENROUTER_API_KEY
KUBE_CONTEXT=kind-aq-takehome \
  bash scripts/create-openrouter-secret.sh
```

The script defaults to the `kind-aq-takehome` context and refuses to modify a
remote cluster unless `ALLOW_REMOTE_KUBE_CONTEXT=true` is explicitly set. Use
`KUBE_NAMESPACE` or `KUBE_SECRET_NAME` to override the default namespace or
Secret name.

Application manifests can consume the Secret without containing its value:

```yaml
env:
  - name: OPENROUTER_API_KEY
    valueFrom:
      secretKeyRef:
        name: openrouter-api
        key: OPENROUTER_API_KEY
```

`k8s/secret.yaml.example` documents the expected Secret shape using a
placeholder only. Its `.example` suffix prevents `kubectl apply -f k8s/` from
applying it accidentally.