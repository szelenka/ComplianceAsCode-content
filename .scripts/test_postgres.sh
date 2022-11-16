#!/bin/bash

IMAGE=crunchy-postgres-fips:14.5.0-ubuntu20.20221107-d0e6b73
XCCD_FILENAME=ssg-crunchy-data-postgres-ds.xml
XCCD_PROFILE=xccdf_org.ssgproject.content_profile_standard

CONTAINER_ID=$(docker run -i -d \
    -u 0:0 \
    -e LD_LIBRARY_PATH= \
    -e PGVER=14 \
    -e PGDATA=/pgdata/pg14 \
    -e PGLOG=/home/postgres/pg_log \
    -w /home/postgres \
    --platform linux/amd64 \
    --entrypoint cat \
    ${IMAGE}
)

function cleanup() {
    docker kill ${CONTAINER_ID}
}
trap cleanup EXIT

# copy XML in
docker cp build/build/${XCCD_FILENAME} ${CONTAINER_ID}:/home/postgres

docker exec ${CONTAINER_ID} config-mirror engci-maven 1
docker exec ${CONTAINER_ID} apt-get install -yqq libopenscap8
docker exec ${CONTAINER_ID} oscap info ${XCCD_FILENAME}

# W: probe_environmentvariable58: Entity has no value! -- is expected
# ref : https://github.com/OpenSCAP/openscap/commit/7c78b84dda1727c9baf096671e3a3b540cac9f95
docker exec ${CONTAINER_ID} oscap xccdf eval \
    --profile ${XCCD_PROFILE} \
    --results-arf arf.xml \
    --report report.html \
    /home/postgres/${XCCD_FILENAME}

# copy report out
rm -rf build/build/report.html
docker cp ${CONTAINER_ID}:/home/postgres/report.html build/build/report.html
