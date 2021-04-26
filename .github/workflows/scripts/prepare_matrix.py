#!/usr/bin/env python3
import os
import json
import pprint

base_images = os.environ.get("BASE_IMAGES", "").split(",")

matrix = {}

matrix['job_name'] = []
matrix['include'] = []

for base_image in base_images:
    
    with open(os.path.join(base_image, 'env.json')) as env_fp:
        env_data = json.load(env_fp)
    
    for platform in env_data['supported_platforms']:
        job_name = "{0}-{1}".format(base_image, platform)
        matrix['job_name'].append(job_name)
        include_data = {}
        include_data['job_name'] = job_name
        include_data['base_image'] = base_image
        include_data['platform'] = platform
        matrix['include'].append(include_data)

if not base_images:
    print("::set-output name=skip_build::true")
else:
    print("::set-output name=skip_build::false")

pprint.pprint(matrix)
print("::set-output name=matrix::{0}".format(json.dumps(matrix)))