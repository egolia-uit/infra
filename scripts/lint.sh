#!/usr/bin/env bash
set -euo pipefail

parent_targets=(
  "kubernetes/app/kevinnitrohomelab/"
  "kubernetes/infra/kevinnitrohomelab/"
)

targets=()
for dir in "${parent_targets[@]}"; do
  for subdir in "$dir"*/; do
    targets+=("$subdir")
  done
done
targets+=("kubernetes/cluster/kevinnitrohomelab/")

KUBECONFORM_ARGS=(
  -schema-location 'https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/{{.Group}}/{{.ResourceKind}}_{{.ResourceAPIVersion}}.json'
  -schema-location default
  -strict
  -summary
)

total_errors=0

for target in "${targets[@]}"; do
  echo "::group::Linting $target"
  output=$(kubectl kustomize "$target" | envsubst | kubeconform "${KUBECONFORM_ARGS[@]}" 2>&1 || true)
  echo "$output"

  error_count=$(echo "$output" | grep "Summary:" | sed -E 's/.*Errors: ([0-9]+).*/\1/' || echo "0")

  if [[ -z "$error_count" ]] || [[ ! "$output" =~ "Summary:" ]]; then
    echo "❌ Critical failure: Could not find summary for $target"
    error_count=1
  fi

  if [ "$error_count" -gt 0 ]; then
    echo "❌ Found $error_count error(s) in $target"
    total_errors=$((total_errors + error_count))
  else
    echo "✅ No errors in $target"
  fi
  echo "::endgroup::"
done

echo '---'
if [ "$total_errors" -gt 0 ]; then
  echo "Final Status: Validation failed with $total_errors total error(s)."
  exit 1
else
  echo 'Final Status: All targets passed!'
  exit 0
fi
