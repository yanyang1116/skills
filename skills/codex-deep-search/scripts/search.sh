#!/usr/bin/env bash
# Deep search via Codex CLI in synchronous mode.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
RESULT_DIR="${SKILL_DIR}/data/codex-search-results"

PROMPT=""
OUTPUT=""
MODEL="gpt-5.3-codex"
SANDBOX="workspace-write"
TIMEOUT=1200
TASK_NAME="search-$(date +%s)"
TEMP_WORKSPACE=""

resolve_codex_bin() {
  local candidate=""
  local node_bin=""
  local npm_root=""
  local npm_bin=""
  local nvm_candidate=""

  if [[ -n "${CODEX_BIN:-}" ]] && [[ -x "${CODEX_BIN}" ]]; then
    printf '%s\n' "${CODEX_BIN}"
    return 0
  fi

  if candidate="$(command -v codex 2>/dev/null)"; then
    printf '%s\n' "${candidate}"
    return 0
  fi

  if node_bin="$(command -v node 2>/dev/null)"; then
    candidate="$(dirname "${node_bin}")/codex"
    if [[ -x "${candidate}" ]]; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  fi

  if npm_root="$(npm root -g 2>/dev/null)"; then
    npm_bin="$(cd "${npm_root}/.." 2>/dev/null && pwd)/bin/codex"
    if [[ -x "${npm_bin}" ]]; then
      printf '%s\n' "${npm_bin}"
      return 0
    fi
  fi

  if [[ -n "${NVM_DIR:-}" ]] && node_bin="$(command -v node 2>/dev/null)"; then
    nvm_candidate="${NVM_DIR}/versions/node/$(node -v)/bin/codex"
    if [[ -x "${nvm_candidate}" ]]; then
      printf '%s\n' "${nvm_candidate}"
      return 0
    fi
  fi

  return 1
}

run_with_timeout() {
  local seconds="$1"
  shift

  if command -v timeout >/dev/null 2>&1; then
    timeout "${seconds}" "$@"
    return $?
  fi

  if command -v gtimeout >/dev/null 2>&1; then
    gtimeout "${seconds}" "$@"
    return $?
  fi

  if command -v python3 >/dev/null 2>&1; then
    python3 - "${seconds}" "$@" <<'PY'
import os
import signal
import subprocess
import sys

timeout_seconds = int(sys.argv[1])
cmd = sys.argv[2:]

proc = subprocess.Popen(cmd)
try:
    proc.wait(timeout=timeout_seconds)
    sys.exit(proc.returncode)
except subprocess.TimeoutExpired:
    proc.send_signal(signal.SIGTERM)
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait()
    sys.exit(124)
PY
    return $?
  fi

  echo "ERROR: timeout requested but no timeout runner is available" >&2
  return 1
}

create_temp_workspace() {
  local base_tmp="${TMPDIR:-/tmp}"
  mktemp -d "${base_tmp%/}/codex-deep-search.XXXXXX"
}

cleanup() {
  if [[ -n "${TEMP_WORKSPACE}" ]] && [[ -d "${TEMP_WORKSPACE}" ]]; then
    rm -rf "${TEMP_WORKSPACE}"
  fi
}

format_duration() {
  local elapsed="$1"
  local mins=$(( elapsed / 60 ))
  local secs=$(( elapsed % 60 ))
  printf '%sm%ss\n' "${mins}" "${secs}"
}

status_from_exit() {
  local exit_code="$1"
  if [[ "${exit_code}" == "0" ]]; then
    printf 'done\n'
  elif [[ "${exit_code}" == "124" ]]; then
    printf 'timeout\n'
  else
    printf 'failed\n'
  fi
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="$2"; shift 2;;
    --output) OUTPUT="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --timeout) TIMEOUT="$2"; shift 2;;
    --task-name) TASK_NAME="$2"; shift 2;;
    *) echo "Unknown flag: $1"; exit 1;;
  esac
done

if [[ -z "${PROMPT}" ]]; then
  echo "ERROR: --prompt is required"
  exit 1
fi

if [[ -z "${OUTPUT}" ]]; then
  OUTPUT="${RESULT_DIR}/${TASK_NAME}.md"
fi

OUTPUT_DIR="$(dirname "${OUTPUT}")"
mkdir -p "${RESULT_DIR}" "${OUTPUT_DIR}"

if ! CODEX_BIN_RESOLVED="$(resolve_codex_bin)"; then
  echo "FALLBACK_TO_DEFAULT_SEARCH: codex_unavailable"
  echo "[codex-deep-search] Codex CLI not found. Fall back to default search."
  exit 69
fi

TEMP_WORKSPACE="$(create_temp_workspace)"
trap cleanup EXIT

START_TS="$(date +%s)"
STARTED_AT="$(date -Iseconds)"

jq -n \
  --arg name "${TASK_NAME}" \
  --arg prompt "${PROMPT}" \
  --arg output "${OUTPUT}" \
  --arg ts "${STARTED_AT}" \
  --arg codex_bin "${CODEX_BIN_RESOLVED}" \
  --arg workspace_dir "${TEMP_WORKSPACE}" \
  '{task_name: $name, prompt: $prompt, output: $output, started_at: $ts, codex_bin: $codex_bin, workspace_dir: $workspace_dir, status: "running"}' \
  > "${RESULT_DIR}/latest-meta.json"

SEARCH_INSTRUCTION="You are a research assistant. Search the web for the following query.

CRITICAL RULES:
1. Do NOT read unrelated local workspace files or project instruction files unless the user explicitly asks for them.
2. Write findings to ${OUTPUT} INCREMENTALLY — after EACH search, append what you found immediately. Do NOT wait until the end.
3. Start the file with a title and query, then append sections as you discover them.
4. Keep searches focused — max 8 web searches. Synthesize what you have, don't over-research.
5. Include source URLs inline.
6. End with a brief summary section.

Query: ${PROMPT}

Start by writing the file header NOW, then search and append."

echo "[codex-deep-search] Task: ${TASK_NAME}"
echo "[codex-deep-search] Output: ${OUTPUT}"
echo "[codex-deep-search] Workspace: ${TEMP_WORKSPACE}"
echo "[codex-deep-search] Codex: ${CODEX_BIN_RESOLVED}"
echo "[codex-deep-search] Model: ${MODEL} | Reasoning: low | Timeout: ${TIMEOUT}s"

cat > "${OUTPUT}" <<EOF
# Deep Search Report
**Query:** ${PROMPT}
**Status:** In progress...
---
EOF

set +e
run_with_timeout "${TIMEOUT}" \
  "${CODEX_BIN_RESOLVED}" \
  -C "${TEMP_WORKSPACE}" \
  --search \
  exec \
  --skip-git-repo-check \
  --model "${MODEL}" \
  --full-auto \
  --sandbox "${SANDBOX}" \
  --add-dir "${OUTPUT_DIR}" \
  -c 'model_reasoning_effort="low"' \
  "${SEARCH_INSTRUCTION}"
EXIT_CODE=$?
set -e

if [[ -f "${OUTPUT}" ]]; then
  echo -e "\n---\n_Search completed at $(date -u)_" >> "${OUTPUT}"
fi

LINES=$(wc -l < "${OUTPUT}" 2>/dev/null || echo 0)
END_TS="$(date +%s)"
COMPLETED_AT="$(date -Iseconds)"
ELAPSED=$(( END_TS - START_TS ))
DURATION="$(format_duration "${ELAPSED}")"
STATUS="$(status_from_exit "${EXIT_CODE}")"

jq -n \
  --arg name "${TASK_NAME}" \
  --arg prompt "${PROMPT}" \
  --arg output "${OUTPUT}" \
  --arg started "${STARTED_AT}" \
  --arg completed "${COMPLETED_AT}" \
  --arg duration "${DURATION}" \
  --arg lines "${LINES}" \
  --arg codex_bin "${CODEX_BIN_RESOLVED}" \
  --arg workspace_dir "${TEMP_WORKSPACE}" \
  --argjson exit_code "${EXIT_CODE}" \
  --arg status "${STATUS}" \
  '{task_name: $name, prompt: $prompt, output: $output, started_at: $started, completed_at: $completed, duration: $duration, lines: ($lines|tonumber), exit_code: $exit_code, codex_bin: $codex_bin, workspace_dir: $workspace_dir, status: $status}' \
  > "${RESULT_DIR}/latest-meta.json"

echo "[codex-deep-search] Done (${DURATION}, exit=${EXIT_CODE}, ${LINES} lines)"
echo "[codex-deep-search] Result file: ${OUTPUT}"

exit "${EXIT_CODE}"
