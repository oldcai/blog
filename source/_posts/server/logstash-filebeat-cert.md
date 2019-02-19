---
title: Filebeat Not Able to Connect to Logstash
date: 2018-12-14 06:35:00
categories:
  - Server
tags:
  - ELK
---

## Possible Errors:

  * Failed to connect to backoff(async(tcp://10.10.10.1:5044)): x509: certificate is valid for 127.0.0.1, not 10.10.10.1
  *  x509: cannot validate certificate for `127.0.0.1` because it doesn't contain any IP SANs

## Step 1 - Add subjectAltName

Add the line below into file `/etc/pki/tls/openssl.cnf`

```
subjectAltName = IP: 127.0.0.1
```

You can change the ip address to your logstash server address

## Step 2 - Regenerate Certification

```
openssl req -config /etc/pki/tls/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout /etc/pki/tls/private/logstash-forwarder.key -out /etc/pki/tls/certs/logstash-forwarder.crt
```

Then you can use the cert file `/etc/pki/tls/certs/logstash-forwarder.crt` to authorize filebeat to connect to logstash.