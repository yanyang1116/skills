---
name: weixin-screenshot-send
description: Send a freshly captured screenshot to the current Weixin chat using OpenClaw's official media send API. Use this whenever the user asks to screenshot the screen and send it to Weixin, send the current screen, capture then send, or wants a screenshot delivered into chat instead of attached to the model reply. Do not use read-image reply attachments for this workflow.
---

# Weixin Screenshot Send

Capture a screenshot, save it briefly to a temporary local file, send it through OpenClaw's official Weixin media path, then delete the temporary file.

This skill exists because **reply attachments are not the same as Weixin outbound media**. Reading an image file into the current reply may let the model see it, but it does not reliably deliver the image into the user's Weixin chat.

## Use this skill when

- The user says things like “截个图发我”, “把屏幕发到微信”, “screenshot and send”, or “capture the screen and send it”.
- The user wants the screenshot to appear in the Weixin conversation.
- You need the most reliable path for sending screenshots to Weixin.

## Core rule

Always use this flow:

1. Capture screenshot to a **temporary file**
2. Send with `openclaw message send --channel openclaw-weixin --media <temp-file>`
3. Delete the temporary file after send completes

Do **not** use this flow:

- `read <image>` and then attach it to the reply

That path is for model-visible attachments, not reliable Weixin media delivery.

## Required inputs

Before sending, confirm or infer these values from the current conversation context:

- **Current Weixin target ID**: the current chat's `<...@im.wechat>` address
- **Account ID**: normally the current connected OpenClaw Weixin account
- **Capture scope**: default to full-screen unless the user asked for a window/selection

## Recommended command

Use `/usr/sbin/screencapture` on macOS and write to `/tmp`.

```bash
TMP_IMG="/tmp/openclaw-weixin-shot-$(date +%s).png" && \
/usr/sbin/screencapture -x "$TMP_IMG" && \
openclaw message send \
  --channel openclaw-weixin \
  --target '<current_user_id@im.wechat>' \
  --media "$TMP_IMG" \
  --message 'screenshot' && \
rm -f "$TMP_IMG"
```

## Safer cleanup pattern

Prefer cleanup even if send fails. If you need a more robust shell form, use:

```bash
TMP_IMG="/tmp/openclaw-weixin-shot-$(date +%s).png"
cleanup() { rm -f "$TMP_IMG"; }
trap cleanup EXIT
/usr/sbin/screencapture -x "$TMP_IMG"
openclaw message send \
  --channel openclaw-weixin \
  --target '<current_user_id@im.wechat>' \
  --media "$TMP_IMG" \
  --message 'screenshot'
```

## Behavior notes

- A screenshot sent successfully from `/tmp` still counts as **temporary disk write**. It is not truly zero-disk.
- Desktop, workspace, and Documents paths can also work, but `/tmp` is preferred for transient screenshots.
- If the user wants “do not save”, explain the practical truth: the official media API needs a file path, so the closest workable method is **temporary file -> send -> delete**.

## Reporting back to the user

After sending, briefly report:

- that you used the official Weixin media send path
- whether the command succeeded
- the returned message ID if available
- that the temporary file was deleted

Example:

- Sent via official OpenClaw Weixin media API
- Message ID: `openclaw-weixin:...`
- Temp screenshot deleted

## Failure handling

If the send fails:

1. Keep the explanation short and concrete
2. Mention whether capture succeeded
3. Mention whether cleanup succeeded
4. Avoid claiming the user received anything unless the command actually returned success

## Do not

- Do not claim that reading an image into the current reply means the user received it in Weixin
- Do not leave temp screenshot files around unless the user explicitly wants them preserved for debugging
- Do not overcomplicate the workflow with workspace copies unless debugging requires it
