#!/bin/bash
# usage: ./export.sh <certificate-name> <dest-folder>

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

export CA_ROOT="/root/ca"
export CERT_NAME=$1     # "intermediate" for intermediate, or cert name for client/server (ex. "est.arturol76.net" or "device3")
export DEST_DIR=$2

# export int
cp ${CA_ROOT}/${INTERMEDIATE_DIR}/certs/ca-chain.cert.pem ${DEST_DIR}/${INTERMEDIATE_DIR}-ca-chain.cert.pem
cp ${CA_ROOT}/${INTERMEDIATE_DIR}/certs/${CERT_NAME}.cert.pem ${DEST_DIR}/${INTERMEDIATE_DIR}-${CERT_NAME}.cert.pem
cp ${CA_ROOT}/${INTERMEDIATE_DIR}/private/${CERT_NAME}.key.pem ${DEST_DIR}/${INTERMEDIATE_DIR}-${CERT_NAME}.key.pem