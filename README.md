Simple CA for creating root, intermediate and leaf (client/server) certificates. For testing purposes only.

![picture 1](images/diagram.png)  
```bash
cd

sudo ./create_root.sh

sudo ./create_int.sh INT1
sudo ./create_server.sh INT1 server.contoso.com

sudo ./create_int.sh INT2
sudo ./create_client.sh INT2 clientA

sudo ./create_int.sh INT3  
sudo ./create_client.sh INT3 deviceA  
```

All the certificates are stored in `/root/ca`.

## getting started
Optionally clear the CA store:
```bash
sudo rm -rf /root/ca
```

Grab the scripts:
```bash
cd
sudo rm -rf ~/est-tests
git clone https://github.com/arlotito/est-tests.git
cd ~/est-tests/certs
chmod +x *.sh
```

...and create your own certs.
Customize .openssl.cnf as needed.

## creates ROOT and INTERMEDIATE certs
Optionally view the ROOT certificates:
```bash
sudo openssl x509 -noout -in /root/ca/certs/ca.cert.pem -noout -subject
sudo openssl x509 -noout -in /root/ca/certs/ca.cert.pem -noout -issuer
```

Optionally view the INTERMEDIATE certificates:
(replace `<INTERMEDIATE>` with int1 or int2 or int3)
```bash
sudo openssl x509 -noout -in <INTERMEDIATE>/certs/intermediate.cert.pem -noout -subject
sudo openssl x509 -noout -in <INTERMEDIATE>/certs/intermediate.cert.pem -noout -issuer
```

Optionally verify INTERMEDIATE against ROOT:
```bash
sudo openssl verify -CAfile /root/CA/certs/ca.cert.pem /root/CA/<INTERMEDIATE>/certs/intermediate.cert.pem
```