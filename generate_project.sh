#!/bin/bash

# SnapSieve Xcode Project Generator
# Uses XcodeGen to generate the .xcodeproj
#

PROJECT_NAME="SnapSieve"
BUNDLE_ID="com.marlowsousa.snapsieve"
DEPLOYMENT_TARGET="14.0"
SOURCE_DIR="PhotoCleaner"

echo "🚀 Generating Xcode project for $PROJECT_NAME..."
echo ""

# Check if Info.plist exists in source dir
if [ ! -f "$SOURCE_DIR/Info.plist" ]; then
    echo "❌ Error: $SOURCE_DIR/Info.plist not found!"
    exit 1
fi

# Check if entitlements file exists
if [ ! -f "$SOURCE_DIR/SnapSieve.entitlements" ]; then
    echo "⚠️  SnapSieve.entitlements not found in $SOURCE_DIR. Creating..."
    cat > "$SOURCE_DIR/SnapSieve.entitlements" << 'ENTITLEMENTS_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.security.app-sandbox</key>
	<true/>
	<key>com.apple.security.files.user-selected.read-write</key>
	<true/>
	<key>com.apple.security.assets.pictures.read-write</key>
	<true/>
	<key>com.apple.security.personal-information.photos-library</key>
	<true/>
</dict>
</plist>
ENTITLEMENTS_EOF
fi

echo ""

# Check if xcodegen is installed
if command -v xcodegen &> /dev/null; then
    echo "✅ xcodegen found. Generating project..."
    echo ""

    # Create project.yml for xcodegen
    cat > project.yml << EOF
name: $PROJECT_NAME
options:
  bundleIdPrefix: com.marlowsousa
  deploymentTarget:
    macOS: "$DEPLOYMENT_TARGET"
  xcodeVersion: "15.0"
  generateEmptyDirectories: true

settings:
  base:
    SWIFT_VERSION: "5.9"
    MACOSX_DEPLOYMENT_TARGET: "$DEPLOYMENT_TARGET"
    CODE_SIGN_STYLE: Automatic
    PRODUCT_BUNDLE_IDENTIFIER: $BUNDLE_ID
    DEVELOPMENT_TEAM: ""

targets:
  $PROJECT_NAME:
    type: application
    platform: macOS
    sources:
      - path: $SOURCE_DIR
        excludes:
          - "**/*.md"
          - "**/Info.plist"
          - "**/*.entitlements"
    settings:
      base:
        INFOPLIST_FILE: $SOURCE_DIR/Info.plist
        CODE_SIGN_ENTITLEMENTS: $SOURCE_DIR/SnapSieve.entitlements
        LD_RUNPATH_SEARCH_PATHS: "\$(inherited) @executable_path/../Frameworks"
        SWIFT_STRICT_CONCURRENCY: complete
        ENABLE_USER_SCRIPT_SANDBOXING: NO
    info:
      path: $SOURCE_DIR/Info.plist
      properties:
        CFBundleIdentifier: $BUNDLE_ID
        CFBundleDisplayName: "Snap Sieve"

  ${PROJECT_NAME}Tests:
    type: bundle.unit-test
    platform: macOS
    sources:
      - path: ${SOURCE_DIR}Tests
    dependencies:
      - target: $PROJECT_NAME
    settings:
      base:
        GENERATE_INFOPLIST_FILE: YES

schemes:
  $PROJECT_NAME:
    build:
      targets:
        $PROJECT_NAME: all
        ${PROJECT_NAME}Tests: [test]
    run:
      config: Debug
    test:
      config: Debug
      targets:
        - ${PROJECT_NAME}Tests
    profile:
      config: Release
    archive:
      config: Release
EOF

    # Generate the project
    xcodegen generate
    
    if [ $? -eq 0 ]; then
        echo "✅ Project generated successfully!"
    else
        echo "❌ Error generating project"
        exit 1
    fi
else
    echo "❌ xcodegen not found! Please install it via 'brew install xcodegen'"
    exit 1
fi
