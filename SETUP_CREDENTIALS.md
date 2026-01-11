# SnapSieve - Credential Setup Guide

This guide explains how to configure your Apple Developer credentials for App Store submission.

## Prerequisites

1. **Apple Developer Account** - Enrolled in Apple Developer Program ($99/year)
2. **Xcode** - Latest version installed
3. **App-Specific Password** - For Fastlane automation (optional)

---

## Step 1: Register Bundle ID

1. Go to [Apple Developer Portal](https://developer.apple.com/account/resources/identifiers/list)
2. Click **"+"** to register a new identifier
3. Select **"App IDs"** → Continue
4. Select **"App"** → Continue
5. Fill in:
   - **Description:** SnapSieve
   - **Bundle ID:** Choose **Explicit** and enter: `com.YOURCOMPANY.snapsieve`
   - Replace `YOURCOMPANY` with your company/personal identifier
6. Enable capabilities:
   - ✅ Photos (read/write access)
7. Click **Register**

---

## Step 2: Update Project Configuration

### Option A: Update generate_project.sh (Recommended)

Edit `/home/user/PhotoCleaner/generate_project.sh`:

```bash
# Find this line (around line 9):
BUNDLE_ID="com.photocleaner.app"

# Change to your registered Bundle ID:
BUNDLE_ID="com.YOURCOMPANY.snapsieve"
```

Also update line 101:
```yaml
DEVELOPMENT_TEAM: ""
# Change to:
DEVELOPMENT_TEAM: "YOUR_TEAM_ID"  # Find this in Apple Developer Portal → Membership
```

### Option B: Update in Xcode

1. Run `./generate_project.sh` to create the project
2. Open `PhotoCleaner.xcodeproj`
3. Select the project in Navigator
4. Go to **Signing & Capabilities** tab
5. Select your Team from dropdown
6. Update Bundle Identifier to match your registered ID

---

## Step 3: Configure Fastlane Credentials

Edit `/home/user/PhotoCleaner/fastlane/Appfile`:

```ruby
# Your registered Bundle ID
app_identifier "com.YOURCOMPANY.snapsieve"

# Your Apple ID email
apple_id "your.email@example.com"

# Your Team ID (found in Apple Developer Portal → Membership)
team_id "XXXXXXXXXX"
```

---

## Step 4: App-Specific Password (for CI/CD)

For automated uploads via Fastlane:

1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in → **Security** → **App-Specific Passwords**
3. Click **"+"** to generate a new password
4. Name it: "Fastlane SnapSieve"
5. Copy the generated password

Set as environment variable:
```bash
export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"
```

Or add to your shell profile (~/.zshrc or ~/.bashrc):
```bash
echo 'export FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD="xxxx-xxxx-xxxx-xxxx"' >> ~/.zshrc
```

---

## Step 5: Verify Configuration

Run these commands to verify:

```bash
# Regenerate project with new settings
./generate_project.sh

# Verify Fastlane can read credentials
cd fastlane && bundle exec fastlane mac version
```

---

## Quick Reference

| Setting | Location | Example |
|---------|----------|---------|
| Bundle ID | `generate_project.sh` line 9 | `com.acme.snapsieve` |
| Team ID | `generate_project.sh` line 101 | `ABCD1234XY` |
| Apple ID | `fastlane/Appfile` | `dev@example.com` |
| App Password | Environment variable | `xxxx-xxxx-xxxx-xxxx` |

---

## Troubleshooting

### "No signing certificate found"
- Open Xcode → Preferences → Accounts → Download Manual Profiles
- Or run: `fastlane match development`

### "Bundle ID not registered"
- Ensure the Bundle ID in your project matches exactly what you registered in the Developer Portal

### "Team ID not found"
- Go to [Apple Developer Portal](https://developer.apple.com/account) → Membership
- Copy the Team ID displayed there

---

## After Configuration

Once credentials are set up, you can:

```bash
# Build and test locally
fastlane mac ci

# Create release build
fastlane mac release skip_upload:true

# Full release to App Store
fastlane mac cd
```

---

## Need Help?

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Project Issues](https://github.com/wolram/PhotoCleaner/issues)
