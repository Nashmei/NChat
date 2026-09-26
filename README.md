# NChat 2.0

Native SwiftUI AI client for NVIDIA NIM on iPhone.

## Highlights
- NVIDIA API key stored in iOS Keychain
- Full NVIDIA model catalog discovery
- Automatic model validation after saving a key and whenever the app becomes active
- Only verified chat models appear in the picker
- Arabic + Latin Unicode quality probe, streaming check and latency measurement
- Capability profiles for Text, Vision, Reasoning, Tools and Arabic
- Capability-aware request payloads
- Native streaming chat with Stop and Regenerate
- Raw internal reasoning is not rendered in chat
- Built-in language policy: reply in the language of the latest user message
- Local-first SwiftData conversations, search, pin, rename, delete and export
- Image/file attachments with Vision-model validation
- Main responsible model + configurable specialist Agents
- Agent failures fall back to the main model
- Markdown and copyable code blocks
- Context budget and advanced generation controls
- Dark violet NChat visual system with an original NChat identity

## Architecture
SwiftUI + SwiftData + async/await + URLSession SSE + Keychain.

Core layers: NVIDIAService for NVIDIA transport, ModelCatalogStore for discovery and validation, ChatViewModel for orchestration and fallback, and NChatTheme for the visual system.

## Privacy
API keys are not committed or stored in chat history. They are saved in Keychain. Conversations are local-first.

## Version
NChat 2.0.0 (Build 20)

## Build
The GitHub workflow is manual-only. Use Actions > Build NChat IPA > Run workflow when an IPA is wanted. Pushes do not trigger builds.
