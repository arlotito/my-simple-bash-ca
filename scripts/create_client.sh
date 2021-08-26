#!/bin/bash
# usage: ./create_intermediate.sh int1 test.server.com

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

INTERMEDIATE_DIR=$1
export DEST_DIR=/root/ca/$1

SERVER_CERT_NAME=$2

# create key
cd /root/ca
      # -aes256
openssl genrsa -out $INTERMEDIATE_DIR/private/$SERVER_CERT_NAME.key.pem 2048
chmod 400 $INTERMEDIATE_DIR/private/$SERVER_CERT_NAME.key.pem

# create CSR
cd /root/ca
openssl req -config $INTERMEDIATE_DIR/openssl.cnf \
      -key $INTERMEDIATE_DIR/private/$SERVER_CERT_NAME.key.pem \
      -new -sha256 -out $INTERMEDIATE_DIR/csr/$SERVER_CERT_NAME.csr.pem

# sign certificate
cd /root/ca
openssl ca -config $INTERMEDIATE_DIR/openssl.cnf \
      -extensions usr_cert -days 375 -notext -md sha256 \
      -in $INTERMEDIATE_DIR/csr/$SERVER_CERT_NAME.csr.pem \
      -out $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.cert.pem
chmod 444 $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.cert.pem

# view certificate
openssl x509 -noout -text \
      -in $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.cert.pem

# verify certificate
openssl verify -CAfile $INTERMEDIATE_DIR/certs/ca-chain.cert.pem \
      $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.cert.pem

# create chain file
cd /root/ca
cat $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.cert.pem \
      $INTERMEDIATE_DIR/certs/ca-chain.cert.pem > $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.fullchain.cert.pem
chmod 444 $INTERMEDIATE_DIR/certs/$SERVER_CERT_NAME.fullchain.cert.pem