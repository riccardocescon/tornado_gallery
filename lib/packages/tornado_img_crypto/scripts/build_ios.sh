#!/bin/bash
# Build script for iOS/macOS testing

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building Tornado Crypto for iOS/macOS...${NC}"

# Create build directory
BUILD_DIR="build_ios"
if [ ! -d "$BUILD_DIR" ]; then
    mkdir "$BUILD_DIR"
fi

cd "$BUILD_DIR"

# Build for macOS first (easier to test)
echo -e "${YELLOW}Building for macOS...${NC}"
cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.14 \
    -DCMAKE_OSX_ARCHITECTURES="x86_64;arm64"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}CMake configuration successful for macOS${NC}"
    make
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}macOS build successful!${NC}"
        ls -la libtornado_crypto*
    else
        echo -e "${RED}macOS build failed!${NC}"
        exit 1
    fi
else
    echo -e "${RED}CMake configuration failed for macOS!${NC}"
    exit 1
fi

echo -e "${GREEN}Build completed successfully!${NC}"