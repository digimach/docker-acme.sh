#!/usr/bin/env python3

# Modify the files as needed to prepare the stable branch based of main branch
import os
from ruamel.yaml import YAML

WORKFLOW_FILES=['docker_build.yaml', 'shell_linting.yaml']
WORKFLOW_FILES_DIR='.github/workflows'

def workflow_files():
    """
    Set the workflow files as needed
    """
    for workflow_file in WORKFLOW_FILES:
        yaml=YAML()
        yaml.width = 88
        yaml.indent(mapping=2, sequence=4, offset=2)
        workflow_file_path = os.path.join(WORKFLOW_FILES_DIR, workflow_file)

        with open(workflow_file_path, 'r') as stream:
            data = yaml.load(stream)

        data['on']['push']['branches'] = [os.environ.get("NEW_BRANCH")]
        data['on']['pull_request']['branches'] = [os.environ.get("NEW_BRANCH")]

        with open(workflow_file_path, 'w') as fp:
            yaml.dump(data, fp)


workflow_files()