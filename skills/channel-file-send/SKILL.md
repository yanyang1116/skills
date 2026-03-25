---
name: channel-file-send
description: Send an existing local file to the current chat using OpenClaw's official media send API for the active channel. Use this whenever the user asks to send a file, deliver a local document, forward a local image, or upload any existing file into the conversation. Do not use reply attachments or read-file attachments for this workflow.
---

# Channel File Send

Send an existing local file into the current chat through OpenClaw's official outbound media send path.

This skill is for files that already exist, such as:

- images
- `package.json`
- markdown files
- text files
- project artifacts
- documents the user points to by path or location

## Use this skill when

- The user says “把这个文件发给我”, “send this file”, “把桌面那个图发我”, “把 package.json 发给我”, or similar.
- The file already exists locally.
- The user wants the file to appear in the current chat itself.

## Core rule

Always use OpenClaw's official media send command:

```bash
openclaw message send \
  --channel '<current-channel>' \
  --target '<current-target>' \
  --media '<local-file-path>' \
  --message '<optional short caption>'
```

Do **not** use:

- `read <file>` and attach it to the current reply
- model-visible attachments as a substitute for actual channel delivery

Those may attach content to the assistant turn, but they are not the reliable path for actual file delivery into chat.

## What this skill is for

Use this skill for **existing files**.

Examples:

- send a Desktop screenshot file
- send a file from `Documents`
- send a project `package.json`
- send a generated report from the workspace

If the user asks you to **first create or capture** a file, do that upstream, then call this skill once you have a concrete file path.

## Inputs to confirm or infer

Before sending, confirm or infer:

- the current channel
- the current target ID for that channel
- the file path to send
- whether a short caption is useful

If the user refers vaguely to “that file”, resolve the path first instead of guessing.

## Proven behavior pattern

The key practical conclusion is:

> the main constraint is **send method**, not ordinary local path location.

So prefer the official `openclaw message send ... --media` route over reply attachments.

## Workflow

1. Resolve the exact local file path
2. Verify the file exists if needed
3. Send it via `openclaw message send --channel <current-channel> --media <path>`
4. Report success or failure briefly

## Example command pattern

```bash
openclaw message send \
  --channel '<current-channel>' \
  --target '<current-target>' \
  --media '/absolute/path/to/file' \
  --message 'optional caption'
```

## Reporting back to the user

After sending, briefly say:

- what file you sent
- that you used the official OpenClaw media send path
- whether the command succeeded
- the returned message ID if available

## Failure handling

If sending fails:

1. Say exactly which path you attempted
2. Say whether the file existed
3. Include the relevant command error briefly
4. Do not imply the user received the file unless the command returned success

## Do not

- Do not use `read` attachment flow as a substitute for actual chat send
- Do not claim that a model-visible attachment means the file arrived in chat
- Do not move or copy the file unless there is a specific reason to do so
- Do not overfit the skill to a single channel if the same official media-send pattern applies elsewhere
