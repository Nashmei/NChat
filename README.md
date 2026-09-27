# Prompt Wars — NChat Game Edition

Prompt Wars is a native iOS tactical command game built with SwiftUI. Players issue natural-language orders, while a deterministic local game engine owns health, damage, counters, rewards and victory.

## Current game
- Native iOS 17+ SwiftUI interface
- Onboarding and futuristic visual system
- Training, Ranked and Blitz modes
- Three-lane tactical battle engine
- Vanguard, Ranger, Guardian and Striker units
- Balanced, Assault, Defend, Flank and Ambush tactics
- Natural-language Arabic/English local command interpreter
- Optional NVIDIA tactical-AI proxy integration
- Energy, core health, unit health and battle event feed
- Persistent XP, level, rating, credits, wins and losses
- Daily missions
- Squad/loadout editor
- Leaderboard presentation
- Haptics and system feedback
- Online matchmaking client contract
- Secure backend configuration UI
- Manual-only GitHub Actions IPA workflow

## AI security model
The NVIDIA API key must never be embedded in the IPA. The app accepts a secure backend/proxy URL. The backend owns the NVIDIA secret, validates model output, and returns a constrained tactical plan. AI is not authoritative for damage, health, rewards, rating or the winner.

Expected tactical response:
```json
{
  "tactic": "Flank",
  "focusLane": 2,
  "aggression": 0.7,
  "holdPosition": false,
  "summary": "Pressure the right lane."
}
```

## Online backend contract
Ranked and Blitz are designed for a server-authoritative backend. The client currently defines `POST /v1/matchmaking` and expects a match ticket. Training remains fully local and playable without a backend.

## Open-source / asset policy
The current runtime target uses Apple frameworks only: SwiftUI, Foundation, Combine, UIKit and AVFoundation.

For future external art, the approved direction is Kenney's CC0 packs (including UI Pack - Sci-Fi, Game Icons and Sci-Fi RTS). Their asset pages identify the packs as CC0 and Kenney states commercial use is allowed and attribution is not required. No Kenney binary asset is currently bundled, so the repository does not carry unused third-party art.

## Build
The GitHub Actions workflow is intentionally manual-only:
```yaml
on:
  workflow_dispatch:
```
Pushing commits does not automatically start an IPA build.

## Project layout
- `NChat/App/NChatApp.swift` — app entry
- `NChat/Game/GameStore.swift` — authoritative local game state
- `NChat/Game/GameModels.swift` — battle models
- `NChat/Game/ProductionModels.swift` — modes, missions, loadout, online models
- `NChat/Game/BattleView.swift` — battle UI
- `NChat/Game/CommandCenterView.swift` — modes, missions, leaderboard
- `NChat/Game/LoadoutView.swift` — squad customization
- `NChat/Game/OnlineService.swift` — matchmaking client contract
- `NChat/Game/TacticalAIService.swift` — secure AI proxy client
- `NChat/Game/FeedbackService.swift` — haptics/system audio
- `NChat/Game/OnboardingView.swift` — first-run experience

## Release status
The local game and production UI are implemented. A real global PvP service, account service, anti-cheat, remote leaderboard persistence, push notifications, analytics, App Store signing and production NVIDIA proxy require deployed external infrastructure and credentials; they cannot be made real solely by client-side Swift code.
