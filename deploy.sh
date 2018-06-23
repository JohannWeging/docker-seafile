#!/bin/bash
TAG_VERSION=${VERSION%.*}
docker push johannweging/seafile:${TAG_VERSION}

if [[ "${TAG_VERSION}" == "${LATEST}" ]]; then
    docker tag johannweging/seafile:${TAG_VERSION} johannweging/seafile:latest
    docker push johannweging/seafile:latest
fi
