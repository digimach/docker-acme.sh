#!/usr/bin/env python3
import subprocess
import os
import sys
import re

def push_manifest(manifests_data):

    if not manifests_data:
        print("** No manifest data to push")
        sys.exit(1)

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
    manifests_data = {}

    for tag in os.listdir('manifests'):
        manifest_name = "-".join(tag.split("-")[:3])
        manifests_data.setdefault(manifest_name, [])
        manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

    push_manifest(manifests_data)

def dynamic_os_manifest():
    manifests_data = {}

    for tag in os.listdir('manifests'):
        manifest_name = "-".join(tag.split("-")[:2])
        manifest_name = re.sub('^(.*)-master$', '\\1-latest', manifest_name)
        manifests_data.setdefault(manifest_name, [])
        manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)

    push_manifest(manifests_data)

def dynamic_manifest():
    manifests_data = {}

    for tag in os.listdir('manifests'):
        image_base_os = tag.split("-")[0]
        acmesh_version = tag.split("-")[1]

        if image_base_os == os.environ.get('LATEST_BASE_OS') and acmesh_version == os.environ.get('LATEST_ACMESH_VERSION'):
            manifest_name = "latest"
            manifests_data.setdefault(manifest_name, [])
            manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)
        elif image_base_os == os.environ.get('STABLE_BASE_OS') and acmesh_version == os.environ.get('STABLE_ACMESH_VERSION'):
            manifest_name = "stable"
            manifests_data.setdefault(manifest_name, [])
            manifests_data[manifest_name].append("--amend digimach/acme.sh:" + tag)
        else:
            continue

    push_manifest(manifests_data)

def main():
    if sys.argv[1] == 'dated_os':
        dated_os_manifest()
    elif sys.argv[1] == 'dynamic_os':
        dynamic_os_manifest()
    elif sys.argv[1] == 'dynamic':
        dynamic_manifest()
    
