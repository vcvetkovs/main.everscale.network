#!/bin/bash -eE

DEBUG=${DEBUG:-no}

if [ "$DEBUG" = "yes" ]; then
    set -x
fi

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
export SCRIPT_DIR
SRC_TOP_DIR=$(cd "${SCRIPT_DIR}/../" && pwd -P)
export SRC_TOP_DIR
export DOCKER_COMPOSE_DIR="${SRC_TOP_DIR}/docker-compose"
export ENABLE_VALIDATE="yes"
export CLEAN_HOST=${CLEAN_HOST:-yes}
export COMPOSE_HTTP_TIMEOUT=120 # in sec, 60 sec - default
HOSTNAME=$(hostname -f)
export EVER_NODE_GITHUB_REPO="https://github.com/everx-labs/ever-node.git"
export EVER_NODE_GITHUB_COMMIT_ID="master"
export EVER_NODE_TOOLS_GITHUB_REPO="https://github.com/everx-labs/ever-node-tools.git"
export EVER_NODE_TOOLS_GITHUB_COMMIT_ID="master"
export EVER_CLI_GITHUB_REPO="https://github.com/everx-labs/ever-cli.git"
export EVER_CLI_GITHUB_COMMIT_ID="master"
export DEPOOL_ENABLE="no"
# Calculated dynamically (total RAM - 1GB), uncomment if you want to agjust it manually
#export NODE_MEM_LIMIT="127G"
