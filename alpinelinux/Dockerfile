FROM alpine:latest as acmesh_artifacts

# os related operations below:
RUN apk -U --no-cache upgrade

RUN apk add --no-cache curl gzip tar 

# acme.sh related operations below:
ARG acmesh_version=master
ARG acmesh_link="https://github.com/acmesh-official/acme.sh/archive/${acmesh_version}.tar.gz"
ARG acmesh_artifacts_dir=/opt/acmesh

# Download and place acme.sh inside the container
RUN mkdir -p "${acmesh_artifacts_dir}" \
    && curl --location --remote-header-name --output "/tmp/acmesh-${acmesh_version}.tar.gz" ${acmesh_link} \
    && tar --extract --verbose --gunzip --strip 1 --file "/tmp/acmesh-${acmesh_version}.tar.gz" -C "${acmesh_artifacts_dir}" \
    && rm -rf "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && "${acmesh_artifacts_dir}"/acme.sh --help

FROM alpine:latest

ARG acmesh_artifacts_dir=/opt/acmesh
ARG auto_upgrade=0
ARG acme_working_dir=/usr/lib/acmesh

ENV LE_WORKING_DIR "$acme_working_dir"
ENV LE_CONFIG_HOME /acmesh/config
ENV LE_CERT_HOME /acmesh/cert-home

ENV AUTO_UPGRADE "$auto_upgrade"

COPY --from=acmesh_artifacts "$acmesh_artifacts_dir" "$acmesh_artifacts_dir"

# Place the custom acme.sh executable script that does
# pre-execution actions and then calls acme.sh in the $ACMESH_INSTALL_DIR
ADD acme.sh /usr/local/bin/acme.sh

ADD entrypoint.sh /entrypoint.sh

VOLUME $LE_CONFIG_HOME
VOLUME $LE_CERT_HOME

# Install acme.sh
RUN apk add --no-cache bash wget curl git openssl socat \
    && apk -U --no-cache upgrade \
    && cd "$acmesh_artifacts_dir" || exit \
    && ./acme.sh --install --no-cron --no-profile --auto-upgrade=0

ENTRYPOINT ["/entrypoint.sh"]
