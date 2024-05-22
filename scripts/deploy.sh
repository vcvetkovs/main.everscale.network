#!/bin/bash -eEx

BEGIN_TIME_STAMP=$(date +%s)

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
# shellcheck source=env.sh
. "${SCRIPT_DIR}/env.sh"

TMP_DIR=/tmp/$(basename "$0" .sh)_$$
rm -rf "${TMP_DIR}"
mkdir -p "${TMP_DIR}"

set +eE

cd "${DOCKER_COMPOSE_DIR}/ever-node/" && docker-compose down

if [ "${CLEAN_HOST}" = "yes" ]; then
    docker system prune --all --force --volumes
    docker network create proxy_nw
fi

set -eE

until [ "$(echo "${IntIP}" | grep "\." -o | wc -l)" -eq 3 ]; do
    set +e
    IntIP="$(curl -sS4 https://ip.me/)":${ADNL_PORT}
    set -e
    echo "INFO: IntIP = $IntIP"
done

sed -i "s|IntIP.*|IntIP=${IntIP}|g" "${DOCKER_COMPOSE_DIR}/statsd/.env"
cd "${DOCKER_COMPOSE_DIR}/statsd/" && docker-compose pull
cd "${DOCKER_COMPOSE_DIR}/statsd/" && docker-compose up -d

rm -rf "${DOCKER_COMPOSE_DIR}/ever-node/build/ever-node"
cd "${DOCKER_COMPOSE_DIR}/ever-node/build" && git clone --recursive "${EVER_NODE_GITHUB_REPO}" ever-node
cd "${DOCKER_COMPOSE_DIR}/ever-node/build/ever-node" && git checkout "${EVER_NODE_GITHUB_COMMIT_ID}"

rm -rf "${DOCKER_COMPOSE_DIR}/ever-node/build/ever-node-tools"
cd "${DOCKER_COMPOSE_DIR}/ever-node/build" && git clone --recursive "${EVER_NODE_TOOLS_GITHUB_REPO}"
cd "${DOCKER_COMPOSE_DIR}/ever-node/build/ever-node-tools" && git checkout "${EVER_NODE_TOOLS_GITHUB_COMMIT_ID}"

rm -rf "${DOCKER_COMPOSE_DIR}/ever-node/build/ever-cli"
cd "${DOCKER_COMPOSE_DIR}/ever-node/build" && git clone --recursive "${EVER_CLI_GITHUB_REPO}"
cd "${DOCKER_COMPOSE_DIR}/ever-node/build/ever-cli" && git checkout "${EVER_CLI_GITHUB_COMMIT_ID}"

rm -f "${DOCKER_COMPOSE_DIR}/ever-node/configs/SafeMultisigWallet.abi.json"
cd "${DOCKER_COMPOSE_DIR}/ever-node/configs"

sed -i "s|DEPOOL_ENABLE=.*|DEPOOL_ENABLE=${DEPOOL_ENABLE}|g" "${DOCKER_COMPOSE_DIR}/ever-node/.env"
sed -i "s|NODE_CMD_1=.*|NODE_CMD_1=bash|g" "${DOCKER_COMPOSE_DIR}/ever-node/.env"
if [ "${ENABLE_VALIDATE}" = "yes" ]; then
    sed -i "s|NODE_CMD_2=.*|NODE_CMD_2=validate|" "${DOCKER_COMPOSE_DIR}/ever-node/.env"
else
    sed -i "s|NODE_CMD_2=.*|NODE_CMD_2=novalidate|" "${DOCKER_COMPOSE_DIR}/ever-node/.env"
fi

NODE_MEM_LIMIT_DYNAMIC="$((($(grep MemTotal /proc/meminfo | awk '{print $2}') / 1000 / 1000 - 1)))G"
NODE_MEM_LIMIT="${NODE_MEM_LIMIT:-${NODE_MEM_LIMIT_DYNAMIC}}"
sed -i "s|MEM_LIMIT=.*|MEM_LIMIT=${NODE_MEM_LIMIT}|g" "${DOCKER_COMPOSE_DIR}/ever-node/.env"

cd "${DOCKER_COMPOSE_DIR}/ever-node/" && docker-compose build --no-cache
cd "${DOCKER_COMPOSE_DIR}/ever-node/" && docker-compose up -d
docker ps -a
docker exec --tty rnode "/ever-node/scripts/generate_console_config.sh"
sed -i "s|NODE_CMD_1.*|NODE_CMD_1=normal|g" "${DOCKER_COMPOSE_DIR}/ever-node/.env"
cd "${DOCKER_COMPOSE_DIR}/ever-node/" && docker-compose stop
cd "${DOCKER_COMPOSE_DIR}/ever-node/" && docker-compose up -d

rm -rf "${TMP_DIR}"

END_TIME_STAMP=$(date +%s)
SCRIPT_DURATION=$((END_TIME_STAMP - BEGIN_TIME_STAMP))

echo "INFO: script duration = ${SCRIPT_DURATION} sec."
