#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

mkdir -p /root/ca
cp root.openssl.cnf /root/ca/openssl.cnf 

cd /root/ca

mkdir -p certs crl newcerts private

chmod 700 private
touch index.txt
echo 1000 > serial

# create root key
cd /root/ca
openssl genrsa -aes256 -out private/ca.key.pem 4096
chmod 400 private/ca.key.pem

# create root cert
cd /root/ca

openssl req -config openssl.cnf \
    -key private/ca.key.pem \
    -new -x509 -days 7300 -sha256 -extensions v3_ca \
    -out certs/ca.cert.pem
chmod 444 certs/ca.cert.pem