#!/bin/bash

# Push script for GitHub Container Registry
# Usage: ./scripts/push-to-ghcr.sh [version] [github-username]

set -e

# Default values
VERSION=${1:-latest}
GITHUB_USERNAME=${2:-applebunker}
REGISTRY="ghcr.io"
IMAGE_NAME="static-redirect-page"
FULL_IMAGE_NAME="${REGISTRY}/${GITHUB_USERNAME}/${IMAGE_NAME}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Pushing to GitHub Container Registry${NC}"
echo -e "Image: ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "Registry: ${REGISTRY}"
echo ""

# Check if user is logged in to GitHub Container Registry
if ! docker info | grep -q "ghcr.io"; then
    echo -e "${YELLOW}You need to login to GitHub Container Registry first:${NC}"
    echo -e "  echo \$GITHUB_TOKEN | docker login ghcr.io -u \$GITHUB_USERNAME --password-stdin"
    echo ""
    echo -e "${BLUE}To get a GitHub token:${NC}"
    echo -e "  1. Go to https://github.com/settings/tokens"
    echo -e "  2. Generate a new token with 'write:packages' permission"
    echo -e "  3. Set GITHUB_TOKEN environment variable"
    echo ""
    read -p "Do you want to login now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -z "$GITHUB_TOKEN" ]; then
            echo -e "${RED}Error: GITHUB_TOKEN environment variable is not set${NC}"
            exit 1
        fi
        echo "$GITHUB_TOKEN" | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin
    else
        echo -e "${RED}Login required to push to GitHub Container Registry${NC}"
        exit 1
    fi
fi

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
echo -e "${GREEN}Building and pushing multi-architecture image to GitHub Container Registry...${NC}"
docker buildx build \
    --platform linux/amd64,linux/arm64,linux/arm/v7 \
    --tag "${FULL_IMAGE_NAME}:${VERSION}" \
    --tag "${FULL_IMAGE_NAME}:latest" \
    --push \
    .

echo -e "${GREEN}Successfully pushed to GitHub Container Registry:${NC}"
echo -e "  ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "  ${FULL_IMAGE_NAME}:latest"
echo ""
echo -e "${YELLOW}To pull and run the image:${NC}"
echo -e "  docker pull ${FULL_IMAGE_NAME}:${VERSION}"
echo -e "  docker run -p 8080:8080 ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "${YELLOW}To run with custom environment variables:${NC}"
echo -e "  docker run -p 8080:8080 \\"
echo -e "    -e REDIRECT_MESSAGE='Custom message' \\"
echo -e "    -e REDIRECT_LINK='https://example.com' \\"
echo -e "    ${FULL_IMAGE_NAME}:${VERSION}"
echo ""
echo -e "${BLUE}Image will be available at:${NC}"
echo -e "  https://github.com/${GITHUB_USERNAME}/packages"
