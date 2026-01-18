#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default branch (can be overridden by first argument)
LLVM_BRANCH="${1:-llvmorg-21.1.8}"

echo -e "${BLUE}=== LLVM Build Script ===${NC}"
echo -e "${BLUE}Branch: $LLVM_BRANCH${NC}\n"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LLVM_SOURCE_DIR="${SCRIPT_DIR}/llvm-project"
BUILD_DIR="${SCRIPT_DIR}/build"
INSTALL_DIR="${SCRIPT_DIR}/install"

# Step 1: Checkout LLVM from GitHub branch (depth 1)
echo -e "${BLUE}Step 1: Cloning LLVM $LLVM_BRANCH branch...${NC}"
if [ ! -d "$LLVM_SOURCE_DIR" ]; then
    git clone --depth 1 --branch "$LLVM_BRANCH" https://github.com/llvm/llvm-project.git "$LLVM_SOURCE_DIR"
    echo -e "${GREEN}✓ LLVM cloned successfully${NC}\n"
else
    echo -e "${GREEN}✓ LLVM source already exists${NC}\n"
fi

# Step 2: Build LLVM with CMake, Ninja, and Release configuration
echo -e "${BLUE}Step 2: Building LLVM...${NC}"

# cd into the llvm-project directory
cd "$LLVM_SOURCE_DIR"

# Run CMake with Ninja and Release configuration
echo "Running CMake..."
cmake -S llvm -B build -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="${SCRIPT_DIR}/install" \
    -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=OFF \
    -DCMAKE_INSTALL_RPATH="" \
    -DCMAKE_SKIP_INSTALL_RPATH=ON

# Build with Ninja
echo "Building with Ninja..."
ninja -C build
echo -e "${GREEN}✓ Build completed${NC}\n"

# Step 3: Install and copy bin and lib files
echo -e "${BLUE}Step 3: Installing LLVM...${NC}"
cmake --build build --target install
echo -e "${GREEN}✓ Installation completed${NC}\n"

# Step 4: Create tar.gz of install directory
echo -e "${BLUE}Step 4: Creating tar.gz archive...${NC}"
BRANCH_NAME=$(echo "$LLVM_BRANCH" | sed 's/\//-/g')
TAR_FILENAME="llvm-${BRANCH_NAME}-install.tar.gz"
cd ../
tar -czf "$TAR_FILENAME" install/
echo -e "${GREEN}✓ Archive created: $TAR_FILENAME${NC}\n"

#echo -e "${GREEN}=== Build complete! ===${NC}"
#echo "Install directory: $INSTALL_DIR"
#echo "Archive: $SCRIPT_DIR/$TAR_FILENAME"
