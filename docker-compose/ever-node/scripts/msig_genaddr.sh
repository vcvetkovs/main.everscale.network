#!/bin/bash -eE

export EVER_NODE_ROOT_DIR="/ever-node"
export EVER_NODE_CONFIGS_DIR="${EVER_NODE_ROOT_DIR}/configs"
export EVER_NODE_KEYS_DIR="${EVER_NODE_CONFIGS_DIR}/keys"
export EVER_NODE_TOOLS_DIR="${EVER_NODE_ROOT_DIR}/tools"
export EVER_NODE_LOGS_DIR="${EVER_NODE_ROOT_DIR}/logs"

mkdir -p "${EVER_NODE_KEYS_DIR}"

apt update >/dev/null 2>&1 && apt install -y wget >/dev/null 2>&1

if [ ! -f "${EVER_NODE_CONFIGS_DIR}/SafeMultisigWallet.abi.json" ]; then
    cd ${EVER_NODE_CONFIGS_DIR} && wget https://raw.githubusercontent.com/everx-labs/ton-labs-contracts/master/solidity/safemultisig/SafeMultisigWallet.abi.json
fi

if [ ! -f "${EVER_NODE_CONFIGS_DIR}/SafeMultisigWallet.tvc" ]; then
    cd ${EVER_NODE_CONFIGS_DIR} && wget https://github.com/everx-labs/ton-labs-contracts/raw/master/solidity/safemultisig/SafeMultisigWallet.tvc
fi

cd ${EVER_NODE_TOOLS_DIR}
EVER_CLI_OUTPUT=$("${EVER_NODE_TOOLS_DIR}/ever-cli" genaddr "${EVER_NODE_CONFIGS_DIR}/SafeMultisigWallet.tvc" \
    "${EVER_NODE_CONFIGS_DIR}/SafeMultisigWallet.abi.json" --genkey "${EVER_NODE_KEYS_DIR}/msig.keys.json" --wc -1)
RAW_ADDRESS=$(echo "${EVER_CLI_OUTPUT}" | grep "Raw address" | cut -d ' ' -f 3)
SEED_PHRASE=$(echo "${EVER_CLI_OUTPUT}" | grep "Seed phrase" | sed -e 's/Seed phrase: //' | tr -d '"')
echo "${RAW_ADDRESS}" >"${EVER_NODE_CONFIGS_DIR}/${VALIDATOR_NAME}.addr"
echo "INFO: Raw address = ${RAW_ADDRESS}"
echo "INFO: Seed phrase = ${SEED_PHRASE}"
