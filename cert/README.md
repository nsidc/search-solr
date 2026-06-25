SSL Certificates
---

This directory (`/cert`) will hold the generated self-signed certs when the VM is created.

It will use the following command line to generate the certs:

    $openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout solr.key -out solr.crt -subj "/CN=nsidc"

If the certificate expires, the above command line can be run manually on the VM
to make a new one.
