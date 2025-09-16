#!/bin/bash

# Local build script for Docker image
# Usage: ./scripts/build-local.sh [version]

set -e

# Default values
VERSION=${1:-latest}
IMAGE_NAME="static-redirect-page"
FULL_IMAGE_NAME="${IMAGE_NAME}:${VERSION}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Building local Docker image${NC}"
echo -e "Image: ${FULL_IMAGE_NAME}"
echo ""

# Build local image
echo -e "${YELLOW}Building image...${NC}"
docker build -t "${FULL_IMAGE_NAME}" .

echo -e "${GREEN}Successfully built:${NC}"
echo -e "  ${FULL_IMAGE_NAME}"
echo ""
echo -e "${YELLOW}To run the image:${NC}"
echo -e "  docker run -p 8080:8080 ${FULL_IMAGE_NAME}"
echo ""
echo -e "${YELLOW}To run with custom environment variables:${NC}"
echo -e "  docker run -p 8080:8080 \\"
echo -e "    -e REDIRECT_MESSAGE='Custom message' \\"
echo -e "    -e REDIRECT_LINK='https://example.com' \\"
echo -e "    ${FULL_IMAGE_NAME}"
echo ""
echo -e "${YELLOW}To test the image:${NC}"
echo -e "  curl http://localhost:8080"
