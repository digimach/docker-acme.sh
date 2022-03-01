FROM alpine:latest as acmesh_artifacts

# os related operations below:
RUN apk -U --no-cache upgrade

RUN apk add --no-cache curl gzip tar util-linux xz

# Set ARGS
ARG acmesh_version=master
ARG acmesh_link="https://github.com/acmesh-official/acme.sh/archive/${acmesh_version}.tar.gz"
ARG acmesh_artifacts_dir=/opt/acmesh
ARG s6_artifacts_dir=/opt/s6
ARG s6_overlay_version=3.0.0.2-2

# Download and place acme.sh inside the container
RUN mkdir -p "${acmesh_artifacts_dir}" \
    && curl --location --remote-header-name --output "/tmp/acmesh-${acmesh_version}.tar.gz" ${acmesh_link} \
    && tar --extract --verbose --gunzip --strip 1 --file "/tmp/acmesh-${acmesh_version}.tar.gz" -C "${acmesh_artifacts_dir}" \
    && rm -rf "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && "${acmesh_artifacts_dir}"/acme.sh --help

# Download s6-overlay artifacts and checksum files
RUN mkdir -p ${s6_artifacts_dir} \
    && CPU_ARCH=$(lscpu | grep Architecture | cut -f2 -d":" | xargs) \
    && echo "CPU ARCH is: ${CPU_ARCH}" \
    && curl --fail --location --remote-header-name --output "/tmp/s6-overlay-noarch.tar.xz" \
        https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-noarch-${s6_overlay_version}.tar.xz \
    && curl --fail --location --remote-header-name --output "/tmp/s6-overlay-noarch.tar.xz.sha256" \
        https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-noarch-${s6_overlay_version}.tar.xz.sha256 \
    && curl --fail --location --remote-header-name --output "/tmp/s6-overlay.tar.xz" \
        https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-x86_64-${s6_overlay_version}.tar.xz \
    && curl --fail --location --remote-header-name --output "/tmp/s6-overlay.tar.xz.sha256" \
        https://github.com/just-containers/s6-overlay/releases/download/v${s6_overlay_version}/s6-overlay-${CPU_ARCH}-${s6_overlay_version}.tar.xz.sha256

# Perform checksum on s6-overlay artifacts
RUN echo "$(cat /tmp/s6-overlay-noarch.tar.xz.sha256 | cut -f1 -d" ")  /tmp/s6-overlay-noarch.tar.xz" | sha256sum -cs 
RUN echo "$(cat /tmp/s6-overlay.tar.xz.sha256 | cut -f1 -d" ")  /tmp/s6-overlay.tar.xz" | sha256sum -cs 

# Extract s6-overlay artifacts
RUN tar -C ${s6_artifacts_dir} --xz --extract --preserve-permissions --file /tmp/s6-overlay-noarch.tar.xz \
    && tar -C ${s6_artifacts_dir} --xz --extract --preserve-permissions --file /tmp/s6-overlay.tar.xz

FROM alpine:latest

ARG acmesh_artifacts_dir=/opt/acmesh
ARG auto_upgrade=0
ARG acme_working_dir=/usr/lib/acmesh
ARG s6_artifacts_dir=/opt/s6

COPY --from=acmesh_artifacts "$acmesh_artifacts_dir" "$acmesh_artifacts_dir"
COPY --from=acmesh_artifacts "$s6_artifacts_dir" "/"

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
RUN apk add --no-cache bash wget curl git openssl shadow socat \
    && apk -U --no-cache upgrade \
    && cd "$acmesh_artifacts_dir" || exit \
    && ./acme.sh --install --no-cron --no-profile --auto-upgrade 0 \
    && chmod -R +x "$LE_WORKING_DIR"

COPY root/ /

VOLUME $LE_CONFIG_HOME
VOLUME $LE_CERT_HOME
VOLUME $LE_LOG_DIR

ENTRYPOINT ["/init"]
