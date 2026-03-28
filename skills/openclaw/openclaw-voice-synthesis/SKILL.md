---
name: openclaw-voice-synthesis
description: Generate local text-to-speech audio on macOS and use it as a reusable voice artifact for chat delivery or downstream workflows. Use this whenever the user asks you to synthesize speech, turn text into a spoken audio file, make a voice sample, test different system voices, preview voice lines, or create short spoken clips such as “给我合成一段语音”, “做个 voice sample”, “把这句话转成语音”, “试几个声线”, “生成一条可发送的语音”, or similar. Prefer this skill when the real output is a local audio file, even if the user does not mention TTS, file formats, or macOS commands explicitly.
---

# OpenClaw Voice Synthesis

Generate a local speech file from text using macOS built-in TTS, with a simple and repeatable workflow.

This skill is for **voice generation itself**.
It does **not** require the audio to be sent into chat, although the generated file can be handed off to a channel-send workflow afterwards.

## What this skill does

Use macOS built-in tools to produce a spoken audio artifact:

- `say` for text-to-speech generation
- `afconvert` for converting the result into a more convenient output format such as `.wav`

This is useful for:

- quick spoken replies
- TTS test clips
- voice/sample comparison
- generating a reusable audio file for later delivery
- validating whether a given system voice is acceptable

## Use this skill when

Trigger this skill when the user wants any of the following:

- synthesize a spoken clip from text
- create a local `.wav` or other audio file from text
- test several macOS system voices
- compare voice options by number or name
- produce a short voice line for later sending
- build a repeatable local TTS workflow

Examples of likely requests:

- “把这句话转成语音”
- “给我合成一条 voice”
- “做几个不同声线让我试听”
- “生成一个 wav 文件”
- “给这段文案做个语音样本”
- “试一下系统自带 voice”

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

## Voice selection

If the user asks to inspect available voices, list them with:

```bash
say -v '?'
```

Important practical note:

- macOS exposes many entries, but many are language-region variants rather than truly distinct voice designs
- do not imply that all listed entries are equally suitable for Chinese or for a “professional bot” style
- if the user wants to compare voices, generate short samples using the **same text** and label them clearly by order or name

## Sample-comparison workflow

When the user wants to audition voices:

1. Choose a small batch first, not dozens
2. Use the same short text for all samples
3. Name files in a stable numbered format such as:
   - `01_name.wav`
   - `02_name.wav`
   - `03_name.wav`
4. Keep each sample short for faster comparison
5. Ask the user to respond by number

This is better than asking the user to remember voice names.

## Language guidance

Match the test text to the user's actual use case.

- If the user wants Chinese voice output, test with Chinese text
- If the user wants English output, test with English text
- If the user wants mixed-language output, test with mixed-language text

Do not assume an English-oriented voice will sound acceptable when forced to speak Chinese.

## File naming and location

Prefer a predictable temporary or workspace-local path such as:

- `/tmp/openclaw-voice/`
- `/Users/yy/.openclaw/workspace/tmp/voice/`

When generating multiple samples, create a dedicated subdirectory:

- `/Users/yy/.openclaw/workspace/tmp/voice/samples/`

Always return absolute paths.

## Reporting back

When you finish, report concrete facts only:

- output path
- output format
- whether conversion succeeded
- optional file size if relevant

Good:

- “Generated `/absolute/path/sample.wav` successfully.”
- “Created 5 numbered voice samples in `/absolute/path/samples/`.”

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
