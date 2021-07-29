#!/usr/bin/env python3
import subprocess
import os
import sys
import re

class DockerTag(object):
    def __init__(self, docker_tag):
        docker_tag_split = docker_tag.split("-")
        self.base_os = docker_tag_split[0]
        self.acmesh_version = docker_tag_split[1]
        self.date_stamp = docker_tag_split[2]
        self.platform = docker_tag_split[3]
        self.latest_version = False
        self.stable_version = False
        self.latest_base_os = False
        self.stable_base_os = False

        if re.search('^.*-pr\d+', docker_tag):
            self.pr_build = True
        else:
            self.pr_build = False
        
        if self.acmesh_version == os.environ.get("LATEST_ACMESH_VERSION"):
            self.latest_version = True
            self.acmesh_version = "latest"
        elif self.acmesh_version == os.environ.get("STABLE_ACMESH_VERSION"):
            self.stable_version = True
        
        if self.base_os == os.environ.get("LATEST_BASE_OS"):
            self.latest_base_os = True
        elif self.base_os == os.environ.get("STABLE_BASE_OS"):
            self.stable_base_os = True

def push_manifest(manifests_data):

    if not manifests_data:
        print("** No manifest data to push")
        sys.exit(0)

    for manifest_name, ammend_tags in manifests_data.items():
        cmd = "docker manifest create digimach/acme.sh:{0} {1}".format(manifest_name, " ".join(ammend_tags))
        print(cmd)
        subprocess.check_call(cmd.split(" "))
        print("** Created manifest:", manifest_name)

        cmd = "docker manifest push digimach/acme.sh:{0}".format(manifest_name)
        print(cmd)
        subprocess.check_call(cmd.split(" "))
        print("** Pushed manifest:", manifest_name)

def dated_os_manifest():
    """
    Creates manifest <base_os>-<acmesh_version>-<date_stamp>
    """
    manifests_data = {}

    for tag in os.listdir('tags_meta'):
        tag_meta = DockerTag(tag)
        manifest_name = "{0}-{1}-{2}".format(tag_meta.base_os,
                                             tag_meta.acmesh_version,
                                             tag_meta.date_stamp)
        manifests_data.setdefault(manifest_name, [])
        manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

    push_manifest(manifests_data)

def dynamic_os_manifest():
    """
    Creates manifests:
        1. <base_os>-<acmesh_version>
        2. <base_os>-<latest|stable>
    """
    manifests_data = {}

    for tag in os.listdir('tags_meta'):
        tag_meta = DockerTag(tag)
        manifest_name = "{0}-{1}".format(tag_meta.base_os,
                                         tag_meta.acmesh_version)
        manifests_data.setdefault(manifest_name, [])
        manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

        if tag_meta.stable_version:
            manifest_name = "{0}-stable".format(tag_meta.base_os)
            manifests_data.setdefault(manifest_name, [])
            manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

    push_manifest(manifests_data)

def dynamic_manifest():
    """
    Creates manifest <latest|stable>
    """
    manifests_data = {}

    for tag in os.listdir('tags_meta'):
        tag_meta = DockerTag(tag)

        if tag_meta.latest_version and tag_meta.latest_base_os:
            manifest_name = "latest"
        elif tag_meta.stable_version and tag_meta.stable_base_os:
            manifest_name = "stable"
        else:
            continue

        manifests_data.setdefault(manifest_name, [])
        manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

    push_manifest(manifests_data)

def acmesh_versioned():
    """
    Creates manifest <acmesh_versioned> only for stable versions
    """
    manifests_data = {}

    for tag in os.listdir('tags_meta'):
        tag_meta = DockerTag(tag)

        if tag_meta.stable_base_os:
            manifest_name = tag_meta.acmesh_version
        else:
            continue

        manifests_data.setdefault(manifest_name, [])
        manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

    push_manifest(manifests_data)

def main():
    if sys.argv[1] == 'dated_os':
        dated_os_manifest()
    elif sys.argv[1] == 'dynamic_os':
        dynamic_os_manifest()
    elif sys.argv[1] == 'dynamic':
        dynamic_manifest()
    elif sys.argv[1] == 'acmesh_versioned':
        acmesh_versioned()
    
main()