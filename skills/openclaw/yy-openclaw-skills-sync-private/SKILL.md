---
name: yy-openclaw-skills-sync-private
description: Private skill for Young's OpenClaw setup. Use when the user says 更新 skill, 同步 skill, 安装 skill, reinstall skills, or asks to sync/install all OpenClaw skills from Young's personal local source tree. This skill is intentionally hard-coded for Young's machine and should not be reused as a general-purpose installer.
---

# YY OpenClaw Skills Sync Private

Private utility skill for Young's personal machine.

This skill exists to resync all OpenClaw skills from Young's personal source repo into OpenClaw's global skills directory.

## Private scope

This skill is intentionally hard-coded to Young's local setup:

- Local source directory: `/Users/yy/Documents/yy/skills/skills/openclaw`
- GitHub prefix: `https://github.com/yanyang1116/skills/tree/main/skills/openclaw/`
- Install pattern: `skills add <url> --agent openclaw -g --yes`

Do not generalize these paths unless the user explicitly asks.

## When to use

Use this skill whenever Young says things like:

- “更新 skill”
- “同步 skill”
- “安装 skill”
- “把我的 OpenClaw skills 装一下”
- “重新安装一下那些 skill”
- “sync my OpenClaw skills”
- “reinstall all my OpenClaw skills”

Treat these phrases as the same request:

> rescan Young's personal OpenClaw skill source directory and reinstall all discovered skills globally.

## Core behavior

Always run the same flow:

1. Scan `/Users/yy/Documents/yy/skills/skills/openclaw`
2. Find each direct child directory that represents a skill
3. Use the directory name as the final path segment in the GitHub URL
4. Reinstall every discovered skill globally with OpenClaw
5. Report which skills were installed and whether any failed

## Important assumptions

- This skill is for **all skills in the directory**, not a named subset
- “更新” means **reinstall all skills globally again**
- The remote GitHub path matches the local directory name
- The install target is global OpenClaw skills, not project-local skills

## Recommended command pattern

First enumerate the local skill directories:

```bash
find /Users/yy/Documents/yy/skills/skills/openclaw \
  -mindepth 1 -maxdepth 1 -type d \
  -exec basename {} \; | sort
```

Then install each one using this exact pattern:

```bash
skills add "https://github.com/yanyang1116/skills/tree/main/skills/openclaw/<skill-name>" \
  --agent openclaw -g --yes
```

## Execution guidance

- Prefer one brief preamble, then do the work
- Validate the discovered directory names before installing if the listing looks suspicious
- Install serially, not in a noisy parallel burst
- If one install fails, continue with the rest, then summarize failures clearly
- Do not silently switch to project-level install
- If the user's typed command contains a long dash like `—agent`, normalize it to `--agent`

## Output back to the user

After completion, report:

- the source directory scanned
- the discovered skill names
- which installs succeeded
- which installs failed, if any
- that the installs were global (`-g`)

## Safety / expectation note

This is a private convenience skill for Young's machine. If another user encounters this skill, they should not assume the hard-coded paths apply to them.
