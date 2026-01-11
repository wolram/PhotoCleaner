# Fastlane Configuration for SnapSieve

This directory contains the fastlane configuration for building, testing, and releasing SnapSieve (PhotoCleaner) for macOS.

## Prerequisites

1. **Ruby and Bundler**
   ```bash
   # Install bundler if not present
   gem install bundler

   # Install fastlane dependencies
   cd /path/to/PhotoCleaner
   bundle install
   ```

2. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

3. **xcodegen** (for project generation)
   ```bash
   brew install xcodegen
   ```

## Quick Start

```bash
# Navigate to project root
cd /path/to/PhotoCleaner

# Build the app
bundle exec fastlane mac build

# Run tests
bundle exec fastlane mac test

# Full release (archive + notarize + upload)
bundle exec fastlane mac release
```

## Available Lanes

### Build Lanes

| Lane | Description | Usage |
|------|-------------|-------|
| `build` | Build in Debug configuration | `fastlane mac build` |
| `build_release` | Build in Release configuration | `fastlane mac build_release` |

### Test Lanes

| Lane | Description | Usage |
|------|-------------|-------|
| `test` | Run unit tests with failure on error | `fastlane mac test` |
| `test_report` | Run tests without failing (for CI reporting) | `fastlane mac test_report` |

Test output is generated at `./fastlane/test_output/` including HTML and JUnit reports.

### Release Lanes

| Lane | Description | Usage |
|------|-------------|-------|
| `release` | Full release: archive, notarize, upload | `fastlane mac release` |
| `release skip_notarize:true` | Skip notarization step | `fastlane mac release skip_notarize:true` |
| `release skip_upload:true` | Skip App Store upload | `fastlane mac release skip_upload:true` |

### Utility Lanes

| Lane | Description | Usage |
|------|-------------|-------|
| `version` | Display current version and build number | `fastlane mac version` |
| `bump_build` | Increment the build number | `fastlane mac bump_build` |
| `set_version` | Set the version number | `fastlane mac set_version version:1.2.0` |
| `clean` | Clean build artifacts and derived data | `fastlane mac clean` |
| `generate` | Regenerate Xcode project with xcodegen | `fastlane mac generate` |

### CI/CD Lanes

| Lane | Description | Usage |
|------|-------------|-------|
| `ci` | Full CI pipeline (build + test) | `fastlane mac ci` |
| `cd` | Full CD pipeline (bump + build + test + release) | `fastlane mac cd` |

## Configuration Files

### Appfile
Contains app-specific configuration:
- `app_identifier`: Bundle ID (`com.photocleaner.app`)
- `apple_id`: Your Apple Developer email
- `team_id`: Your Apple Developer Team ID

### Matchfile
Configuration for [fastlane match](https://docs.fastlane.tools/actions/match/) code signing:
- `git_url`: Private Git repo for certificates
- `type`: Certificate type (appstore, development, developer_id)
- `platform`: Target platform (macos)

## Setting Up Credentials

### For Local Development

1. Edit `fastlane/Appfile` and replace placeholder values:
   ```ruby
   apple_id("your-actual-email@example.com")
   team_id("YOUR_ACTUAL_TEAM_ID")
   ```

2. Generate an App-Specific Password for notarization:
   - Go to https://appleid.apple.com
   - Sign in and navigate to Security
   - Under "App-Specific Passwords", click "Generate Password"
   - Store securely

### For CI/CD

Set these environment variables in your CI system:

| Variable | Description |
|----------|-------------|
| `APPLE_ID` | Apple Developer email |
| `TEAM_ID` | Apple Developer Team ID |
| `APP_SPECIFIC_PASSWORD` | For notarization |
| `MATCH_PASSWORD` | For match certificate encryption |
| `MATCH_GIT_BASIC_AUTHORIZATION` | Base64 encoded Git credentials |

## Example CI/CD Workflows

### GitHub Actions

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install xcodegen
        run: brew install xcodegen

      - name: Run CI
        run: bundle exec fastlane mac ci
```

### Release Workflow

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Install xcodegen
        run: brew install xcodegen

      - name: Release
        env:
          APPLE_ID: ${{ secrets.APPLE_ID }}
          TEAM_ID: ${{ secrets.TEAM_ID }}
          APP_SPECIFIC_PASSWORD: ${{ secrets.APP_SPECIFIC_PASSWORD }}
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
        run: bundle exec fastlane mac release
```

## Code Signing with Match

If you want to use match for code signing across your team:

1. Create a private Git repository for certificates

2. Initialize match:
   ```bash
   bundle exec fastlane match init
   ```

3. Generate certificates:
   ```bash
   # For development
   bundle exec fastlane match development

   # For App Store
   bundle exec fastlane match appstore

   # For Developer ID (direct distribution)
   bundle exec fastlane match developer_id
   ```

4. In CI, use readonly mode:
   ```bash
   bundle exec fastlane match appstore --readonly
   ```

## Troubleshooting

### "Xcode project not found"
Run the generate lane or the project generator script:
```bash
fastlane mac generate
# or
./generate_project.sh
```

### "xcodegen not installed"
Install xcodegen via Homebrew:
```bash
brew install xcodegen
```

### Notarization fails
1. Ensure `apple_id` and `team_id` are set correctly in Appfile
2. Verify your App-Specific Password is valid
3. Check that your app meets Apple's notarization requirements

### Code signing errors
1. Ensure you have a valid Apple Developer account
2. Check that provisioning profiles are installed
3. Consider using match for team-wide code signing

## File Structure

```
fastlane/
├── Appfile          # App-specific configuration
├── Fastfile         # Lane definitions
├── Matchfile        # Code signing configuration
├── README.md        # This file
├── metadata/        # App Store metadata
│   └── en-US/
│       └── app_store_metadata.md
└── test_output/     # Generated test reports (gitignored)
```

## More Information

- [fastlane documentation](https://docs.fastlane.tools/)
- [fastlane for macOS](https://docs.fastlane.tools/getting-started/ios/setup/)
- [match documentation](https://docs.fastlane.tools/actions/match/)
- [notarize documentation](https://docs.fastlane.tools/actions/notarize/)
