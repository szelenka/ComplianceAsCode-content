#!/bin/bash

set -e

TAG=oscap:$(date -u +%Y%m%d%H%M)

docker build \
    --platform linux/amd64 \
    --file Dockerfiles/ubuntu \
    --tag ${TAG} \
    .

CONTAINER_ID=$(docker run -i -d \
    -e BUILD_JOBS=6 \
    -w /home/oscap/content/build \
    --platform linux/amd64 \
    --cap-drop=all \
    --entrypoint cat \
    ${TAG} 
)

function cleanup() {
    docker kill ${CONTAINER_ID}
    # docker rmi -f ${TAG}
}
trap cleanup EXIT

docker exec ${CONTAINER_ID} bash -c 'cmake \
    -DSSG_PRODUCT_DEFAULT:BOOL=OFF \
    -DSSG_PRODUCT_CRUNCHYDATAPOSTGRES:BOOL=ON \
    -G Ninja ../ ;'
docker exec ${CONTAINER_ID} bash -c 'ninja -j ${BUILD_JOBS} ;'
docker exec ${CONTAINER_ID} bash -c 'ctest \
    --output-on-failure \
    --exclude-regex ^stable-profiles$ \
    --exclude-regex validate-parse-affected \
    -LE quick \
    -j ${BUILD_JOBS} ;'

rm -rf ${PWD}/build/build
docker cp ${CONTAINER_ID}:/home/oscap/content/build/ ${PWD}/build/
