#!/bin/bash

# PhotoCleaner Xcode Project Generator
# This script creates an Xcode project from the Swift source files

set -e

PROJECT_NAME="PhotoCleaner"
BUNDLE_ID="com.photocleaner.app"
DEPLOYMENT_TARGET="14.0"

echo "🚀 Generating Xcode project for $PROJECT_NAME..."
echo ""

# Check if Info.plist exists
if [ ! -f "$PROJECT_NAME/Info.plist" ]; then
    echo "⚠️  Info.plist not found. Creating..."
    mkdir -p "$PROJECT_NAME"
    cat > "$PROJECT_NAME/Info.plist" << 'PLIST_EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>$(DEVELOPMENT_LANGUAGE)</string>
	<key>CFBundleDisplayName</key>
	<string>SnapSieve</string>
	<key>CFBundleExecutable</key>
	<string>$(EXECUTABLE_NAME)</string>
	<key>CFBundleIdentifier</key>
	<string>com.photocleaner.app</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>$(PRODUCT_NAME)</string>
	<key>CFBundlePackageType</key>
	<string>APPL</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>LSMinimumSystemVersion</key>
	<string>14.0</string>
	<key>NSHumanReadableCopyright</key>
	<string>Copyright © 2026. All rights reserved.</string>
	<key>NSPhotoLibraryUsageDescription</key>
	<string>SnapSieve needs access to your photo library to find duplicates and similar photos. All processing happens locally on your device.</string>
	<key>NSPhotoLibraryAddUsageDescription</key>
	<string>SnapSieve needs permission to manage your photo library. Photos are only deleted with your explicit confirmation.</string>
</dict>
</plist>
PLIST_EOF
    echo "✅ Info.plist created"
fi

# Check if entitlements file exists
if [ ! -f "$PROJECT_NAME/PhotoCleaner.entitlements" ]; then
    echo "⚠️  Entitlements file not found. Creating..."
    cat > "$PROJECT_NAME/PhotoCleaner.entitlements" << 'ENTITLEMENTS_EOF'
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
    echo "✅ Entitlements file created"
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
  bundleIdPrefix: com.photocleaner
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
      - path: $PROJECT_NAME
        excludes:
          - "**/*.md"
          - "**/Info.plist"
          - "**/*.entitlements"
    settings:
      base:
        INFOPLIST_FILE: $PROJECT_NAME/Info.plist
        CODE_SIGN_ENTITLEMENTS: $PROJECT_NAME/PhotoCleaner.entitlements
        LD_RUNPATH_SEARCH_PATHS: "\$(inherited) @executable_path/../Frameworks"
        SWIFT_STRICT_CONCURRENCY: complete
        ENABLE_USER_SCRIPT_SANDBOXING: NO
    info:
      path: $PROJECT_NAME/Info.plist
      properties:
        CFBundleIdentifier: $BUNDLE_ID
        CFBundleDisplayName: SnapSieve
        LSMinimumSystemVersion: "$DEPLOYMENT_TARGET"
        NSPhotoLibraryUsageDescription: "SnapSieve needs access to your photo library to find duplicates and similar photos. All processing happens locally on your device."
        NSPhotoLibraryAddUsageDescription: "SnapSieve needs permission to manage your photo library. Photos are only deleted with your explicit confirmation."

schemes:
  $PROJECT_NAME:
    build:
      targets:
        $PROJECT_NAME: all
    run:
      config: Debug
      commandLineArguments:
        "-com.apple.CoreData.ConcurrencyDebug 1": true
    profile:
      config: Release
    archive:
      config: Release
EOF

    # Generate the project
    xcodegen generate
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Project generated successfully!"
        echo ""
        echo "📂 Opening project in Xcode..."
        open ${PROJECT_NAME}.xcodeproj
        echo ""
        echo "📋 Next steps:"
        echo "   1. In Xcode, go to Project Settings → Signing & Capabilities"
        echo "   2. Select your Apple Developer Team"
        echo "   3. Press Cmd+R to build and run"
        echo ""
        echo "🎉 Done! Your app should now open on macOS."
    else
        echo "❌ Error generating project"
        exit 1
    fi

else
    echo "❌ xcodegen not found!"
    echo ""
    echo "📦 Installing xcodegen via Homebrew..."
    echo ""
    
    # Check if Homebrew is installed
    if command -v brew &> /dev/null; then
        echo "Installing xcodegen..."
        brew install xcodegen
        echo ""
        echo "✅ xcodegen installed. Running script again..."
        exec "$0"
    else
        echo "❌ Homebrew not found!"
        echo ""
        echo "Please install Homebrew first:"
        echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        echo ""
        echo "Then run this script again:"
        echo "  ./generate_project.sh"
        exit 1
    fi
fi

