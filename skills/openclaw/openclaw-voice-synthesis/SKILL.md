---
name: openclaw-voice-synthesis
description: Generate local text-to-speech audio on macOS and save it as a reusable spoken audio file, typically `.wav`. Use this whenever the user asks you to synthesize speech, turn text into audio, make a spoken clip, or create a local voice file such as “把这句话转成语音”, “给我合成一段语音”, “生成一个 wav 文件”, or similar. Prefer this skill when the real output is a local audio artifact, even if the user does not mention TTS, file formats, or macOS commands explicitly.
---

# OpenClaw Voice Synthesis

Generate a local speech file from text using macOS built-in TTS, with a simple and repeatable workflow.

This skill is for **voice generation itself**.
It does **not** require the audio to be sent into chat, although the generated file can be handed off to a channel-send workflow afterwards.

## What this skill does

Use macOS built-in tools to produce a spoken audio artifact:

- `say` for text-to-speech generation
- `afconvert` for converting the result into a more convenient output format such as `.wav`

This skill is for:

- turning text into speech
- generating a reusable local audio file
- preparing a voice file for later delivery or reuse

## Use this skill when

Trigger this skill when the user wants any of the following:

- synthesize a spoken clip from text
- create a local `.wav` or other audio file from text
- produce a short voice line for later sending
- build a repeatable local TTS workflow

Examples of likely requests:

- “把这句话转成语音”
- “给我合成一段语音”
- “生成一个 wav 文件”
- “给这段文案做个语音文件”

## Core workflow

Default workflow:

1. Create a temporary working directory if needed
2. Run `say` to synthesize speech into an `.aiff` file
3. Run `afconvert` to convert that `.aiff` into the desired deliverable format, usually `.wav`
4. Verify the output file exists and has non-zero size
5. Return the concrete output path

Recommended pattern:

```bash
mkdir -p /tmp/openclaw-voice
say -o /tmp/openclaw-voice/out.aiff "Your text here"
afconvert -f WAVE -d LEI16@22050 /tmp/openclaw-voice/out.aiff /tmp/openclaw-voice/out.wav
```

## Default output format

Prefer `.wav` unless the user asks for something else.

Why:

- broadly compatible
- easy to inspect
- worked well in current OpenClaw QQ voice-send testing

If the user needs another format, say so clearly and convert accordingly.

## File naming and location

Prefer a predictable temporary or workspace-local path such as:

- `/tmp/openclaw-voice/`
- `/Users/yy/.openclaw/workspace/tmp/voice/`

Always return absolute paths.

## Reporting back

When you finish, report concrete facts only:

- output path
- output format
- whether conversion succeeded
- optional file size if relevant

Good:

- “Generated `/absolute/path/sample.wav` successfully.”

Avoid vague progress language if no output file exists yet.

## Failure handling

If synthesis fails:

1. Say whether `say` succeeded or failed
2. Say whether `afconvert` succeeded or failed
3. State whether any partial output file exists
4. Do not claim the voice clip is ready unless a real output file was produced

## Boundaries

This skill is about **local audio generation**.

If the user wants the audio to actually arrive in chat:

- first generate the file with this skill
- then use the appropriate channel-send/media-send workflow for delivery

Keep the distinction clear:

- **this skill** = make the audio file
- **channel/media skill** = deliver the file into the conversation

## Do not

- Do not claim you used a third-party TTS engine if you only used macOS built-in tools
- Do not describe the output as “custom cloned voice” unless a real cloning system is actually involved
- Do not overpromise on voice quality; macOS system voices have real quality limits
- Do not confuse file generation with successful chat delivery
