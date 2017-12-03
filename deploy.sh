#!/bin/bash
docker push johannweging/seafile:${VERSION}

if [[ "${VERSION}" == "${LATEST}" ]]; then
    docker tag johannweging/seafile:${VERSION} johannweging/seafile:latest
    docker push johannweging/seafile:latest
fi
