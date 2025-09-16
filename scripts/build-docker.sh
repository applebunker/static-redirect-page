#!/bin/bash

# Build script for multi-architecture Docker images
# Usage: ./scripts/build-docker.sh [version] [registry]

set -e

# Default values
VERSION=${1:-latest}
REGISTRY=${2:-ghcr.io/applebunker}
IMAGE_NAME="static-redirect-page"
FULL_IMAGE_NAME="${REGISTRY}/${IMAGE_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building multi-architecture Docker image${NC}"
echo -e "Image: ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "Architectures: linux/amd64, linux/arm64, linux/arm/v7"
echo ""

# Check if Docker buildx is available
if ! docker buildx version > /dev/null 2>&1; then
    echo -e "${RED}Error: Docker buildx is not available${NC}"
    echo "Please install Docker with buildx support or enable buildx plugin"
    exit 1
fi

# Create and use buildx builder if it doesn't exist
if ! docker buildx inspect multiarch-builder > /dev/null 2>&1; then
    echo -e "${YELLOW}Creating buildx builder...${NC}"
    docker buildx create --name multiarch-builder --use
else
    echo -e "${YELLOW}Using existing buildx builder...${NC}"
    docker buildx use multiarch-builder
fi

# Build and push multi-architecture image
echo -e "${GREEN}Building and pushing multi-architecture image...${NC}"
docker buildx build \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --tag "${FULL_IMAGE_NAME}:${VERSION}" \
    --tag "${FULL_IMAGE_NAME}:latest" \
    --push \
    .

echo -e "${GREEN}Successfully built and pushed:${NC}"
echo -e "  ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "  ${FULL_IMAGE_NAME}:latest"
echo ""
echo -e "${YELLOW}To run the image:${NC}"
echo -e "  docker run -p 8080:8080 ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "${YELLOW}To run with custom environment variables:${NC}"
echo -e "  docker run -p 8080:8080 \\"
echo -e "    -e REDIRECT_MESSAGE='Custom message' \\"
echo -e "    -e REDIRECT_LINK='https://example.com' \\"
echo -e "    ${FULL_IMAGE_NAME}:${VERSION}"
