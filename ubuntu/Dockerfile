FROM ubuntu:latest as acmesh_artifacts

# os related operations below:
RUN apt-get --yes update \
    && apt-get --yes upgrade

RUN apt-get --yes install curl gzip tar xz-utils

# Set ARGS
ARG acmesh_version=master
ARG acmesh_link="https://github.com/acmesh-official/acme.sh/archive/${acmesh_version}.tar.gz"
ARG acmesh_artifacts_dir=/opt/acmesh
ARG s6_overlay_version=3.1.2.1

# Download and place acme.sh inside the container
RUN mkdir -p "${acmesh_artifacts_dir}" \
    && curl --location --remote-header-name --output "/tmp/acmesh-${acmesh_version}.tar.gz" ${acmesh_link} \
    && tar --extract --verbose --gunzip --strip 1 --file "/tmp/acmesh-${acmesh_version}.tar.gz" -C "${acmesh_artifacts_dir}" \
    && rm -rf "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && "${acmesh_artifacts_dir}"/acme.sh --help

# Download and install s6-overlay-builder
RUN mkdir -p /s6-overlay-install
# ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-noarch.tar.xz /tmp
# RUN tar --directory /s6-artifact -Jxpf /tmp/s6-overlay-noarch.tar.xz
# ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-x86_64.tar.xz /tmp
# RUN tar --directory /s6-artifact -Jxpf /tmp/s6-overlay-x86_64.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C /s6-overlay-install -Jxpf /tmp/s6-overlay-noarch.tar.xz
RUN ls -alrt /s6-overlay-install
ADD https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C /s6-overlay-install -Jxpf /tmp/s6-overlay-x86_64.tar.xz
RUN ls -alrt /s6-overlay-install

FROM ubuntu:latest

ARG acmesh_artifacts_dir=/opt/acmesh
ARG auto_upgrade=0
ARG acme_working_dir=/usr/lib/acmesh

COPY --from=acmesh_artifacts "$acmesh_artifacts_dir" "$acmesh_artifacts_dir"
COPY --from=acmesh_artifacts "/s6-overlay-install/" "/"

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
RUN apt-get update \
    && apt-get install --yes bash curl git openssl socat \
    && apt-get remove --yes sqlite3 \
    && apt-get --yes upgrade \
    && apt-get --yes autoremove \
    && apt-get --yes purge \
    && apt-get --yes clean

RUN cd "$acmesh_artifacts_dir" || exit \
    && ./acme.sh --install --no-cron --no-profile --auto-upgrade 0 \
    && chmod -R +x "$LE_WORKING_DIR" \
    && ls -alrt /init

COPY root/ /

VOLUME $LE_CONFIG_HOME
VOLUME $LE_CERT_HOME
VOLUME $LE_LOG_DIR

ENTRYPOINT ["/init"]
CMD [""]