#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root: sudo $0"
  exit
fi

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./create_root.sh 

  -h  Display help
  -n  certificate name (will be used as folder/file name)
  -c  (optional) common name. If not specified, it will be the <cert-name> 
  -s  (optional) subject 
      example: "/C=US/ST=Oregon/L=Portland/O=Company Name/OU=Org/CN=www.example.com"
  -d  subject alternate names (optional but best practice)
      example: "DNS:example.com,DNS:www.example.net,IP:10.0.0.1"



Examples:

  sudo ./create_root.sh -n myCA

  sudo ./create_root.sh -n myCA -c "myCA TEST CERT"

  sudo ./create_root.sh -n myCA -c "myCA for testing only" -s "/C=US/ST=WA/L=Seattle/O=Contoso/OU=Org"

EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

CERT_SUBJ_DEFAULT="/C=US/ST=Oregon/L=Portland/O=Contoso/OU=Org"

while getopts "hn:c:s:a:" args; do
    case "${args}" in
        h ) showHelp;;
        n ) CERT_NAME="${OPTARG}";;
        c ) CERT_CN_CUSTOM="${OPTARG}";;
        s ) CERT_SUBJ_CUSTOM="${OPTARG}";;
        a ) CERT_SAN_CUSTOM="${OPTARG}";;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

if [ ! "$CERT_NAME" ];
then
    showHelp
    exit 1
fi

if [ "$CERT_CN_CUSTOM" ];
then
  CERT_CN=${CERT_CN_CUSTOM}
else
  CERT_CN=${CERT_NAME}
fi

if [ "$CERT_SUBJ_CUSTOM" ];
then
  CERT_SUBJ=${CERT_SUBJ_CUSTOM}
else
  CERT_SUBJ=${CERT_SUBJ_DEFAULT}"/CN="${CERT_CN}
fi

if [ "$CERT_SAN_CUSTOM" ];
then
  CERT_SAN="subjectAltName=${CERT_SAN_CUSTOM}"
else
  CERT_SAN="subjectAltName=DNS:${CERT_CN}"
fi

ROOT_CA=/root/$CERT_NAME

mkdir -p ${ROOT_CA}/certs ${ROOT_CA}/private

# create root cert
openssl req -x509 \
  -newkey rsa:4096 -sha256 -days 3650 -extensions v3_ca \
  -nodes -keyout ${ROOT_CA}/private/${CERT_NAME}.key.pem \
  -out ${ROOT_CA}/certs/${CERT_NAME}.cert.pem \
  -subj "${CERT_SUBJ}" \
  -addext "${CERT_SAN}"

chmod 400 ${ROOT_CA}/private/${CERT_NAME}.key.pem
chmod 444 ${ROOT_CA}/certs/${CERT_NAME}.cert.pem

echo
echo "public certificate: ${ROOT_CA}/certs/${CERT_NAME}.cert.pem"
echo "private key:        ${ROOT_CA}/private/${CERT_NAME}.key.pem"
echo 
echo "certificate subject and issuer:"
echo "sudo openssl x509 -noout -in ${ROOT_CA}/certs/${CERT_NAME}.cert.pem -noout -subject -issuer -ext subjectAltName"
sudo openssl x509 -noout -in ${ROOT_CA}/certs/${CERT_NAME}.cert.pem -noout -subject -issuer -ext subjectAltName