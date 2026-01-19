# Repository Guidelines

## Project Structure & Module Organization
- `PhotoCleaner/`: app source. Subfolders: `App/` (entry point, app state, config), `Core/` (services, algorithms, utilities), `Data/` (SwiftData entities + repositories), `Features/` (feature modules with View + ViewModel), `UI/` (shared components, navigation, styles), `Resources/` (assets).
- `PhotoCleanerTests/`: XCTest suite for algorithms and services.
- `Design System/`, `DesignAssets/`, `ScreenShots/`: design references and UI assets.
- `fastlane/`: release automation; `generate_project.sh` and `Package.swift` support XcodeGen/SwiftPM flows.

## Build, Test, and Development Commands
- `./generate_project.sh`: generate `PhotoCleaner.xcodeproj` via XcodeGen (installs XcodeGen if missing).
- `open PhotoCleaner.xcodeproj`: open the project in Xcode.
- `xcodebuild -scheme PhotoCleaner -configuration Debug build`: build from the CLI.
- `xcodebuild test -scheme PhotoCleaner`: run the full test suite.
- `xcodebuild test -scheme PhotoCleaner -only-testing:PhotoCleanerTests/PerceptualHashTests`: run a specific test class.
- `xcodebuild clean -scheme PhotoCleaner`: clean build artifacts.
- `swiftlint`: run linting (install SwiftLint if needed; no repo config file is present).

## Coding Style & Naming Conventions
- Swift 5.9, SwiftUI, SwiftData; 4-space indentation, Xcode default formatting.
- Use SwiftLint for linting consistency (per README guidance).
- Naming patterns: `SomethingView`, `SomethingViewModel`, `SomethingService` (actor-based), `SomethingRepository`, `SomethingEntity`, `SomethingTests`.
- Concurrency: prefer async/await; keep view models `@MainActor`; services as actors.

## Testing Guidelines
- Use XCTest in `PhotoCleanerTests/` with `test*` method names.
- Add tests for Core algorithms and services when changing detection, scoring, or grouping logic.
- Keep tests deterministic; avoid hitting the Photos library directly.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, capitalized (e.g., `Add ...`, `Fix ...`, `Remove ...`).
- Keep commits focused; avoid mixing refactors with behavior changes.
- PRs should include a clear summary, test results, linked issues, and screenshots for UI changes (store in `ScreenShots/`).

## Security & Configuration
- Update permissions in `PhotoCleaner/Info.plist` and `PhotoCleaner/PhotoCleaner.entitlements` when changing Photo access.
- Keep `PhotoCleaner/App/PrivacyInfo.xcprivacy` aligned with new data usage.
