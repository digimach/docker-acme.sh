FROM ubuntu:latest as acmesh_artifacts

# os related operations below:
RUN apt-get --yes update \
    && apt-get --yes upgrade

RUN apt-get --yes install curl gzip tar xz-utils

# Set ARGS
ARG acmesh_version=master
ARG acmesh_link="https://github.com/acmesh-official/acme.sh/archive/${acmesh_version}.tar.gz"
ARG acmesh_artifacts_dir=/opt/acmesh

# Download and place acme.sh inside the container
RUN mkdir -p "${acmesh_artifacts_dir}" \
    && curl --location --remote-header-name --output "/tmp/acmesh-${acmesh_version}.tar.gz" ${acmesh_link} \
    && tar --extract --verbose --gunzip --strip 1 --file "/tmp/acmesh-${acmesh_version}.tar.gz" -C "${acmesh_artifacts_dir}" \
    && rm -rf "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && "${acmesh_artifacts_dir}"/acme.sh --help

#--------------------------------------------#

FROM ghcr.io/linuxserver/baseimage-alpine:3.16

ARG acmesh_artifacts_dir=/opt/acmesh
ARG auto_upgrade=0
ARG acme_working_dir=/usr/lib/acmesh
ARG acmesh_version=master
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="digimach"

COPY --from=acmesh_artifacts "$acmesh_artifacts_dir" "$acmesh_artifacts_dir"

# Set runtime variables
ENV LE_WORKING_DIR="$acme_working_dir"
ENV LE_CONFIG_HOME=/acmesh/config
ENV LE_CERT_HOME=/acmesh/cert-home
ENV LE_LOG_DIR=/acmesh/logs

ENV AUTO_UPGRADE "$auto_upgrade"

ENV PUID=1001
ENV PGID=1001

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

# Install acme.sh
RUN echo "**** install runtime packages ****" && \
    apk add --no-cache bash curl git openssl socat && \
    echo "**** cleanup ****" && \
    rm -rf \
        /tmp/* \
        /root/.cache \
        /root/.cargo

COPY root/ /

VOLUME $LE_CONFIG_HOME
VOLUME $LE_CERT_HOME
VOLUME $LE_LOG_DIR
