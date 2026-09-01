#!/usr/bin/env bash
# Build and publish decidim-govbr image to GHCR
set -euo pipefail

IMAGE_NAME="ghcr.io/lpirola/decidim-govbr"
TAG="${1:-$(git describe --tags --always --dirty 2>/dev/null || git rev-parse --short HEAD)}"
FULL_IMAGE="${IMAGE_NAME}:${TAG}"

echo "=== Building ${FULL_IMAGE} ==="
docker build \
  --build-arg ENVIRONMENT=production \
  --tag "${FULL_IMAGE}" \
  --tag "${IMAGE_NAME}:latest" \
  .

echo ""
echo "=== Pushing to GHCR ==="
echo "Image: ${FULL_IMAGE}"
echo "Also tagged as: ${IMAGE_NAME}:latest"
echo ""

docker push "${FULL_IMAGE}"
docker push "${IMAGE_NAME}:latest"

echo ""
echo "✓ Successfully published!"
echo "  ${FULL_IMAGE}"
echo "  ${IMAGE_NAME}:latest"
