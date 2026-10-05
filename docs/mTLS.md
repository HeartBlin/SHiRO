# mTLS

I use mTLS (or mutual TLS) for my self-hosted services.

This is more a guide for me on how to bring up a CA with openssl.

I don't expect this to be awfully wrong, but neither best praxis. Use this at your own risk. These instructions are just for references sake.

If you do find a security vulnerability here, do let me know. Or hack me idk, either or I guess.

I will use my [Finality](../clients/Finality/config.nix) ISO for any CA tasks, with the key-containing folder being on a LUKS container (a dd'ed file with LUKS attached to it)

## Bootstrapping

We'll set up some folders, and `.cnf` files. They are a secret tool that will help us later.

It goes without saying: a lot of these are secrets. Store them appropriately. Or in `.p12s` case, delete after you're done with them.

In my case, I forbid myself from using agenix to store any `certs` or `.p12s`.

```bash
mkdir -p root-ca/certs root-ca/crl root-ca/newcerts root-ca/private
chmod 700 root-ca/private
touch root-ca/index.txt root-ca/index.txt.attr

openssl rand -hex 16 > root-ca/serial

echo 1000 > root-ca/crlnumber
mv root-openssl.cnf root-ca/openssl.cnf
```

What is `root-openssl.cnf`? This:

```ini
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = .
certs = $dir/certs
crl_dir = $dir/crl
new_certs_dir = $dir/newcerts
database = $dir/index.txt
serial = $dir/serial
RANDFILE = $dir/private/.rand

private_key = $dir/private/root.key.pem
certificate = $dir/certs/root.cert.pem

crlnumber = $dir/crlnumber
crl = $dir/crl/root.crl.pem
crl_extensions = crl_ext
default_crl_days = 365

default_md = sha384
name_opt = ca_default
cert_opt = ca_default
default_days = 3650 # 10 years at least.
preserve = no
policy = policy_strict
copy_extensions = none

[ policy_strict ]
countryName = match
organizationName = match
organizationalUnitName = optional
commonName = supplied

[ req ]
default_bits = 384
distinguished_name = req_distinguished_name
string_mask = utf8only
default_md = sha384
x509_extensions = v3_root_ca

[ req_distinguished_name ]
countryName = Country Name
organizationName = Organization Name
commonName = Common Name

[ v3_root_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:1
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ crl_ext ]
authorityKeyIdentifier = keyid:always
```

We continue with the intermediary.

```bash
mkdir -p intermediate-ca/certs intermediate-ca/crl intermediate-ca/newcerts intermediate-ca/private intermediate-ca/csr
chmod 700 intermediate-ca/private
touch intermediate-ca/index.txt intermediate-ca/index.txt.attr

openssl rand -hex 16 > intermediate-ca/serial
echo 1000 > intermediate-ca/crlnumber

mv intermediate-openssl.cnf intermediate-ca/openssl.cnf
```

Where `intermediate-openssl.cnf` is:

```ini
[ ca ]
default_ca = CA_default

[ CA_default ]
dir = .
certs = $dir/certs
crl_dir = $dir/crl
new_certs_dir = $dir/newcerts
database = $dir/index.txt
serial = $dir/serial
RANDFILE = $dir/private/.rand

private_key = $dir/private/intermediate.key.pem
certificate = $dir/certs/intermediate.cert.pem

crlnumber = $dir/crlnumber
crl = $dir/crl/intermediate.crl.pem
crl_extensions = crl_ext
default_crl_days = 90

default_md = sha256
name_opt = ca_default
cert_opt = ca_default
default_days = 365
preserve = no
policy = policy_loose
copy_extensions = none

[ policy_loose ]
countryName = optional
organizationName = optional
organizationalUnitName = optional
commonName = supplied

[ req ]
default_bits = 256
distinguished_name = req_distinguished_name
string_mask = utf8only
default_md = sha256
x509_extensions = v3_intermediate_ca

[ req_distinguished_name ]
countryName = Country Name
organizationName = Organization Name
commonName = Common Name

[ v3_intermediate_ca ]
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, cRLSign, keyCertSign

[ usr_cert ]
basicConstraints = CA:FALSE
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always,issuer
keyUsage = critical, digitalSignature
extendedKeyUsage = clientAuth

[ crl_ext ]
authorityKeyIdentifier = keyid:always
```

## Root CA setup.

This happens (hopefully) only once. Again, secrets.

```bash
cd root-ca
openssl ecparam -name secp384r1 -genkey -noout -out private/root.key.pem
chmod 400 private/root.key.pem
openssl req -config openssl.cnf -key private/root.key.pem -new -x509 -days 3650 -sha384 \
  -extensions v3_root_ca -subj "/C=<region>/O=<domain>/CN=<domain> Root CA" \
  -out certs/root.cert.pem
cd ..
```

Where:

* `<region>` is a two character contry code
* `<domain>` is your domain <sub>_(you have one, right?)_</sub>

This gets you the root setup. We are doing no client signing with it.

## Intermediate CA setup

This is done once, then every time it needs to be renewed.

```bash
cd intermediate-ca
openssl ecparam -name secp384r1 -genkey -noout -out private/intermediate.key.pem
chmod 400 private/intermediate.key.pem
openssl req -config openssl.cnf -new -sha384 -key private/intermediate.key.pem \
  -subj "/C=<region>/O=<domain>/CN=<domain> Intermediate CA" \
  -out csr/intermediate.csr.pem
cd ..
```

``` bash
cd root-ca
openssl ca -config openssl.cnf -extensions v3_intermediate_ca -days 1825 -notext -md sha384 \
  -in ../intermediate-ca/csr/intermediate.csr.pem \
  -out ../intermediate-ca/certs/intermediate.cert.pem
cd ..
```

``` bash
cat intermediate-ca/certs/intermediate.cert.pem root-ca/certs/root.cert.pem \
  > intermediate-ca/certs/ca-chain.cert.pem
```

## Issuing Client Certs

This is the one you want. This repeats for every user or device you have.

```bash
cd intermediate-ca
NAME=<username>@<domain> # Ease of use. you can ignore it lmao

openssl ecparam -name prime256v1 -genkey -noout -out private/$NAME.key.pem
chmod 400 private/$NAME.key.pem

openssl req -new -key private/$NAME.key.pem \
  -subj "/C=<region>/O=<domain>/CN=$NAME" \
  -out csr/$NAME.csr.pem

openssl ca -config openssl.cnf -extensions usr_cert -days 397 -notext -md sha256 \
  -in csr/$NAME.csr.pem -out certs/$NAME.cert.pem

openssl pkcs12 -export -inkey private/$NAME.key.pem -in certs/$NAME.cert.pem \
  -certfile certs/ca-chain.cert.pem -name "$NAME" \
  -certpbe AES-256-CBC -keypbe AES-256-CBC -macalg SHA256 -iter 100000 \
  -out certs/$NAME.p12
cd ..
```

Where:

* `<username>` is whatever you call the users
* `<domain>` is still your domain <sub>_(you have one, right?)_</sub>

## Leaf Revocation

You will be here once in your life. You lost a phone, a device...

Or someone else you trusted did.

You might want to revoke that one.

```bash
cd intermediate-ca
openssl ca -config openssl.cnf -revoke certs/$NAME.cert.pem -crl_reason keyCompromise
openssl ca -config openssl.cnf -gencrl -out crl/intermediate.crl.pem
cd ..
```

`-crl_reason` has a LOT of options... you can pick and choose really.

* `unspecified`: aka the _fuck you_.
* `keyCompromise`: Evidence or proof the key was exposed or compromised. The big _uh oh_. Use this 99% of times, since 99% of time you revoke, it's cause the cert is no longer trusted.
* `CACompromise`: Two pathways: Intermediate got compromised: sucks. Root got compromised? Don't even. Just nuke the root key and remake it.
* `affiliationChanged`: Identity details inside the cert are no longer accurate. However, the key has not been compromised. Like... changing `<username>`.
* `superseded`: The cert has been replaced with a newer version.
* `cessationOfOperation`: The device you used this one is dead/out of commision.
* `certificateHold`: Temporary suspended. Think of it like... idk, you lose the phone, but then recuprate it. Can be un-revoked actually!
* `removeFromCRL`: Removes temporary suspentions. Tied to `certificateHold`.

You can check, for peace of mind, if revocations went through.

```bash
openssl verify -crl_check -CAfile intermediate-ca/certs/ca-chain.cert.pem \
  -CRLfile intermediate-ca/crl/intermediate.crl.pem \
  intermediate-ca/certs/$NAME.cert.pem
```

`OK` if the cert is valid, `certificate revoked` if you killed it.

## Intermediate CA Revocation

You really should not reach this phase. If your Intermediate got compromised, I would nuke the whole thing.

However, we _CAN_ revoke a intermediate. Doing it by the book, so they say.

```bash
cd root-ca

openssl ca -config openssl.cnf -revoke ../intermediate-ca/certs/intermediate.cert.pem -crl_reason CACompromise

openssl ca -config openssl.cnf -gencrl -out crl/root.crl.pem
cd ..
```

Get the `root.crl.pem` out of the environment, and feed it to Caddy. Test if any of your leafs fail (they should). If yes, you are fine. Make another intermediate, make your other leafs.

## Root CA Revocation

```bash
rm -rf root-ca/
```

Hope that helped.

Real talk, there is no Root revoke. That's the most trusted cert in the chain. Get rid of the certs in all clients, remove root and intermediary, and re-spin this up.

## Closing

You might want to keep all `certs` and `p12s` you make. They will become useful at the low points in time. Like getting a clients serial. Who knows?

Note: This is for an offline workflow. You will have to get the files _out_ of your specific environment. Like... you revoke a cert, but you don't give the server that file, it means you did basically nothing. Or how you can make a `crl` even if you didn't revoke anything yet. That kind of stuff.
