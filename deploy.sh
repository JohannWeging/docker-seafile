#!/bin/bash
TAG_VERSION="${VERSION%.*}"
docker tag "johannweging/seafile:${VERSION}" "johannweging/seafile:${TAG_VERSION}"
docker push "johannweging/seafile:${TAG_VERSION}"

if [[ "${VERSION}" == "${LATEST}" ]]; then
    docker tag "johannweging/seafile:${TAG_VERSION}" "johannweging/seafile:latest"
    docker push "johannweging/seafile:latest"
fi
