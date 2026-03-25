---
name: channel-screenshot-send
description: Capture a fresh screenshot and send it into the current chat using OpenClaw's official media send API for the active channel. Use this whenever the user asks to screenshot the screen and send it, capture then send, send the current screen, or wants a screenshot delivered into chat instead of attached to the model reply. Do not use read-image reply attachments for this workflow.
---

# Channel Screenshot Send

Capture a screenshot, save it briefly to a temporary local file, send it through OpenClaw's official outbound media path for the current channel, then delete the temporary file.

This skill exists because **reply attachments are not the same as channel outbound media**. Reading an image file into the current reply may let the model see it, but it does not reliably deliver the image into the user's actual chat.

## Use this skill when

- The user says things like “截个图发我”, “把屏幕发我”, “screenshot and send”, or “capture the screen and send it”.
- The user wants the screenshot to appear in the current conversation itself.
- You need the most reliable path for sending screenshots into chat.

## Core rule

Always use this flow:

1. Capture screenshot to a **temporary file**
2. Send with `openclaw message send --channel <current-channel> --media <temp-file>`
3. Delete the temporary file after send completes

Do **not** use this flow:

- `read <image>` and then attach it to the reply

That path is for model-visible attachments, not reliable chat delivery.

## Required inputs

Before sending, confirm or infer these values from the current conversation context:

- **Current channel**
- **Current target ID** for that channel
- **Capture scope**: default to full-screen unless the user asked for a window/selection

## Recommended command pattern

Use the platform's screenshot tool to write to `/tmp`, then send via OpenClaw official media send.

```bash
TMP_IMG="/tmp/openclaw-channel-shot-$(date +%s).png"
cleanup() { rm -f "$TMP_IMG"; }
trap cleanup EXIT

/usr/sbin/screencapture -x "$TMP_IMG"
openclaw message send \
  --channel '<current-channel>' \
  --target '<current-target>' \
  --media "$TMP_IMG" \
  --message 'screenshot'
```

If the current host is not macOS, use the appropriate screenshot utility for that system.

## Behavior notes

- A screenshot sent successfully from `/tmp` still counts as **temporary disk write**. It is not truly zero-disk.
- If the user wants “do not save”, explain the practical truth: the official media API needs a file path, so the closest workable method is **temporary file -> send -> delete**.
- The key distinction is **send method**, not whether the image is temporary or permanent.

## Reporting back to the user

After sending, briefly report:

- that you used the official OpenClaw media send path
- whether the command succeeded
- the returned message ID if available
- that the temporary file was deleted

## Failure handling

If the send fails:

1. Keep the explanation short and concrete
2. Mention whether capture succeeded
3. Mention whether cleanup succeeded
4. Avoid claiming the user received anything unless the command actually returned success

## Do not

- Do not claim that reading an image into the current reply means the user received it in chat
- Do not leave temp screenshot files around unless the user explicitly wants them preserved for debugging
- Do not overcomplicate the workflow with unnecessary file copies unless debugging requires it
