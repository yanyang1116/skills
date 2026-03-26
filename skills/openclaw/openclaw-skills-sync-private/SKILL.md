---
name: openclaw-skills-sync-private
description: >
  Private skill for Young's personal skills workflow. Use this whenever Young
  asks to install a public skill from a git URL, update installed public
  skills, sync OpenClaw-only skills, reinstall OpenClaw skills, or uses natural
  variants like “安装这个 skill”, “更新一下 skills”, “同步一下 openclaw
  skills”, “把我的 OpenClaw skills 装一下”, or “把那些 skill 重新装一遍”.
  Route the request into one of three flows: public skill install, public skill
  update, or OpenClaw-only skill sync. If the request is ambiguous, ask a short
  clarifying question before acting. Keep the existing hard-coded OpenClaw sync
  flow intact.
---

# OpenClaw Skills Sync Private

Private routing skill for Young's personal skills workflow.

This skill exists because Young handles skills frequently, and those requests
fall into two different classes with different execution models:

- **Public skills**
- **OpenClaw-only skills** written by Young for OpenClaw

The most important job of this skill is **correct routing**. Do not collapse
these into one generic "update skills" action.

## Stable model

Young's skills work splits into two categories:

1. **Public skills**
   - General-purpose skills
   - Supports **install** and **update** as separate operations

2. **OpenClaw-only skills**
   - Young's own skills under the OpenClaw layer
   - For these, there is no meaningful distinction between “install” and
     “update” in normal use
   - The correct behavior is the existing fixed flow: scan the directory and
     add each discovered skill again

## Routing rules

Always classify the user's request into exactly one of these buckets before
executing anything:

### A. Public skill install

Use this flow when Young wants to install a public skill from a specific git
source.

Typical wording:

- “安装这个 skill”
- “装这个公共 skill”
- “把这个 git 地址的 skill 装上”
- “install this skill”
- a message that includes a concrete git URL / repo source for a skill

Run this exact command pattern:

```bash
skills add '<git-url>' -a openclaw -a antigravity -a codex -a claude-code -y -g
```

Rules:

- Use the git URL the user provided or explicitly confirmed
- Keep the install non-interactive with `-y`
- Keep the install global with `-g`
- Install to these agents exactly:
  - `openclaw`
  - `antigravity`
  - `codex`
  - `claude-code`
- Do not silently omit one of the agents
- Do not replace this with project-local install

## B. Public skill update

Use this flow when Young wants to update already installed public skills.

Typical wording:

- “更新一下 skills”
- “更新公共 skills”
- “更新全局 skills”
- “update my skills”
- “把装过的 skills 更新一下”

Run this exact command:

```bash
skills update --yes
```

Rules:

- Treat this as the public-skills update path
- Do not substitute the OpenClaw-only directory sync flow
- Keep it non-interactive with `--yes`

## C. OpenClaw-only skill sync / reinstall

Use this flow when Young is talking about the OpenClaw-only skills that he
maintains personally.

Typical wording:

- “同步一下 openclaw skills”
- “把我的 OpenClaw skills 装一下”
- “重新装一下 openclaw 那些 skill”
- “把那些 openclaw skill 同步一下”
- “安装我的 openclaw 包”

This flow is intentionally **hard-coded** and already considered reliable.
Do not over-optimize it.

Always run the existing process:

1. Scan `/Users/yy/Documents/yy/skills/skills/openclaw`
2. Find each direct child directory that represents a skill
3. Use the directory name as the final path segment in the GitHub URL
4. Reinstall every discovered skill globally with OpenClaw
5. Report which skills were installed and whether any failed

Private fixed parameters:

- Local source directory: `/Users/yy/Documents/yy/skills/skills/openclaw`
- GitHub prefix: `https://github.com/yanyang1116/skills/tree/main/skills/openclaw/`
- Install pattern: `skills add <url> --agent openclaw -g --yes`

Recommended enumeration command:

```bash
find /Users/yy/Documents/yy/skills/skills/openclaw \
  -mindepth 1 -maxdepth 1 -type d \
  -exec basename {} \; | sort
```

Then install each discovered skill using this exact pattern:

```bash
skills add "https://github.com/yanyang1116/skills/tree/main/skills/openclaw/<skill-name>" \
  --agent openclaw -g --yes
```

Rules:

- Keep the existing hard-coded path and parameters
- Install serially, not in a noisy parallel burst
- If one install fails, continue with the rest, then summarize clearly
- Do not generalize this into a multi-agent public install flow
- Do not replace it with `skills update --yes`

## Ambiguity handling

If the user's request is not specific enough, ask a short clarifying question
before acting.

Ambiguous examples:

- “更新一下 skills”
- “装一下 skills”
- “同步一下我的 skills”
- “把 skill 处理一下”

In ambiguous cases, clarify along these lines:

- “你这次是指公共 skills，还是 OpenClaw 那套专属 skills？”
- “如果是公共 skills，是要安装一个具体包，还是更新已安装的全部？”

Keep the clarification short. One question is usually enough.

## Output back to the user

After completion, report the path that was chosen:

- **Public install**: which git URL was installed
- **Public update**: that `skills update --yes` was run
- **OpenClaw-only sync**:
  - source directory scanned
  - discovered skill names
  - which installs succeeded
  - which installs failed, if any
  - that installs were global (`-g`)

## Important boundaries

- Do not merge public install/update logic with the OpenClaw-only sync flow
- Do not “improve” the OpenClaw-only flow unless Young explicitly asks
- Do not silently infer a git URL for public install if none was provided
- Do not assume that “update skills” automatically means OpenClaw-only sync
- When unclear, ask
