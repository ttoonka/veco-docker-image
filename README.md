# Docker Buildx Guide

This guide provides instructions on how to build and use Docker images locally with Docker Buildx.

## Building an Image

To build a Docker image with Docker Buildx, use the `docker buildx build` command with the `--platform` option to specify the platform, the `--load` option to load the image into the local Docker image repository, and the `-t` option to tag the image with a name. For example:

```bash
docker buildx build --platform linux/amd64 --load -t my-image-name .
docker run -it --rm --platform linux/amd64 my-image-name:latest bash