# PIKIR Mobile - Project Context

Read this file completely before your first edit in any session. If anything you are asked to do contradicts this file, stop and say so instead of guessing.

## 1. What this project is

PIKIR is an Android app that intervenes at the moment an Indonesian informal or gig worker is about to take a predatory online loan (pinjol) or a paylater instalment. Tagline: "Pikir dulu, baru pinjam."

This repository is being built for the GEMASTIK 2026 Software Development competition. The deliverable for the current round is a **fully mocked frontend** that can be demoed on a real device and screen-recorded. It is not a production app and it is not connected to a backend.

Target user: ojek-online drivers, street vendors, small online sellers, students. Low financial literacy, low to medium digital literacy, often deciding under stress at night.

## 2. Hard rules

These are not preferences. Breaking any of them breaks the submission.

1. **No backend calls.** Every screen is fed by mock data. Where a real API would be called, define a repository interface and implement a mock class, then leave `// TODO(backend): POST /api/v1/...` at the call site with the endpoint name from the handoff document.
2. **No login, no accounts, ever.** The app is fully anonymous. Do not create sign-in screens, avatars, user names, email fields, or account settings. Greetings say "Halo" with no name.
3. **No Contacts and no Gallery permissions.** Do not add them to the manifest, do not request them at runtime.
4. **Notification detection is deterministic for now.** Use keyword and regex matching on incoming notification text. Do not add TensorFlow Lite yet. Mark the TFLite integration point with `// TODO(ml): replace deterministic keyword check with TFLite classifier`.
5. **Local only storage.** All state lives on the device. Chat history is deleted after 24 hours. Chat sessions become read only after 2 hours of inactivity.
6. **Never add AI attribution to git.** Do not add "Generated with Claude Code" or any `Co-Authored-By` trailer to commit messages, PR descriptions, code comments, or documentation. Do not run `git commit` or `git push` unless the user explicitly asks in that message. The user pushes manually.
7. **Do not create new markdown planning files** in the repository root without being asked. Working notes go in `docs/ai/` which is gitignored.

## 3. Platform

- Flutter for all UI. Kotlin only for the Android-specific services that Flutter cannot reach.
- `minSdkVersion 30` (Android 11). Do not raise it to 34.
- Two Android services, both talking to Flutter through a `MethodChannel`:
  - `AccessibilityService` for detecting a paylater checkout screen and the launch of a whitelisted loan app.
  - `NotificationListenerService` for reading incoming notifications and dismissing the ones flagged as predatory.
- Both services keep running when the PIKIR UI is closed.
- Overlays are drawn with the system alert window permission.
- Screenshots are allowed. Do not set `FLAG_SECURE`.

## 4. Architecture

```
lib/
  main.dart
  app.dart                  // MaterialApp, theme, router
  core/
    theme/                  // tokens.dart, app_theme.dart, text_styles.dart
    widgets/                // shared components (see section 6)
    router/                 // named routes for every screen
    platform/               // MethodChannel wrappers for the two services
  data/
    models/                 // DebtEntry, EmergencyFundPlan, ChatMessage, RouteOption...
    repositories/           // abstract interfaces
    mock/                   // MockXRepository implementations + seeded fixtures
  features/
    onboarding/
    home/
    intervention/           // Fitur 1
    mitigation/             // Fitur 2
    notification_scanner/   // Fitur 3
    emergency_fund/         // Fitur 4
    chat/                   // Fitur 5
    ledger/
    settings/
```

Rules:
- One folder per feature, each containing `screens/`, `widgets/`, and its state class.
- State management is Riverpod. Keep it simple, no code generation.
- Every screen is reachable from a named route. No screen may exist without an entry point.
- Mock repositories are injected at the top so a real implementation can replace them later without touching the UI.

## 5. Design tokens

Do not invent colors, sizes, or fonts outside this list.

| Token | Value |
|---|---|
| primary | `#0B6B3A` |
| onPrimary | `#FFFFFF` |
| primaryContainer | `#DCF2E4` |
| accent | `#F2B441` |
| safe | `#1E9E5A` |
| caution | `#E8A33D` |
| cautionContainer | `#FFF7E6` |
| danger | `#D64545` |
| dangerContainer | `#FDECEC` |
| background | `#F6F8F5` |
| surface | `#FFFFFF` |
| outline | `#E3E8E2` |
| textPrimary | `#10231A` |
| textSecondary | `#5C6B62` |

- Font: Plus Jakarta Sans. Numbers tabular and bold.
- Display number 40 to 44sp, headline 26 to 28sp, title 18 to 20sp, body 16sp minimum, caption 13sp minimum. Nothing smaller than 13sp anywhere.
- Card radius 24, hero card radius 28, button radius 28, input radius 16.
- Card padding 20, gap between cards 16, screen horizontal padding 20.
- One soft shadow only: y 4, blur 20, black at 6 percent.
- Minimum tap target 48x48.
- There is no blue in this app. Secondary actions are outlined green.
- No dark theme.

## 6. UI rules that come from the product, not from taste

These map directly to the non functional requirements in the proposal and are judged. Do not simplify them away.

1. Every status is shown with **color plus icon plus text labl** together. Never color alone.
2. Nothing is pre selected, pre checked, or pre filled with a recommended option.
3. When two or more choices are offered, the buttons have **identical width, height, and font weight**. Never shrink, fade, or grey out the option that declines or exits.
4. When an action needs deliberate friction, use hold to confirm: the button keeps full size and full contrast while a progress ring fills over 5 seconds. Friction lives in the gesture, never in hiding the option.
5. No countdown timers, no scarcity copy, no "sisa 2 jam lagi", no confirmshaming, no streaks, no points, no confetti, no leaderboards, no comparison with other users.
6. All costs are shown before the decision, in rupiah, formatted `Rp1.800.000` with no cents.
7. On consumptive and basic needs paths, the app never shows, suggests, or links to a loan product.
8. All UI copy is everyday Bahasa Indonesia. Financial terms get a one line plain language gloss beneath them.
9. Overlay screens always carry a visible PIKIR mark so the user knows which app is speaking.

Shared widgets to build once and reuse: `PikirButton` (filled and outlined variants of equal metrics), `HoldToConfirmButton`, `ThresholdGauge`, `StatusChip`, `SourceChip`, `DisclaimerBand`, `OptionCard`, `TierProgressBar`, `PikirBottomNav`.

## 7. Feature logic that is easy to get wrong

**Need classification branches into three, not two.** This was corrected late, older drafts in the repository may still be wrong.
- Consumptive wants, such as shoes or a concert ticket, go to the **opportunity cost** screen. They do not go to social assistance.
- Urgent survival needs, such as medical care or food, go to **social assistance and rights routing**. They never go to a loan product.
- Productive needs, such as working capital or a broken motorbike, go to the **feasibility test** and then to financing options **sorted by disbursement speed**, not by lowest interest.

**Intervention triggers.**
- E-commerce: checkout screen detected AND paylater selected. Both conditions, not either. The app blocks the screen instantly with a blanket loading screen while it analyses.
- Loan app: block the moment the app opens, then ask "Kamu mau ngutang buat apa?" with two options. Urgent or working capital hands over to mitigation. Consumptive asks the user to type the item name.
- Offline fallback is mandatory. If there is no connection or the mock analysis takes over 3 seconds, show the local fallback screen with the breathing prompt.

**Notification scanner.** A flagged notification is dismissed silently and PIKIR posts its own educational notification in its place. The replacement notification must always include an action that reveals the original message. The user is never locked out of their own message.

**Bottom navigation.** `Beranda`, `Mitigasi`, center FAB `Tanya PIKIR`, `Dana Darurat`, `Ledger`. Settings is reached from a gear icon on Beranda, not from a tab. There is no profile tab because there are no accounts.

## 8. Demo mode

The submission needs a screen recording, and the real triggers are hard to stage on camera. Build a `DemoPage` reachable from Settings, hidden behind a row labelled "Mode demo", containing buttons that fire each flow directly:
- Simulasi checkout paylater
- Simulasi buka aplikasi pinjaman
- Simulasi notifikasi pinjol masuk
- Reset data ke kondisi awal

Seed the mock data so the demo always looks the same: three ledger entries totalling `Rp3.150.000`, a debt ratio of 18 percent, an emergency fund at `Rp450.000` of a `Rp1.000.000` tier one target.

## 9. Definition of done for a screen

- Matches the mockup layout and the tokens above.
- Reachable through a named route from its documented entry point.
- Uses mock repository data, no hardcoded widgets full of literals scattered across files.
- Copy is in Bahasa Indonesia and passes the rules in section 6.
- Builds with no analyzer errors.
- Runs on a real device at 393x852 without the primary action falling below the fold.
