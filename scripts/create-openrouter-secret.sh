#!/usr/bin/env bash

set -euo pipefail

context="${KUBE_CONTEXT:-kind-aq-takehome}"
namespace="${KUBE_NAMESPACE:-default}"
secret_name="${KUBE_SECRET_NAME:-openrouter-api}"

if [[ -z "${OPENROUTER_API_KEY:-}" ]]; then
  echo "OPENROUTER_API_KEY is not exported in this shell." >&2
  exit 1
fi

configured_context="$(kubectl config get-contexts "${context}" -o name 2>/dev/null || true)"
if [[ "${configured_context}" != "${context}" ]]; then
  echo "Kubernetes context '${context}' does not exist." >&2
  exit 1
fi

if [[ "${context}" != kind-* && "${ALLOW_REMOTE_KUBE_CONTEXT:-false}" != "true" ]]; then
  echo "Refusing to modify non-Kind context '${context}'." >&2
  echo "Set ALLOW_REMOTE_KUBE_CONTEXT=true only when the assessment explicitly authorizes it." >&2
  exit 1
fi

if ! kubectl --context "${context}" get namespace "${namespace}" >/dev/null 2>&1; then
  echo "Namespace '${namespace}' does not exist in context '${context}'." >&2
  exit 1
fi

secret_env_file="$(mktemp)"
trap 'rm -f "${secret_env_file}"' EXIT
chmod 600 "${secret_env_file}"
printf 'OPENROUTER_API_KEY=%s\n' "${OPENROUTER_API_KEY}" >"${secret_env_file}"

kubectl \
  --context "${context}" \
  --namespace "${namespace}" \
  create secret generic "${secret_name}" \
  --from-env-file="${secret_env_file}" \
  --dry-run=client \
  -o yaml |
  kubectl \
    --context "${context}" \
    --namespace "${namespace}" \
    apply -f -

echo "Secret '${secret_name}' is configured in ${context}/${namespace}."

