# Claude Usage Menu Bar

A native macOS menu bar app that shows Claude's 5-hour and weekly (7-day) subscription rate-limit usage as small gauges next to the clock/battery/Wi-Fi icons.

## How it works

- Reads the OAuth token Claude Code stores in the macOS Keychain (service `Claude Code-credentials`, account = current user). The first time it does this, macOS will show a permission prompt — choose **Always Allow**.
- Polls an undocumented Anthropic endpoint (`GET https://api.anthropic.com/api/oauth/usage`) every 2 minutes using that token, and shows the returned 5-hour and 7-day utilization as color-coded gauges (green `<70%`, amber `70–89%`, red `≥90%`).
- This endpoint is **not officially documented by Anthropic**. The exact field names/response shape used here were inferred from third-party tools and may need adjusting if Anthropic changes it — see "Known limitations" below.

## Requirements

- macOS 14 (Sonoma) or later.
- Claude Code CLI installed and signed in (so the Keychain item exists).
- No Xcode required — only the Swift toolchain (Command Line Tools).

## Build & run (development)

```bash
swift run
```

This compiles and launches the app directly from Terminal. Quit it from the dropdown menu's "Quit" button (it has no Dock icon, so Cmd+Q from another app won't reach it).

## Build a standalone .app

```bash
./Packaging/build_app.sh
cp -R ClaudeUsageMenuBar.app /Applications/
```

Installing to `/Applications` is recommended — the "Launch at Login" toggle (backed by `SMAppService`) is most reliable when the app lives there.

The app is **ad-hoc code signed** (not notarized, not distributed). It's a personal local utility, not sandboxed: macOS App Sandbox would block reading another app's Keychain item, so sandboxing is intentionally left off.

## Known limitations

- The usage endpoint is reverse-engineered and undocumented. If Anthropic changes its shape, decoding will fail and the app will show an error state (it won't crash) — `Sources/ClaudeUsageMenuBar/Services/UsageAPIClient.swift` is where to adjust field names/types if that happens.
- If the Keychain item's stored format changes, update `Sources/ClaudeUsageMenuBar/Services/CredentialParser.swift` (it already tries a nested `claudeAiOauth.accessToken` JSON shape, a flat `accessToken` JSON shape, and a plain-text token, in that order).
- Rebuilding repeatedly during development may occasionally cause macOS to re-prompt for Keychain access, since ad-hoc signatures can change between builds. This settles down once you stop rebuilding.
