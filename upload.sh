#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Arguments
LLVM_VERSION="${1}"
ARTIFACT_PATH="${2}"

if [ -z "$LLVM_VERSION" ] || [ -z "$ARTIFACT_PATH" ]; then
    echo -e "${RED}Usage: $0 <llvm-version> <artifact-path>${NC}"
    echo "Example: $0 llvmorg-20.1.0 llvm-llvmorg-20.1.0-install.tar.gz"
    exit 1
fi

if [ ! -f "$ARTIFACT_PATH" ]; then
    echo -e "${RED}Error: Artifact file not found: $ARTIFACT_PATH${NC}"
    exit 1
fi

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_NAME="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_NAME="linux"
else
    echo -e "${RED}Error: Unsupported OS: $OSTYPE${NC}"
    exit 1
fi

echo -e "${BLUE}=== GitHub Release Upload Script ===${NC}"
echo -e "${BLUE}LLVM Version: $LLVM_VERSION${NC}"
echo -e "${BLUE}OS: $OS_NAME${NC}"
echo -e "${BLUE}Artifact: $ARTIFACT_PATH${NC}\n"

# Rename artifact to include OS
ARTIFACT_BASENAME=$(basename "$ARTIFACT_PATH" .tar.gz)
NEW_ARTIFACT_NAME="${ARTIFACT_BASENAME}-${OS_NAME}.tar.gz"
cp "$ARTIFACT_PATH" "$NEW_ARTIFACT_NAME"

echo -e "${BLUE}Renamed artifact to: $NEW_ARTIFACT_NAME${NC}\n"

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo -e "${RED}Error: GitHub CLI (gh) is not installed${NC}"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if release exists
echo "Checking if release $LLVM_VERSION exists..."
if gh release view "$LLVM_VERSION" &> /dev/null; then
    echo -e "${BLUE}Release $LLVM_VERSION exists. Deleting existing ${OS_NAME} artifact if present...${NC}"
    # Delete the specific OS artifact if it exists
    gh release delete-asset "$LLVM_VERSION" "$NEW_ARTIFACT_NAME" --yes 2>/dev/null || true
    
    # Upload new artifact
    echo -e "${BLUE}Uploading $NEW_ARTIFACT_NAME to existing release...${NC}"
    gh release upload "$LLVM_VERSION" "$NEW_ARTIFACT_NAME" --clobber
else
    echo -e "${BLUE}Release $LLVM_VERSION does not exist. Creating new release...${NC}"
    gh release create "$LLVM_VERSION" "$NEW_ARTIFACT_NAME" \
        --title "LLVM $LLVM_VERSION" \
        --notes "LLVM build for $LLVM_VERSION"
fi

echo -e "${GREEN}✓ Successfully uploaded $NEW_ARTIFACT_NAME to release $LLVM_VERSION${NC}"

# Clean up renamed artifact
rm -f "$NEW_ARTIFACT_NAME"
