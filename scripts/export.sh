#!/bin/bash
# usage: ./export.sh <intermediate> <certificate-name> <dest-folder>

if [ "$EUID" -ne 0 ]
  then echo "Please run as root: sudo ./export.sh"
  exit
fi

showHelp() {
# `cat << EOF` This means that cat should stop reading when EOF is detected
cat << EOF  
Usage: ./export.sh -i <intermediate-name> -c <certificate-name> -d <dest-folder> [-k] [-h]
  -h  Display help
  -i  name of the intermediate  
      (it's the /root/ca/<intermediate-name>)
  -c  name of the certificate ("intermediate" or client/server name) 
      (it's /root/ca/<intermediate-name>/certs/<CERT_NAME>.cert.pem and /root/ca/<intermediate-name>/private/<CERT_NAME>.cert.pem)
  -d  destination folder
  -k  exports the private key

Examples:

  to extract the intermediate "int1" (including private key) into ~/exported:
    ./export.sh -i int1 -c intermediate -d ~/exported -k

  to extract the server "est.contoso.com" (including private key) into ~/exported:
    ./export.sh -i int1 -c est.contoso.com -d ~/exported -k

  to extract the client "device3" (including private key) into ~/exported:
    ./export.sh -i int1 -c device3 -d ~/exported -k
EOF
# EOF is found above and hence cat command stops reading. This is equivalent to echo but much neater when printing out.
}

while getopts "hki:c:d:" args; do
    case "${args}" in
        h ) showHelp;;
        i ) INTERMEDIATE_DIR="${OPTARG}";;
        c ) CERT_NAME="${OPTARG}";;
        d ) DEST_DIR="${OPTARG}";;
        k ) PK=1;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done
shift $((OPTIND-1))

if [ ! "$INTERMEDIATE_DIR" ] || [ ! "$CERT_NAME" ] || [ ! "$DEST_DIR" ];
then
    showHelp
    exit 1
fi

export CA_ROOT="/root/ca"

# create dest folder if it does not exist
echo 
echo "creating ${DEST_DIR} (if it does not exist already)..."
sudo mkdir -p ${DEST_DIR}

source=${CA_ROOT}/${INTERMEDIATE_DIR}/certs/ca-chain.cert.pem
dest=${DEST_DIR}/${INTERMEDIATE_DIR}-ca-chain.cert.pem
echo
echo "exporting root+intermediate chain..."
echo "${source} --> ${dest}"
sudo cp $source $dest

source=${CA_ROOT}/${INTERMEDIATE_DIR}/certs/${CERT_NAME}.cert.pem
dest=${DEST_DIR}/${INTERMEDIATE_DIR}-${CERT_NAME}.cert.pem
echo
echo "exporting certificate..."
echo "${source} --> ${dest}"
sudo cp $source $dest

if [ "$PK" ];
then
    source=${CA_ROOT}/${INTERMEDIATE_DIR}/private/${CERT_NAME}.key.pem
    dest=${DEST_DIR}/${INTERMEDIATE_DIR}-${CERT_NAME}.key.pem
    echo
    echo "exporting private key..."
    echo "${source} --> ${dest}"
    sudo cp $source $dest
fi

exit 0