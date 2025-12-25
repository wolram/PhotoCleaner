#!/bin/bash

# PhotoCleaner Xcode Project Generator
# This script creates an Xcode project from the Swift source files

set -e

PROJECT_NAME="PhotoCleaner"
BUNDLE_ID="com.photocleaner.app"
DEPLOYMENT_TARGET="14.0"

echo "Generating Xcode project for $PROJECT_NAME..."

# Check if xcodegen is installed
if command -v xcodegen &> /dev/null; then
    echo "Using xcodegen to generate project..."

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

targets:
  $PROJECT_NAME:
    type: application
    platform: macOS
    sources:
      - path: $PROJECT_NAME
        excludes:
          - "**/*.xcassets"
    resources:
      - path: $PROJECT_NAME/Resources/Assets.xcassets
    settings:
      base:
        INFOPLIST_FILE: $PROJECT_NAME/Info.plist
        CODE_SIGN_ENTITLEMENTS: $PROJECT_NAME/PhotoCleaner.entitlements
        LD_RUNPATH_SEARCH_PATHS: "@executable_path/../Frameworks"
        ASSETCATALOG_COMPILER_APPICON_NAME: AppIcon
    entitlements:
      path: $PROJECT_NAME/PhotoCleaner.entitlements

  ${PROJECT_NAME}Tests:
    type: bundle.unit-test
    platform: macOS
    sources:
      - ${PROJECT_NAME}Tests
    dependencies:
      - target: $PROJECT_NAME

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
EOF

    xcodegen generate
    echo "Project generated successfully!"

else
    echo "xcodegen not found. Installing via Homebrew..."
    echo ""
    echo "Option 1: Install xcodegen and run this script again:"
    echo "  brew install xcodegen"
    echo "  ./generate_project.sh"
    echo ""
    echo "Option 2: Create project manually in Xcode:"
    echo "  1. Open Xcode"
    echo "  2. File → New → Project → macOS → App"
    echo "  3. Name: $PROJECT_NAME"
    echo "  4. Interface: SwiftUI, Language: Swift, Storage: SwiftData"
    echo "  5. Delete generated files and add the PhotoCleaner folder"
    echo ""
    echo "Option 3: Use Swift Package Manager:"
    echo "  swift build"
    echo "  swift package generate-xcodeproj"
    echo ""

    # Try SPM approach
    echo "Attempting Swift Package Manager approach..."
    if swift package generate-xcodeproj 2>/dev/null; then
        echo "Xcode project generated via SPM!"
        open ${PROJECT_NAME}.xcodeproj
    else
        echo "SPM project generation requires the Package.swift to be properly configured."
        echo "Please use Option 1 or Option 2 above."
    fi
fi

echo ""
echo "Next steps:"
echo "1. Open ${PROJECT_NAME}.xcodeproj in Xcode"
echo "2. Select your development team in Signing & Capabilities"
echo "3. Build and run (Cmd+R)"
