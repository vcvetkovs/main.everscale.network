#!/bin/bash -eEx

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"


rm -rf "${DOCKER_COMPOSE_DIR}/ton-node/build/ton-node"
rm -rf "${DOCKER_COMPOSE_DIR}/ton-node/build/ever-node-tools"
rm -rf "${DOCKER_COMPOSE_DIR}/ton-node/build/ever-cli"

# docker run --rm \
#   -v DB:/ever_node/node_db/ \
#   -v DB2:/ever-node/node_db/ \
#   ubuntu:latest \
#   bash -c "cp -R /ton-node/* /ever-node/"