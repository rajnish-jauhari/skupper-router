#!/bin/bash

# Define the platforms for which we want to build the image
PLATFORMS="linux/amd64,linux/arm64,linux/s390x"
IMAGE_NAME="quay.io/rhn-support-rjauhari/skupper-router"
IMAGE_TAG="main"

# Ensure Docker Buildx is enabled
DOCKER_BUILDX=$(docker buildx version)

if [[ -z "$DOCKER_BUILDX" ]]; then
  echo "Error: Docker Buildx is not available. Make sure Docker Desktop is up and Buildx is enabled."
  exit 1
fi

# Enable QEMU for cross-platform builds (use correct platform)
echo "Setting up QEMU emulation for cross-platform builds..."
docker run --rm --privileged --platform linux/arm64 multiarch/qemu-user-static --reset -p yes

# Create and use a new builder (if not already created)
docker buildx create --use

# Build the image for the specified platforms using the custom Containerfile
echo "Building multi-architecture image for platforms: $PLATFORMS"
docker buildx build --platform $PLATFORMS -f Containerfile -t "$IMAGE_NAME:$IMAGE_TAG" --push .

# Check if the build was successful
if [ $? -eq 0 ]; then
  echo "Multi-architecture image successfully built and pushed to the registry."
else
  echo "Error: Something went wrong with the build process."
  exit 1
fi