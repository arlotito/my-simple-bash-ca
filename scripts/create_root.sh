#!/bin/bash
# usage: ./create_root.sh <root_name>
#
# example:
#   ./create_root.sh myCA  

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

ROOT_CA=/root/$1

mkdir -p ${ROOT_CA}/certs ${ROOT_CA}/crl ${ROOT_CA}/newcerts ${ROOT_CA}/private

# create root key
openssl genrsa -aes256 -out ${ROOT_CA}/private/ca.key.pem 4096
chmod 400 ${ROOT_CA}/private/ca.key.pem

# create root cert
openssl req -config openssl.cnf \
    -key ${ROOT_CA}/private/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -out ${ROOT_CA}/certs/ca.cert.pem
chmod 444 ${ROOT_CA}/certs/ca.cert.pem