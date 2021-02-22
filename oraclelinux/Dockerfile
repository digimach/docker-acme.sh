FROM oraclelinux:8-slim as acmesh_artifacts

# os related operations below:
RUN microdnf update --assumeyes \
    &&  microdnf clean all

RUN microdnf install --assumeyes wget tar gzip

# acme.sh related operations below:
ARG acmesh_version=master
ARG acmesh_link="https://github.com/acmesh-official/acme.sh/archive/${acmesh_version}.tar.gz"
ARG acmesh_artifacts_dir=/opt/acmesh
ENV LE_WORKING_DIR /usr/lib/acmesh

# Download and place acme.sh inside the container
RUN mkdir -p "${acmesh_artifacts_dir}" \
    && wget ${acmesh_link} -O "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && tar --extract --verbose --gunzip --strip 1 --file "/tmp/acmesh-${acmesh_version}.tar.gz" -C "${acmesh_artifacts_dir}" \
    && rm -rf "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && "${acmesh_artifacts_dir}"/acme.sh --help \
    && "${acmesh_artifacts_dir}"/acme.sh --install --no-cron

FROM oraclelinux:8-slim

ARG auto_upgrade=0

ENV LE_WORKING_DIR /usr/lib/acmesh
ENV LE_CONFIG_HOME /acmesh/config
ENV LE_CERT_HOME /acmesh/cert-home

ENV ACMESH_ARTIFACTS_DIR="$acmesh_artifacts_dir"
ENV AUTO_UPGRADE "$auto_upgrade"

COPY --from=acmesh_artifacts "$acmesh_artifacts_dir" "$LE_WORKING_DIR"

# Place the custom acme.sh executable script that does
# pre-execution actions and then calls acme.sh in the $ACMESH_INSTALL_DIR
ADD acme.sh /usr/local/bin/acme.sh

ADD entrypoint.sh /entrypoint.sh

VOLUME $LE_CONFIG_HOME
VOLUME $LE_CERT_HOME

# Install acme.sh
RUN microdnf install --assumeyes openssl socat \
    && microdnf update --asumeyes \
    && microdnf clean all 

ENTRYPOINT ["/entrypoint.sh"]
