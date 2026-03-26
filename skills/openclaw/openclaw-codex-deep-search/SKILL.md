---
name: openclaw-codex-deep-search
description: Deep web search using Codex CLI for complex queries that need multi-source synthesis. Use when web_search (Brave) returns insufficient results, when the user asks for in-depth research, comprehensive analysis, or says "deep search", "详细搜索", "帮我查一下", or when a topic needs following multiple links and cross-referencing sources.
---

# Codex Deep Search

Use Codex CLI's web search capability for research tasks needing more depth than Brave API snippets.

## When to Prefer Over web_search

- Complex/niche topics needing multi-source synthesis
- User explicitly asks for thorough/deep research
- Brave results are too shallow or missing context

## Usage

This skill is synchronous only. Call the script, wait for it to finish, then read the output file and summarize the result back to the user.

```bash
bash /path/to/codex-deep-search/scripts/search.sh \
  --prompt "Deep research query" \
  --output "/tmp/search-result.md" \
  --task-name "topic-research" \
  --timeout 1200
```

The script prints progress to stdout and writes the final report to the output file.

## Fallback

If the script cannot find a usable `codex` binary, it will:

- print `FALLBACK_TO_DEFAULT_SEARCH: codex_unavailable`
- exit with code `69`

When that happens, the main agent should tell the user Codex deep search is unavailable on this machine and fall back to the default web search flow instead of retrying this skill.

## Parameters

| Flag | Required | Default | Description |
|------|----------|---------|-------------|
| `--prompt` | Yes | — | Research query |
| `--output` | No | `data/codex-search-results/<task>.md` | Output file path |
| `--task-name` | No | `search-<timestamp>` | Task identifier used for the default output file name |
| `--model` | No | `gpt-5.3-codex` | Model override |
| `--timeout` | No | `1200` | Seconds before auto-stop |

## Result Files

| File | Content |
|------|---------|
| `data/codex-search-results/<task>.md` | Search report (incremental + final summary) |
| `data/codex-search-results/latest-meta.json` | Task metadata, status, duration, output path, resolved codex path, and workspace dir |

## Key Design

- **Synchronous execution** — caller waits for completion and then reads the result file
- **Workspace isolation** — each run starts Codex in a clean temporary workspace and only exposes the output directory
- **Incremental writes** — results are written while the search is running
- **Low reasoning effort** — reduces memory pressure during long searches
- **Portable timeout** — uses available timeout tooling on Linux/macOS
- **Explicit fallback** — missing Codex binary returns a machine-readable fallback signal
