# NChat

Native SwiftUI chat client for NVIDIA NIM APIs on iPhone.

## Current capabilities
- Local-first multi-conversation UI with SwiftData
- NVIDIA API key stored only in iOS Keychain
- OpenAI-compatible NVIDIA NIM chat completions
- Server-Sent Events streaming and Stop generation
- Separate reasoning display when the model returns reasoning_content
- Per-chat model selection
- System prompt support and advanced generation model in the architecture
- Markdown rendering, text selection, rename-ready conversation model
- Dark/light mode follows iOS
- GitHub Actions IPA build

## Architecture
SwiftUI + SwiftData + async/await + URLSession SSE + Keychain. The provider is isolated in Services so additional OpenAI-compatible providers can be added without rewriting the UI.

## NVIDIA
Endpoint: https://integrate.api.nvidia.com/v1/chat/completions

Never commit API keys. Open Settings in NChat and store your key in Keychain.

## Build locally
Install XcodeGen, run `xcodegen generate`, then open `NChat.xcodeproj`.

## IPA
Run the **Build NChat IPA** GitHub Action. The default artifact is an unsigned IPA intended for external signing tools. For App Store/TestFlight distribution, use an Apple Developer certificate and provisioning profile.
