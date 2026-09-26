# NChat 2.0

Native SwiftUI AI workspace for NVIDIA NIM on iPhone.

## Core experience
- NVIDIA API key stored in iOS Keychain
- NVIDIA catalog discovery and validation once per app launch
- Manual full-catalog retest after key changes or on demand
- Only models that pass NChat's chat-quality probe appear in chat/model pickers
- Streaming responses with Stop and Regenerate
- Built-in Arabic, RTL, Unicode and same-language response policy
- Raw internal reasoning is never rendered in chat
- Final-response quality guard rejects corrupted Unicode and clear language-policy failures
- Local-first SwiftData conversations with search, pin, rename, delete and Markdown export
- Image attachments for Vision-capable model families and UTF-8 text/JSON/CSV attachments
- Responsible model plus configurable specialist agents
- Agent failure never blocks the main model response
- Markdown, selectable text and copyable LTR code blocks
- Context budgeting and generation controls
- Original dark violet NChat visual system

## Model verification
A model is listed as verified only after it successfully completes NChat's text/streaming Arabic + Latin quality probe.

Text, streaming and Arabic compatibility are directly exercised by the probe. Capability badges marked with * (Vision, Reasoning, Tools) are currently inferred from model-family metadata/name patterns and are intentionally presented as inferred rather than as a completed functional capability test.

## Privacy
- API keys are stored with iOS Keychain and are never written to chat history.
- Conversations are stored locally with SwiftData.
- Conversation content and selected attachments are sent to NVIDIA only when the user sends a request.
- Custom system instructions are not included in exported chat Markdown.

## Architecture
SwiftUI + SwiftData + async/await + URLSession SSE + Security/Keychain.

Key layers:
- `NVIDIAService`: NVIDIA transport and streaming
- `ModelCatalogStore`: discovery, validation and cached availability
- `ChatViewModel`: chat orchestration, agents and quality enforcement
- `ContextManager`: bounded conversation context
- `ResponseQualityGuard`: Unicode/language output validation
- `NChatTheme`: shared visual design system

## Version
NChat 2.0.0 (Build 20)

## IPA workflow
The GitHub Actions workflow is manual-only. Repository pushes do not trigger a build. Run the workflow explicitly only when an IPA is wanted.
