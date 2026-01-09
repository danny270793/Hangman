#!/bin/bash

# Script to update iOS version using semantic versioning
# Always increments the patch version (1.0.x -> 1.0.x+1)

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 iOS Version Updater${NC}"
echo -e "${BLUE}=======================${NC}\n"

# Get the project root directory (one level up from scripts)
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUBSPEC_FILE="$PROJECT_ROOT/pubspec.yaml"

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo -e "${RED}❌ Error: pubspec.yaml not found at $PUBSPEC_FILE${NC}"
    exit 1
fi

# Read current version from pubspec.yaml
CURRENT_VERSION=$(grep "^version:" "$PUBSPEC_FILE" | sed 's/version: //')

if [ -z "$CURRENT_VERSION" ]; then
    echo -e "${RED}❌ Error: Could not read version from pubspec.yaml${NC}"
    exit 1
fi

# Split version into version name and build number
# Format: 1.0.0+1 -> version_name=1.0.0, build_number=1
VERSION_NAME=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BUILD_NUMBER=$(echo "$CURRENT_VERSION" | cut -d'+' -f2)

echo -e "Current version: ${GREEN}$VERSION_NAME${NC}"
echo -e "Current build number: ${GREEN}$BUILD_NUMBER${NC}\n"

# Split version name into major.minor.patch
MAJOR=$(echo "$VERSION_NAME" | cut -d'.' -f1)
MINOR=$(echo "$VERSION_NAME" | cut -d'.' -f2)
PATCH=$(echo "$VERSION_NAME" | cut -d'.' -f3)

# Increment patch version
NEW_PATCH=$((PATCH + 1))
NEW_VERSION_NAME="$MAJOR.$MINOR.$NEW_PATCH"

# Increment build number
NEW_BUILD_NUMBER=$((BUILD_NUMBER + 1))

# Create new version string
NEW_VERSION="$NEW_VERSION_NAME+$NEW_BUILD_NUMBER"

echo -e "${BLUE}📈 Updating version...${NC}"
echo -e "New version: ${GREEN}$NEW_VERSION_NAME${NC}"
echo -e "New build number: ${GREEN}$NEW_BUILD_NUMBER${NC}\n"

# Update pubspec.yaml
# Using sed with backup for safety
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/^version: $CURRENT_VERSION/version: $NEW_VERSION/" "$PUBSPEC_FILE"
else
    # Linux
    sed -i "s/^version: $CURRENT_VERSION/version: $NEW_VERSION/" "$PUBSPEC_FILE"
fi

echo -e "${GREEN}✅ pubspec.yaml updated successfully!${NC}\n"

# Show the change
echo -e "${BLUE}Changes:${NC}"
echo -e "  ${RED}- version: $CURRENT_VERSION${NC}"
echo -e "  ${GREEN}+ version: $NEW_VERSION${NC}\n"

# Ask if user wants to update iOS Info.plist files
echo -e "${BLUE}Do you want to run 'flutter build ios --config-only' to update iOS Info.plist? (y/n)${NC}"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "\n${BLUE}🔄 Running flutter build ios --config-only...${NC}"
    cd "$PROJECT_ROOT"
    flutter build ios --config-only
    echo -e "${GREEN}✅ iOS configuration updated!${NC}\n"
else
    echo -e "\n${BLUE}ℹ️  Skipped iOS build. Run 'flutter build ios --config-only' manually to update Info.plist${NC}\n"
fi

echo -e "${GREEN}🎉 Version update complete!${NC}"
echo -e "${BLUE}Summary:${NC}"
echo -e "  Version Name: ${GREEN}$VERSION_NAME → $NEW_VERSION_NAME${NC}"
echo -e "  Build Number: ${GREEN}$BUILD_NUMBER → $NEW_BUILD_NUMBER${NC}"
echo -e "\n${BLUE}💡 Don't forget to commit these changes!${NC}"

