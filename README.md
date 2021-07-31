# ACME Shell script: acme.sh&#8203; Docker image
[![License](https://img.shields.io/github/license/Digimach/docker-acme.sh?label=License)](./LICENSE.md)
[![Docker Build](https://github.com/digimach/docker-acme.sh/actions/workflows/docker_build.yaml/badge.svg)](https://github.com/digimach/docker-acme.sh/actions/workflows/docker_build.yaml)
[![Shell Linting](https://github.com/digimach/docker-acme.sh/actions/workflows/shell_linting.yaml/badge.svg)](https://github.com/digimach/docker-acme.sh/actions/workflows/shell_linting.yaml)

[![Docker Pulls](https://img.shields.io/docker/pulls/digimach/acme.sh)](https://hub.docker.com/repository/docker/digimach/acme.sh)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/digimach/acme.sh/latest?label=latest%20image%20size)](https://hub.docker.com/repository/docker/digimach/acme.sh)

[ACME Shell script: acme.sh](https://github.com/acmesh-official/acme.sh) available in 
Docker with compatibility and security in mind. This container holds the official 
upstream acme.sh&#8203; artifacts.

Features:
* Available in multiple CPU architectures 
* Multiple base operating systems
* Handles running as a non-root user
* OS updates applied to tags: **latest**, **stable** and **active**<sup>[1](#life-cycle-footnote)</sup>. acme.sh&#8203; version
* Renewal daemon to check and renew certificates automatically

---
* [Usage](#usage)
  + [Docker Tags](#docker-tags)
  + [acme.sh&#8203; Command Line](#acmesh--8203--command-line)
  + [Renewal Daemon](#renewal-daemon)
* [Parameters](#parameters)
  + [General](#general)
  + [Renewal Daemon](#renewal-daemon-1)
  + [Advanced](#advanced)
* [User / Group Identifiers](#user---group-identifiers)
* [Examples](#examples)
  + [Running as root user](#running-as-root-user)
  + [Fulfilling a Certificate Signing Request (CSR)](#fulfilling-a-certificate-signing-request--csr-)
  + [Running Arbitary Commands](#running-arbitary-commands)
* [Published Images](#published-images)
* [Base Images and Architectures](#base-images-and-architectures)

---

## Usage
### Docker Tags

There are **three types** of tags that are undated and/or unnumbered, which means they
can be updated to point to new Docker images.

| Tag | Description | Base Image | Life Cycle |
| :--- | :--- | :---: | :--- |
| `latest` | Latest source available from acme.sh&#8203; with latest OS updates | `ubuntu:latest` | Built daily |
| `stable` | Latest released version available from acme.sh&#8203; with latest OS updates | `ubuntu:20.04` | Built at least once a month |
| `2.9.0` | acme.sh&#8203; version `2.9.0` with latest OS updates | `ubuntu:20.04` | Built at least once a month |
| `2.8.9` | acme.sh&#8203; version `2.8.9` with latest OS updates | `ubuntu:20.04` | Built at least once a month |

* For production application, it is recommended to use the `stable` tag.
* To use a different base image OS prefix any of the above tags with `<base_image_os>-`. For example `rockylinux-latest`, `amazonlinux-stable` or `alpinelinux-2.9.0`. See [Base Images and Architectures](#base-images-and-architectures) for a list of available base OS.
* See [Published Images](#published-images) for other tags that are available.

### acme.sh&#8203; Command Line
```
docker run --interactive \
           --rm  \
           --tty \
           --env PUID=1001 \
           --env PGUID=1001 \
           --env LE_CONFIG_HOME=/srv/acmesh/config \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --volume /srv/acmesh/config:/srv/acmesh/config \
           --volume /srv/acmesh/cert-home:/srv/acmesh/cert-home \
           digimach/acme.sh:latest \
           acme.sh <acme.sh args>
```

### Renewal Daemon
Use the same parameters and their value as acme.sh&#8203; Command Line with the additional parameters shown below.
```
docker run --interactive \
           --detach  \
           --name acmesh-renewal-daemon \
           --env PUID=1001 \
           --env PGUID=1001 \
           --env LE_CONFIG_HOME=/srv/acmesh/config \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --env LE_LOG_DIR=/srv/acmesh/logs \
           --env ACMESH_DAEMON=1 \
           --env RENEWAL_CHECK_FREQUENCY=1h \
           --volume /srv/acmesh/config:/srv/acmesh/config \
           --volume /srv/acmesh/cert-home:/srv/acmesh/cert-home \
           --volume /srv/acmesh/logs:/srv/acmesh/logs \
           digimach/acme.sh:latest
```

It is important to kill the container running the renewal daemon gracefully.
```
docker kill -s SIGTERM acmesh-renewal-daemon
```
The above will kill the daemon if it is just waiting for the next renewal check and let it finish the renewal check and issue process if its already running.

---

## Parameters
### General
The acme.sh&#8203; container can be configured at run time by passing parameters.

| Parameters | Function |
|---|---|
| `-e LE_CONFIG_HOME=/acmesh/config` | Sets the directory in which acme.sh&#8203; will store configuration. |
| `-e LE_CERT_HOME=/acmesh/cert-home` | Sets the directory which stores certificates and configuration related to signing of certificates. This directory if separate from other directories used by acme.sh&#8203; can be used to distribute signed certificates if there are no private keys. |
| `-e PUID=1001` | See User/Group settings |
| `-e PGID=1001` | See User/Group settings |
| `-v /acmesh/config` | acme.sh&#8203; config goes here as defined by `LE_CONFIG_HOME` variable. |
| `-v /acmesh/cert-home` | acme.sh&#8203; stores the certificates here as defined by  `LE_CERT_HOME` variable. |

### Renewal Daemon
These parameters are in addition to the above parameters and only apply to the operations of renewal daemon.
| Parameters | Function |
|---|---|
| `-e ACMESH_DAEMON=0` | If launching the container as a renewal daemon set this to `1`. |
| `-e RENEWAL_CHECK_FREQUENCY=1h` | The frequency with which renewal checks should be performed. The unit of time can be provided eg `300s`, `60m`, `2h`, `1d` |
| `-e LE_LOG_DIR=/acmesh/logs` | Set the directory where logs are stored for the acme.sh&#8203; renewal daemon. |
| `-e S6_LOGGING_SCRIPT=n30 s10000000 S15000000 T !'gzip -nq9'` | Configure parameter for [`s6-log`](https://skarnet.org/software/s6/s6-log.html) that defines what to log, where, and how.  |
| `-v /acmesh/logs` | The renewal daemon stores the logs in this directory defined by  `LE_LOG_DIR` variable. |

### Advanced
These are advanced parameters that are only to be used when needed.
| Parameters | Function |
|---|---|
| `-e LE_WORKING_DIR=/usr/lib/acmesh` | Set the directory in which acme.sh&#8203; is installed and also used by it to look for deploy, dnsapi and notify hooks. The container already has acme.sh&#8203; installed in the directory at build time which is set to `/usr/lib/acmesh` by default. |
| `-e AUTO_UPGRADE=0` | If set to `1` acme.sh&#8203; will upgrade itself. **It is not recommended to have acme.sh&#8203; auto upgrade itself.** Instead, update the container by downloading the appropriate tag eg `latest`. |
| `-e S6_BEHAVIOUR_IF_STAGE2_FAILS=2` | Sets how s6 behaves if `fix-attrs` or `cont-init` fails. See [Customizing s6 behaviour](https://github.com/just-containers/s6-overlay#customizing-s6-behaviour) |

---

## User / Group Identifiers
By default the container runs the command `uid1001` and `gid:1001`. When mounting volumes (using `-v`/`--volume`) permission issues can arrise. This can be fixed by having the container execute the command as a user who has read and write permisions on the mounted host volume.

---

## Examples

The container is built to allow a drop in replacement for `acme.sh` command running on
the host. The following two commands are equivalent, one running on the host with
`acme.sh` installed vs the other running from within the container - both running as `uid:1001` and `gid:1001`:
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
           --env PUID=1001 \
           --env PGUID=1001 \
           --env LE_CONFIG_HOME=/srv/acmesh/config \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --name acmesh \
           --volume /srv/acmesh:/srv/acmesh/ \
           digimach/acme.sh:latest \
           acme.sh \
           <acme.sh args>
```

### Running as root user
To overide the default behaviour of the container to run as a limited user set the `PUID` and `GUID` variable as `0`.

**This is not recomended and should be avoided at all cost.**

```
docker run --interactive \
           --rm  \
           --tty \
           --env PUID=0 \
           --env PGUID=0 \
           --env LE_CONFIG_HOME=/srv/acmesh/config \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --name acmesh \
           --volume /srv/acmesh:/srv/acmesh/ \
           digimach/acme.sh:latest \
           acme.sh \
           <acme.sh args>
```

### Fulfilling a Certificate Signing Request (CSR)
This is beyond the scope of this guide, but putting an example of fulfilling a
[CSR](https://en.wikipedia.org/wiki/Certificate_signing_request) and performing the
domain validation via DNS. 

In the example below, the CSR is placed in `/srv/acmesh/foo.mydomain.com.csr` which will be copied over to `/srv/acmesh/cert-home/foo.mydomain.com/foo.mydomain.com.csr` when the `--signcsr` command is issued after which the CSR can be removed from `/srv/acmesh/foo.mydomain.com.csr`

The example also makes use of `--renew-hook` which will run the script after a successful issue/renewal of the certificate.

```
docker run --interactive \
           --rm  \
           --tty \
           --env LE_CONFIG_HOME=/srv/acmesh/config \
           --env LE_CERT_HOME=/srv/acmesh/cert-home \
           --user <uid>:<gid> \
           --volume /srv/acmesh:/srv/acmesh \
           digimach/acme.sh:latest \
           acme.sh \
           --signcsr \
           --csr /srv/acmesh/foo.mydomain.com.csr \
           --dns  dns_clouddns \
           --challenge-alias foo.mydomain.com \
           --renew-hook /srv/acmesh/config/renew-hook.sh
```

### Running Arbitary Commands

```
docker run --interactive \
           --rm  \
           --tty \
           --user <uid>:<gid> \
           --volume /srv/acmesh:/srv/acmesh \
           digimach/acme.sh:latest \
           ls -alrt /srv/acmesh
```

---

## Published Images

To simplify tagging scheme, the following nomenclature is applied to all published
tags. Depending on the end use case, you can choose the appropriate tag.

For clarification purposes, the term **latest** refers to latest at build
time and if the tag is not dated, it will be kept up to date at the frequency stated.

Additionally, the term **stable** refers to the stable version of acme.sh&#8203 which
is equal to the latest **released** version. If the tag contains stable and is not
dated it is going to get up to date OS patches at the frequency stated.

If a base OS has multiple versions, every attempt will be made to keep using the latest
stable OS version. Build and support for older version maybe dropped if the upstream
OS does not provide any support. Please refer to the base OS release cycles for more
information.

| Tag | Purpose | Example | Update Frequency | Branch |
|---|---|---|---|---|
| latest | The latest acme.sh&#8203; with up to date OS patches based on latest Ubuntu base image. | latest | Daily | main |
| stable | The latest stable release of acme.sh&#8203; with up to date OS patches based on latest Ubuntu image. | stable | At least once a month | stable-2.9.0 |
| \<acme.sh-version\> | The release of acme.sh&#8203; as embedded in the tag with up to date OS patches based on latest Ubuntu image. | 2.9.0 | See Release Life Cycle | stable-\<acme.sh-version\> |
| \<base_os\>-latest | The latest build of acme.sh&#8203; with up to date base OS patches. | - alpinelinux-latest<br> - amazonlinux-latest<br> - oraclelinux-latest<br> - rockylinux-latest<br> - ubunut-latest | Daily | main |
| \<base_os\>-stable | The most recent stable release of acme.sh&#8203; with up to date base OS patches. | - alpinelinux-stable<br> - amazonlinux-stable<br> - oraclelinux-stable<br> - rockylinux-stable<br> - ubunut-stable | At least once a month | main |
| \<base_os\>-\<acme.sh-version\> | The release of acme.sh&#8203; as embedded in the tag with up to date OS patches based on latest base OS image.<br>While the acme.sh&#8203; version will remain static, this image tag will be regularly updated with latest OS patches applied. | - alpinelinux-2.9.0<br> - amazonlinux-2.9.0<br> - oraclelinux-2.9.0<br> - rockylinux-2.9.0<br> - ubunut-2.9.0 | See Release Life Cycle | stable-\<acme.sh-version\> |
| \<base_os\>-latest-\<YYYYMMDD\> | The latest build of acme.sh&#8203; at <b><i>build time</b></i> with up to date OS patches based on latest base OS image.<br>The image tag is dated for downstream use cases where a static reference is required.<br>Keep in mind, these images do not have OS patches applied regularly nor is acme.sh&#8203; ever updated. | - alpinelinux-latest-20210425<br> - amazonlinux-latest-20210425 - oraclelinux-latest-20210425<br> - rockylinux-latest-20210425<br> - ubunut-latest-20210425 | Once | main |
| \<base_os\>-\<acme.sh-version\>-\<YYYYMMDD\> | The release of acme.sh&#8203; as embedded in the tag with up to date OS patches based on latest base OS image.<br><br>The image tag is dated for downstream use cases where a static reference is required.<br><br>Keep in mind, these images do not have OS patches applied regularly nor is acme.sh&#8203; ever updated. | - alpinelinux-2.9.0-20210425<br> - amazonlinux-2.9.0-20210425 - oraclelinux-2.9.0-20210425<br> - rockylinux-2.9.0-20210425<br> - ubunut-2.9.0-20210425 | Once | stable-\<acme.sh-version\> |

---

## Base Images and Architectures

Every attempt is made to cover popular distributions and architectures in published images. The following table captures what OS, base image tag and architecture are currently published.

| Image OS     | Tag Prefix | Archs                                                                                          |
|--------------|----------------|------------------------------------------------------------------------------------------------|
| Alpine Linux | `alpinelinux-` | linux/arm64/v8, linux/amd64, linux/arm/v6, linux/arm/v7, linux/386, linux/ppc64le, linux/s390x |
| Amazon Linux | `amazonlinux-` | linux/arm64/v8, linux/amd64 |
| Rocky Linux | `rockylinux-` | linux/arm64/v8, linux/amd64 |
| Ubuntu | `ubuntu-`<sup>[2](#ubuntu-latest-stable-ta)</sup> | linux/arm64/v8, linux/amd64, linux/arm/v7, linux/ppc64le, linux/s390x |

---

<a name="life-cycle-footnote">1</a>: See life cycle for more information.

<a name="ubuntu-latest-stable-tag">2</a>: Ubuntu base image is also used on `latest`, `stable` and acme.sh&#8203; versioned tags.