FROM oraclelinux:8-slim as acmesh_artifacts

# os related operations below:
RUN microdnf update --assumeyes \
    &&  microdnf clean all

RUN microdnf install --assumeyes wget tar gzip

# acme.sh related operations below:
ARG acmesh_version=master
ARG acmesh_link="https://github.com/acmesh-official/acme.sh/archive/${acmesh_version}.tar.gz"
ARG auto_upgrade=1
ARG acmesh_artifacts_dir=/opt/acme.sh

# Download and place acme.sh inside the container
RUN mkdir -p "${acmesh_artifacts_dir}" \
    && wget ${acmesh_link} -O "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && tar --extract --verbose --gunzip --strip 1 --file "/tmp/acmesh-${acmesh_version}.tar.gz" -C "${acmesh_artifacts_dir}" \
    && rm -rf "/tmp/acmesh-${acmesh_version}.tar.gz" \
    && "${acmesh_artifacts_dir}"/acme.sh --help

FROM oraclelinux:8-slim

ARG acmesh_version
ARG acmesh_link
ARG auto_upgrade
ARG acmesh_artifacts_dir

ENV LE_WORKING_DIR /acme.sh
ENV LE_CONFIG_HOME /acme.sh/config
ENV LE_CERT_HOME /acme.sh/cert-home

ENV ACMESH_INSTALL_DIR=/opt/acme.sh
ENV AUTO_UPGRADE $auto_upgrade

COPY --from=acmesh_artifacts "${acmesh_artifacts_dir}" "${acmesh_artifacts_dir}"

# Place the custom acme.sh executable script that does
# pre-execution actions and then calls acme.sh in the $ACMESH_INSTALL_DIR
ADD ./acme.sh /usr/local/bin/acme.sh

ADD ./entrypoint.sh /entrypoint.sh

VOLUME $LE_WORKING_DIR

# Install acme.sh
RUN microdnf install --assumeyes openssl socat \
    && microdnf clean all \
    && acme.sh --install --nocron

ENTRYPOINT ["/entrypoint.sh"]
