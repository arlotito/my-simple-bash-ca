#!/bin/bash
# usage: ./create_int.sh int1

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


DIR=$1
export DEST_DIR=/root/ca/$1

mkdir -p /root/ca/$DIR
cp intermediate.openssl.cnf /root/ca/$DIR/openssl.cnf

cd /root/ca/$DIR
mkdir -p certs crl csr newcerts private

chmod 700 private
touch index.txt
echo 1000 > serial

echo 1000 > /root/ca/$DIR/crlnumber


# create key
cd /root/ca
openssl genrsa \
    -out $DIR/private/intermediate.key.pem 4096
chmod 400 $DIR/private/intermediate.key.pem

# create csr
cd /root/ca
openssl req -config $DIR/openssl.cnf -new -sha256 \
      -key $DIR/private/intermediate.key.pem \
      -out $DIR/csr/intermediate.csr.pem

# sign csr
cd /root/ca
openssl ca -config openssl.cnf -extensions v3_intermediate_ca \
      -days 3650 -notext -md sha256 \
      -in $DIR/csr/intermediate.csr.pem \
      -out $DIR/certs/intermediate.cert.pem

chmod 444 $DIR/certs/intermediate.cert.pem

# create chain file
cd /root/ca
cat $DIR/certs/intermediate.cert.pem \
      certs/ca.cert.pem > $DIR/certs/ca-chain.cert.pem
chmod 444 $DIR/certs/ca-chain.cert.pem