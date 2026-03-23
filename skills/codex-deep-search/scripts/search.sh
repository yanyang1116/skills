#!/usr/bin/env bash
# Deep search via Codex CLI with dispatch pattern (background + Telegram callback)
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

RESULT_DIR="${RESULT_DIR:-${SKILL_DIR}/data/codex-search-results}"
OPENCLAW_BIN="${OPENCLAW_BIN:-$(command -v openclaw || true)}"
CODEX_BIN="${CODEX_BIN:-$(command -v codex || true)}"
TIMEOUT_BIN="${TIMEOUT_BIN:-$(command -v timeout || command -v gtimeout || true)}"
OPENCLAW_CONFIG="${OPENCLAW_CONFIG:-$HOME/.openclaw/openclaw.json}"

iso_now() {
  if date -Iseconds >/dev/null 2>&1; then
    date -Iseconds
  else
    date +"%Y-%m-%dT%H:%M:%S%z"
  fi
}

# Defaults
PROMPT=""
OUTPUT=""
MODEL="gpt-5.3-codex"
SANDBOX="workspace-write"
TIMEOUT=120
TELEGRAM_GROUP=""
TASK_NAME="search-$(date +%s)"
START_EPOCH="$(date +%s)"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prompt) PROMPT="$2"; shift 2;;
    --output) OUTPUT="$2"; shift 2;;
    --model) MODEL="$2"; shift 2;;
    --timeout) TIMEOUT="$2"; shift 2;;
    --telegram-group) TELEGRAM_GROUP="$2"; shift 2;;
    --task-name) TASK_NAME="$2"; shift 2;;
    *) echo "Unknown flag: $1"; exit 1;;
  esac
done

if [[ -z "$PROMPT" ]]; then
  echo "ERROR: --prompt is required"
  exit 1
fi

if [[ -z "$CODEX_BIN" ]]; then
  echo "ERROR: codex binary not found in PATH. Install codex or set CODEX_BIN."
  exit 1
fi

# Default output path
if [[ -z "$OUTPUT" ]]; then
  OUTPUT="${RESULT_DIR}/${TASK_NAME}.md"
fi

mkdir -p "$RESULT_DIR"

# Write task metadata
STARTED_AT="$(iso_now)"
jq -n \
  --arg name "$TASK_NAME" \
  --arg prompt "$PROMPT" \
  --arg output "$OUTPUT" \
  --arg ts "$STARTED_AT" \
  '{task_name: $name, prompt: $prompt, output: $output, started_at: $ts, status: "running"}' \
  > "${RESULT_DIR}/latest-meta.json"

SEARCH_INSTRUCTION="You are a research assistant. Search the web for the following query.

CRITICAL RULES:
1. Write findings to $OUTPUT INCREMENTALLY — after EACH search, append what you found immediately. Do NOT wait until the end.
2. Start the file with a title and query, then append sections as you discover them.
3. Keep searches focused — max 8 web searches. Synthesize what you have, don't over-research.
4. Include source URLs inline.
5. End with a brief summary section.

Query: $PROMPT

Start by writing the file header NOW, then search and append."

echo "[codex-deep-search] Task: $TASK_NAME"
echo "[codex-deep-search] Output: $OUTPUT"
echo "[codex-deep-search] Model: $MODEL | Reasoning: low | Timeout: ${TIMEOUT}s"

# Pre-create output file
cat > "$OUTPUT" <<EOF
# Deep Search Report
**Query:** $PROMPT
**Status:** In progress...
---
EOF

# Run Codex with timeout when available.
if [[ -n "$TIMEOUT_BIN" ]]; then
  "$TIMEOUT_BIN" "${TIMEOUT}" "$CODEX_BIN" exec \
    --model "$MODEL" \
    --full-auto \
    --sandbox "$SANDBOX" \
    -c 'model_reasoning_effort="low"' \
    "$SEARCH_INSTRUCTION" 2>&1 | tee "${RESULT_DIR}/task-output.txt"
  EXIT_CODE=${PIPESTATUS[0]}
else
  echo "[codex-deep-search] timeout/gtimeout not found, running without enforced timeout"
  "$CODEX_BIN" exec \
    --model "$MODEL" \
    --full-auto \
    --sandbox "$SANDBOX" \
    -c 'model_reasoning_effort="low"' \
    "$SEARCH_INSTRUCTION" 2>&1 | tee "${RESULT_DIR}/task-output.txt"
  EXIT_CODE=${PIPESTATUS[0]}
fi

# Append completion marker
if [[ -f "$OUTPUT" ]]; then
  echo -e "\n---\n_Search completed at $(date -u)_" >> "$OUTPUT"
fi

LINES=$(wc -l < "$OUTPUT" 2>/dev/null || echo 0)
COMPLETED_AT="$(iso_now)"

# Calculate duration
END_TS=$(date +%s)
ELAPSED=$(( END_TS - START_EPOCH ))
MINS=$(( ELAPSED / 60 ))
SECS=$(( ELAPSED % 60 ))
DURATION="${MINS}m${SECS}s"

# Update metadata
jq -n \
  --arg name "$TASK_NAME" \
  --arg prompt "$PROMPT" \
  --arg output "$OUTPUT" \
  --arg started "$STARTED_AT" \
  --arg completed "$COMPLETED_AT" \
  --arg duration "$DURATION" \
  --arg lines "$LINES" \
  --argjson exit_code "$EXIT_CODE" \
  '{task_name: $name, prompt: $prompt, output: $output, started_at: $started, completed_at: $completed, duration: $duration, lines: ($lines|tonumber), exit_code: $exit_code, status: (if $exit_code == 0 then "done" elif $exit_code == 124 then "timeout" else "failed" end)}' \
  > "${RESULT_DIR}/latest-meta.json"

echo "[codex-deep-search] Done (${DURATION}, exit=${EXIT_CODE}, ${LINES} lines)"

# Send Telegram notification if configured
if [[ -n "$TELEGRAM_GROUP" ]] && [[ -x "$OPENCLAW_BIN" ]]; then
  STATUS_EMOJI="✅"
  [[ "$EXIT_CODE" == "124" ]] && STATUS_EMOJI="⏱"
  [[ "$EXIT_CODE" != "0" ]] && [[ "$EXIT_CODE" != "124" ]] && STATUS_EMOJI="❌"

  # Extract summary (first 800 chars of result file, skip header)
  SUMMARY=$(sed -n '5,30p' "$OUTPUT" 2>/dev/null | head -c 800 || echo "No results")

  MSG="${STATUS_EMOJI} *Deep Search 完成*

🔍 *查询:* ${PROMPT}
⏱ *耗时:* ${DURATION} | 📄 ${LINES} 行
📂 \`${OUTPUT}\`

📝 *摘要:*
${SUMMARY}"

  "$OPENCLAW_BIN" message send \
    --channel telegram \
    --target "$TELEGRAM_GROUP" \
    --message "$MSG" 2>/dev/null || echo "[codex-deep-search] Telegram notification failed"
fi

# ---- Wake AGI via /hooks/wake ----
GATEWAY_PORT="${OPENCLAW_GATEWAY_PORT:-18789}"
HOOK_TOKEN=""
if [[ -f "$OPENCLAW_CONFIG" ]]; then
  HOOK_TOKEN=$(jq -r '.hooks.token // ""' "$OPENCLAW_CONFIG" 2>/dev/null || echo "")
fi

if [[ -n "$HOOK_TOKEN" ]]; then
  WAKE_TEXT="[DEEP_SEARCH_DONE] task=${TASK_NAME} output=${OUTPUT} lines=${LINES} duration=${DURATION} status=$(jq -r '.status' "${RESULT_DIR}/latest-meta.json" 2>/dev/null)"
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST \
    "http://localhost:${GATEWAY_PORT}/hooks/wake" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${HOOK_TOKEN}" \
    -d "{\"text\":\"${WAKE_TEXT}\",\"mode\":\"now\"}" 2>/dev/null)
  echo "[codex-deep-search] Wake sent (HTTP ${HTTP_CODE})"
else
  echo "[codex-deep-search] No hook token, skipping wake"
fi
