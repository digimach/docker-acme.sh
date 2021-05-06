# ACME Shell script: acme.sh Docker image
[![License](https://img.shields.io/github/license/KomailKanjee/docker-acme.sh?label=License)](./LICENSE.md)

[ACME Shell script: acme.sh](https://github.com/acmesh-official/acme.sh) available in 
Docker with compatibility and security in mind. This container holds the official 
upstream acme.sh artifacts.

Features:

* Multiple architectures 
* Multiple base operating systems
* Handles running as a non-root user
* Upstream OS patches applied to `latest` tag at build time


---
- [Usage](#usage)
  * [Basic invocation](#basic-invocation-)
  * [Running as a non-root user](#running-as-a-non-root-user)
  * [Example: Fulfilling a Certificate Signing Request (CSR)](#fulfilling-a-certificate-signing-request-(CSR))
  * [Running Arbitary Commands](#running-arbitary-commands)
  * [CMD, Entrypoint and Equivalent Calls](#cmd--entrypoint-and-equivalent-calls)
- [Images](#images)
  * [Base Images and Architectures](#base-images-and-architectures)
---


# Usage

## Basic Invocation

You can get the help menu by using a command such as:
```
docker run -ti digimach/acme.sh:latest acme.sh --help
```

By default the container runs as `uid:gid` `1001:1001`. Ensure the mounted volumes have appropriate permissions.

The container is built to allow a drop in replacement for `acme.sh` command running on
the host. The following two commands are equivalent, one running on the host with
`acme.sh` installed vs the other running from within the container:
```
LE_WORKING_DIR=/usr/lib/acmesh \
LE_CONFIG_HOME=/srv/acmesh/config \
LE_CERT_HOME=/srv/acmesh/cert-home \
acme.sh <acme.sh args>
```

```
docker run --interactive \
           --rm  \
           --tty \
           --env LE_WORKING_DIR=/srv/acmesh \
           --env LE_CONFIG_HOME=/srv/acmesh/data \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --name acmesh \
           --volume /srv/acmesh:/srv/acmesh/ \
           digimach/acme.sh:latest \
           <acme.sh args>
```

---

## Running as a Non-root User
You can limit the container's power by running it as a user with limited privileges by 
using a command such as:

```
docker run --interactive \
           --rm  \
           --tty \
           --env LE_WORKING_DIR=/srv/acmesh \
           --env LE_CONFIG_HOME=/srv/acmesh/data \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --name acmesh \
           --volume /srv/acmesh:/srv/acmesh/ \
           digimach/acme.sh:latest \
           <acme.sh args>
```
When running it with `--user` make sure the host is aware of the `uid:gid` and the user
has permission to read and write on the host directory.

It is highly recomended that you limit the containers privlieges by specifying a uid
and gid with limited access and privlieges.

---

## Fulfilling a Certificate Signing Request (CSR)
This is beyond the scope of this guide, but putting an example of fulfilling a
[CSR](https://en.wikipedia.org/wiki/Certificate_signing_request) and performing the
domain validation via DNS. 
```
docker run --interactive \
           --rm  \
           --tty \
           --env LE_WORKING_DIR=/srv/acmesh \
           --env LE_CONFIG_HOME=/srv/acmesh/data \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --user <uid>:<gid> \
           --volume /srv/acmesh:/srv/acmesh \
           digimach/acme.sh:latest \
           --signcsr \
           --csr /acmesh/cert-home/foo.mydomain.com.csr \
           --dns  dns_dynu \
           --challenge-alias foo.mydomain.com \
           --renew-hook /srv/acmesh/config/renew-hook.sh
```

---

## Running Arbitary Commands
To run commands inside the container the command has to be `_` followed by the command and arguments to run inside the container.

Here is an example of such command:
```
docker run --interactive \
           --rm  \
           --tty \
           --env LE_WORKING_DIR=/srv/acmesh \
           --env LE_CONFIG_HOME=/srv/acmesh/data \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --user <uid>:<gid> \
           --volume /srv/acmesh:/srv/acmesh \
           digimach/acme.sh:latest \
           _ ls -alrt /srv/acmesh
```

---

## CMD, Entrypoint and Equivalent Calls

This section explains the internals of the container and the CMD and ENTRYPOINT
parameters.

The following two calls are equivalent:
```
docker run -ti digimach/acme.sh:latest --help
```
```
docker run -ti digimach/acme.sh:latest _ /usr/local/bin/acme.sh --help
```
---

# Images

To simplify tagging scheme, the following nomenclature is applied to all published
tags. Depending on the end use case, you can choose the appropriate tag.

For clarification purposes, the term <b><i>latest</b></i> refers to latest at build
time and if the tag is not dated, it will be kept up to date.

If a base OS has multiple versions, every attempt will be made to keep using the latest
stable OS version. Build and support for older version maybe dropped if the upstream
OS does not provide any support. Please refer to the base OS release cycles for more
information.

| Tag                                          | Purpose                                                                                                                                                                                                                                                                                                          | Example                                                                                                                | Update Frequency | Branch |
|----------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|------------------|--------|
| latest                                       | The latest acme.sh with up to date OS patches based on latest Ubuntu base image.                                                                                                                                                                                                                                 | latest                                                                                                                 | Daily            |        |
| stable                                       | The latest stable release of acme.sh with up to date OS patches based on latest Ubuntu image.                                                                                                                                                                                                                    | stable                                                                                                                 | Daily            |        |
| \<base_os\>-latest                           | The latest release of acme.sh with up to date base OS patches.                                                                                                                                                                                                                                                   | * alpinelinux-latest<br>* debian-latest<br>* oraclelinux-latest<br>* ubunut-latest                                     | Daily            |        |
| \<base_os\>-\<acme.sh-version\>              | The release of acme.sh as embedded in the tag with up to date OS patches based on latest base OS image.<br>While the acme.sh version will remain static, this image tag will be regularly updated with latest OS patches applied.                                                                                | * alpinelinux-2.8.8<br>* debian-2.8.8<br>* oraclelinux-2.8.8<br>* ubunut-2.8.8                                         | Daily            |        |
| \<base_os\>-master-\<YYYYMMDD\>              | The latest release of acme.sh at <b><i>build time</b></i> with up to date OS patches based on latest base OS image.<br>The image tag is dated for downstream use cases where a static reference is required.<br>Keep in mind, these images do not have OS patches applied regularly nor is acme.sh ever updated. | * alpinelinux-master-20210425<br>* debian-master-20210425<br>* oraclelinux-master-20210425<br>* ubunut-master-20210425 | Once             |        |
| \<base_os\>-\<acme.sh-version\>-\<YYYYMMDD\> | The release of acme.sh as embedded in the tag with up to date OS patches based on latest base OS image.<br><br>The image tag is dated for downstream use cases where a static reference is required.<br><br>Keep in mind, these images do not have OS patches applied regularly nor is acme.sh ever updated.     | * alpinelinux-2.8.8-20210425<br>* debian-2.8.8-20210425<br>* oraclelinux-2.8.8-20210425<br>* ubunut-2.8.8-20210425     | Once             |        |


## Base Images and Architectures

Every attempt is made to cover popular distributions and architectures in published images. The following table captures what OS, base image tag and architecture are currently published.

| Image OS     | Base Image Tag | Archs                                                                                          |
|--------------|----------------|------------------------------------------------------------------------------------------------|
| Alpine Linux |     latest     | linux/arm64/v8, linux/amd64, linux/arm/v6, linux/arm/v7, linux/386, linux/ppc64le, linux/s390x |
| Debian       |   stable-slim  | linux/arm64/v8, linux/amd64, linux/386, linux/ppc64le, linux/s390x                             |
| Oracle Linux |     8-slim     | linux/arm64/v8, linux/amd64                                                                    |
| Ubuntu       |     latest     | linux/arm64/v8, linux/amd64, linux/arm/v7, linux/ppc64le, linux/s390x                          |