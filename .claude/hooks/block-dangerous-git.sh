#!/bin/bash
# Bloqueia comandos git destrutivos antes de o Claude executá-los.
# Usa Python para ler o JSON (jq não está instalado nesta máquina).

INPUT=$(cat)
COMMAND=$(printf '%s' "$INPUT" | python -c "import sys, json; print(json.load(sys.stdin).get('tool_input', {}).get('command', ''))")

if [ $? -ne 0 ]; then
  echo "BLOCKED: não foi possível ler o comando para checar os guardrails de git." >&2
  exit 2
fi

DANGEROUS_PATTERNS=(
  "git push"
  "git reset --hard"
  "git clean -fd"
  "git clean -f"
  "git branch -D"
  "git checkout \."
  "git restore \."
  "push --force"
  "reset --hard"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if printf '%s' "$COMMAND" | grep -qE "$pattern"; then
    echo "BLOCKED: '$COMMAND' matches dangerous pattern '$pattern'. The user has prevented you from doing this." >&2
    exit 2
  fi
done

exit 0
