---
title: Transport security model
weight: 4125
description: Securing data in transit
---

etcd supports automatic TLS as well as authentication through client certificates for both clients to server as well as peer (server to server / cluster) communication.

{{% alert title="Warning" color="warning" %}}

etcd doesn't enable [RBAC based authentication](../authentication) or the authentication feature in the transport layer by default to reduce friction for users getting started with the database. Further, changing this default would be a breaking change for the project which was established since 2013. An etcd cluster which doesn't enable security features can expose its data to any clients.

{{% /alert %}}

To get up and running, first have a CA certificate and a signed key pair for one member. It is recommended to create and sign a new key pair for every member in a cluster.

For convenience, the [cfssl] tool provides an easy interface to certificate generation, and we provide an example using the tool [here][tls-setup]. Alternatively, try this [guide to generating self-signed key pairs][tls-guide].

The list of flags provided below may not be up-to-date due to ongoing development changes. For the latest available flags, run `etcd --help` or refer to the [etcd help][].

## Basic setup

etcd takes several certificate related configuration options, either through command-line flags or environment variables:

**Client-to-server communication:**

`--cert-file=<path>`: Certificate used for SSL/TLS connections **to** etcd. When this option is set, advertise-client-urls can use the HTTPS schema.

`--key-file=<path>`: Key for the certificate. Must be unencrypted.

`--client-cert-auth`: When this is set etcd will check all incoming HTTPS requests for a client certificate signed by the trusted CA, requests that don't supply a valid client certificate will fail. If [authentication][auth] is enabled, the certificate provides credentials for the user name given by the Common Name field.

`--trusted-ca-file=<path>`: Trusted certificate authority.

`--auto-tls`: Use automatically generated self-signed certificates for TLS connections with clients.

**Peer (server-to-server / cluster) communication:**

The peer options work the same way as the client-to-server options:

`--peer-cert-file=<path>`: Certificate used for SSL/TLS connections between peers. This will be used both for listening on the peer address as well as sending requests to other peers.

`--peer-key-file=<path>`: Key for the certificate. Must be unencrypted.

`--peer-client-cert-auth`: When set, etcd will check all incoming peer requests from the cluster for valid client certificates signed by the supplied CA.

`--peer-trusted-ca-file=<path>`: Trusted certificate authority.

`--peer-auto-tls`: Use automatically generated self-signed certificates for TLS connections between peers.

If either a client-to-server or peer certificate is supplied the key must also be set. All of these configuration options are also available through the environment variables, `ETCD_CA_FILE`, `ETCD_PEER_CA_FILE` and so on.

**Common options:**

`--cipher-suites`: Comma-separated list of supported TLS cipher suites between server/client and peers (empty will be auto-populated by Go).

`--tls-min-version=<version>` Sets the minimum TLS version supported by etcd.

`--tls-max-version=<version>` Sets the maximum TLS version supported by etcd. If not set the maximum version supported by Go will be used.

## Example 1: Client-to-server transport security with HTTPS

For this, have a CA certificate (`ca.crt`) and signed key pair (`server.crt`, `server.key`) ready.

Let us configure etcd to provide simple HTTPS transport security step by step:

```sh
$ etcd --name infra0 --data-dir infra0 \
  --cert-file=/path/to/server.crt --key-file=/path/to/server.key \
  --advertise-client-urls=https://127.0.0.1:2379 --listen-client-urls=https://127.0.0.1:2379
```

This should start up fine and it will be possible to test the configuration by speaking HTTPS to etcd:

```sh
$ curl --cacert /path/to/ca.crt https://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v
```

The command should show that the handshake succeed. Since we use self-signed certificates with our own certificate authority, the CA must be passed to curl using the `--cacert` option. Another possibility would be to add the CA certificate to the system's trusted certificates directory (usually in `/etc/pki/tls/certs` or `/etc/ssl/certs`).

**OSX 10.9+ Users**: curl 7.30.0 on OSX 10.9+ doesn't understand certificates passed in on the command line. Instead, import the dummy ca.crt directly into the keychain or add the `-k` flag to curl to ignore errors. To test without the `-k` flag, run `open ./tests/fixtures/ca/ca.crt` and follow the prompts. Please remove this certificate after testing! If there is a workaround, let us know.

## Example 2: Client-to-server authentication with HTTPS client certificates

For now we've given the etcd client the ability to verify the server identity and provide transport security. We can however also use client certificates to prevent unauthorized access to etcd.

The clients will provide their certificates to the server and the server will check whether the cert is signed by the supplied CA and decide whether to serve the request.

The same files mentioned in the first example are needed for this, as well as a key pair for the client (`client.crt`, `client.key`) signed by the same certificate authority.

```sh
$ etcd --name infra0 --data-dir infra0 \
  --client-cert-auth --trusted-ca-file=/path/to/ca.crt --cert-file=/path/to/server.crt --key-file=/path/to/server.key \
  --advertise-client-urls https://127.0.0.1:2379 --listen-client-urls https://127.0.0.1:2379
```

Now try the same request as above to this server:

```sh
$ curl --cacert /path/to/ca.crt https://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v
```

The request should be rejected by the server:

```
...
routines:SSL3_READ_BYTES:sslv3 alert bad certificate
...
```

To make it succeed, we need to give the CA signed client certificate to the server:

```sh
$ curl --cacert /path/to/ca.crt --cert /path/to/client.crt --key /path/to/client.key \
  -L https://127.0.0.1:2379/v2/keys/foo -XPUT -d value=bar -v
```

The output should include:

```
...
SSLv3, TLS handshake, CERT verify (15):
...
TLS handshake, Finished (20)
```

And also the response from the server:

```json
{
    "action": "set",
    "node": {
        "createdIndex": 12,
        "key": "/foo",
        "modifiedIndex": 12,
        "value": "bar"
    }
}
```

Specify cipher suites to block [weak TLS cipher suites](https://github.com/etcd-io/etcd/issues/8320).

TLS handshake would fail when client hello is requested with invalid cipher suites.

For instance:

```bash
$ etcd \
  --cert-file ./server.crt \
  --key-file ./server.key \
  --trusted-ca-file ./ca.crt \
  --cipher-suites TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256,TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
```

Then, client requests must specify one of the cipher suites specified in the server:

```bash
# valid cipher suite
$ curl \
  --cacert /path/to/ca.crt \
  --cert /path/to/client.crt \
  --key /path/to/client.key \
  -L [CLIENT-URL]/metrics \
  --ciphers ECDHE-RSA-AES128-GCM-SHA256

# request succeeds
etcd_server_version{server_version="3.2.22"} 1
...
```

```bash
# invalid cipher suite
$ curl \
  --cacert /path/to/ca.crt \
  --cert /path/to/client.crt \
  --key /path/to/client.key \
  -L [CLIENT-URL]/metrics \
  --ciphers ECDHE-RSA-DES-CBC3-SHA

# request fails with
(35) error:14094410:SSL routines:ssl3_read_bytes:sslv3 alert handshake failure
```

## Example 3: Transport security & client certificates in a cluster

etcd supports the same model as above for **peer communication**, that means the communication between etcd members in a cluster.

Assuming we have our `ca.crt` and two members with their own key pairs (`member1.crt` & `member1.key`, `member2.crt` & `member2.key`) signed by this CA, we launch etcd as follows:


```sh
DISCOVERY_URL=... # from https://discovery.etcd.io/new

# member1
$ etcd --name infra1 --data-dir infra1 \
  --peer-client-cert-auth --peer-trusted-ca-file=/path/to/ca.crt --peer-cert-file=/path/to/member1.crt --peer-key-file=/path/to/member1.key \
  --initial-advertise-peer-urls=https://10.0.1.10:2380 --listen-peer-urls=https://10.0.1.10:2380 \
  --discovery ${DISCOVERY_URL}

# member2
$ etcd --name infra2 --data-dir infra2 \
  --peer-client-cert-auth --peer-trusted-ca-file=/path/to/ca.crt --peer-cert-file=/path/to/member2.crt --peer-key-file=/path/to/member2.key \
  --initial-advertise-peer-urls=https://10.0.1.11:2380 --listen-peer-urls=https://10.0.1.11:2380 \
  --discovery ${DISCOVERY_URL}
```

The etcd members will form a cluster and all communication between members in the cluster will be encrypted and authenticated using the client certificates. The output of etcd will show that the addresses it connects to use HTTPS.

## Example 4: Automatic self-signed transport security

{{% alert title="Note" color="info" %}}

When you specify ClientAutoTLS and PeerAutoTLS, the validity period of the client certificate and peer certificate automatically generated by etcd is only 1 year. You can specify the --self-signed-cert-validity flag to set the validity period of the certificate in years.

{{% /alert %}}

For cases where communication encryption, but not authentication, is needed, etcd supports encrypting its messages with automatically generated self-signed certificates. This simplifies deployment because there is no need for managing certificates and keys outside of etcd.
Configure etcd to use self-signed certificates for client and peer connections with the flags `--auto-tls` and `--peer-auto-tls`:

```sh
DISCOVERY_URL=... # from https://discovery.etcd.io/new

# member1
$ etcd --name infra1 --data-dir infra1 \
  --auto-tls --peer-auto-tls \
  --initial-advertise-peer-urls=https://10.0.1.10:2380 --listen-peer-urls=https://10.0.1.10:2380 \
  --discovery ${DISCOVERY_URL}

# member2
$ etcd --name infra2 --data-dir infra2 \
  --auto-tls --peer-auto-tls \
  --initial-advertise-peer-urls=https://10.0.1.11:2380 --listen-peer-urls=https://10.0.1.11:2380 \
  --discovery ${DISCOVERY_URL}
```

Self-signed certificates do not authenticate identity so curl will return an error:

```sh
curl: (60) SSL certificate problem: Invalid certificate chain
```

To disable certificate chain checking, invoke curl with the `-k` flag:

```sh
$ curl -k https://127.0.0.1:2379/v2/keys/foo -Xput -d value=bar -v
```

## Example 5: Convert an existing non-TLS etcd cluster to TLS

Previously, we described that etcd supports two types of communication: **client-to-server** and **server-to-server (peer communication)**. In this section, we will prepare configuration steps to migrate both communication types to TLS in your existing etcd cluster.

{{% alert title="Important"%}}

Before starting work on converting the cluster to TLS, please make a backup of the etcd database.

{{% /alert %}}
{{% alert title="Important"%}}

Before restarting any etcd members, you must first add the TLS certificates and configuration to each etcd node.

{{% /alert %}}

---

### 1. Check current cluster status

```sh
export ETCDCTL_API=3

# Define etcd node IPs
HOST_1=ip_address_etcd_node_1
HOST_2=ip_address_etcd_node_2
HOST_3=ip_address_etcd_node_3

# Get member list
etcdctl --endpoints=${HOST_1}:2379,${HOST_2}:2379,${HOST_3}:2379 member list
```

You will get an output similar to:

```sh
10f4390f4a904a13, started, etcd-node-1, http://ip_address_etcd_node_1:2380, http://ip_address_etcd_node_1:2379, false
18e03f3590bf045c, started, etcd-node-2, http://ip_address_etcd_node_2:2380, http://ip_address_etcd_node_2:2379, false
ca7a7d6fe0984fd9, started, etcd-node-3, http://ip_address_etcd_node_3:2380, http://ip_address_etcd_node_3:2379, false
```

{{% alert title="Note" color="info" %}}
Save the **member IDs** and corresponding **IP addresses** — you'll need them to update peer URLs.
{{% /alert %}}

---

### 2. Add TLS certs on each node

Please add TLS certificates to each node using the [cfssl] tool provides an easy interface to certificate generation, and we provide an example using the tool [instruction][tls-setup]. Alternatively, try this [guide to generating self-signed key pairs][tls-guide].

### 3. Enable TLS for client-to-server communication

Update each node's parameters to match your etcd deployment method using the following flags:

```ini
--cert-file=/etc/ssl/etcd/server.pem
--key-file=/etc/ssl/etcd/server-key.pem
--client-cert-auth=true
--trusted-ca-file=/etc/ssl/etcd/ca.pem
--peer-cert-file=/etc/ssl/etcd/peer.pem
--peer-key-file=/etc/ssl/etcd/peer-key.pem
--peer-client-cert-auth=true
--peer-trusted-ca-file=/etc/ssl/etcd/ca.pem
```

Also, update all `--listen-peer-urls`, `--listen-client-urls`, `--advertise-client-urls`, `--initial-cluster`  and `--initial-advertise-peer-urls` to use `https://`.

### 4. Enable TLS for server-to-server communication

Update each etcd member’s peer URL to use `https://` step by step:

```sh
$ On node 10f4390f4a904a13
etcdctl member update 10f4390f4a904a13 --peer-urls=https://ip_address_etcd_node_1:2380
$ On node 18e03f3590bf045c
etcdctl member update 18e03f3590bf045c --peer-urls=https://ip_address_etcd_node_2:2380
$ On node ca7a7d6fe0984fd9
etcdctl member update ca7a7d6fe0984fd9 --peer-urls=https://ip_address_etcd_node_3:2380
```

After that please restart etcd systemd service on each etcd node step by step:

```sh
systemctl daemon-reload
systemctl restart etcd
```

Why is important?
If we convert a cluster of 3 nodes one by one, then at the first stage we will have 1 node with TLS, 2 without TLS and the cluster will respond without TLS. In the 2nd stage, we convert the 2nd node, resulting in a cluster with TLS (2 out of 3 nodes with TLS), which will also function properly.

---

### 5. Verify secure communication

Check cluster health using TLS:

```sh
etcdctl --endpoints=https://${HOST_1}:2379,https://${HOST_2}:2379,https://${HOST_3}:2379 \
  --cacert=/etc/ssl/etcd/ca.pem \
  --cert=/etc/ssl/etcd/client.pem \
  --key=/etc/ssl/etcd/client-key.pem \
  endpoint health
```

You should see responses like:

```sh
https://ip_address_etcd_node_1:2379 is healthy: successfully committed proposal
```

If all endpoints return healthy, your cluster is now fully secured with TLS!

## Notes for DNS SRV

When bootstrapping a cluster with DNS SRV discovery, if the peer URLs use HTTPS and `--peer-trusted-ca-file` is not set, etcd sets the peer TLS `ServerName` to the root domain name given by the `--discovery-srv` flag. This prevents man-in-the-middle certificate attacks by requiring each peer certificate to carry that root domain name in its Subject Alternative Name (SAN) field. For example, with `--discovery-srv=etcd.local`, each peer certificate must list `etcd.local` in its SAN field.

## Notes for etcd proxy

etcd proxy terminates the TLS from its client if the connection is secure, and uses proxy's own key/cert specified in `--peer-key-file` and `--peer-cert-file` to communicate with etcd members.

The proxy communicates with etcd members through both the `--advertise-client-urls` and `--advertise-peer-urls` of a given member. It forwards client requests to etcd members’ advertised client urls, and it syncs the initial cluster configuration through etcd members’ advertised peer urls.

When client authentication is enabled for an etcd member, the administrator must ensure that the peer certificate specified in the proxy's `--peer-cert-file` option is valid for that authentication. The proxy's peer certificate must also be valid for peer authentication if peer authentication is enabled.

## Notes for TLS authentication

### Certificate reload

etcd reloads its TLS certificates on every new connection, so expiring certificates can be replaced without restarting the server: write the new certificate and key files and rename them into place, and subsequent connections use them. Reload also works for certificates whose Subject Alternative Name (SAN) field contains only IP addresses and no domain names.

### Subject Alternative Name (SAN) verification

When a peer presents a certificate, the receiving member authenticates it against the certificate's Subject Alternative Name (SAN) field and the remote IP address of the connection. This prevents unauthorized endpoints from joining the cluster:

- If the SAN field contains no IP addresses and no DNS names, no SAN-based restriction is applied.
- If the SAN field contains IP addresses and the remote IP matches one of them, the connection is accepted without any further DNS checks.
- If the SAN field contains only IP addresses and none matches the remote IP, the connection is rejected — for example, `x509: certificate is valid for 10.138.0.27, not 10.138.0.2`.
- If the SAN field contains DNS names, etcd performs a reverse lookup of the remote IP and accepts the connection when a resulting name matches a SAN entry, either exactly or through a wildcard such as `*.example.default.svc`. Otherwise it performs a forward lookup of each non-wildcard DNS name in the SAN and accepts the connection when a resolved address equals the remote IP. If no lookup matches, the connection is rejected — for example, `tls: "10.138.0.2" does not match any of DNSNames ["*.example.default.svc","*.example.default.svc.cluster.local"]`.

This SAN check applies to peer connections; client connections instead rely on standard X.509 chain verification.

### Common Name and hostname authentication

When cluster members share a certificate authority — for example, during Kubernetes TLS bootstrapping, where dynamic certificates are issued to etcd members and to other system components such as the API server and kubelet — etcd can further restrict which certificates are accepted by Common Name (CN) or hostname:

- `--peer-cert-allowed-cn` accepts a peer only when the certificate's Common Name (CN) exactly matches one of the configured values. The comparison is an exact string match; wildcards and prefix matching are not supported.
- `--peer-cert-allowed-hostname` (for peer certificates) and `--client-cert-allowed-hostname` (for client certificates) match against the certificate's SAN using Go's `x509.Certificate.VerifyHostname()`, which supports both exact hostnames and wildcard entries such as `*.example.com`.

`--peer-cert-allowed-cn` and `--peer-cert-allowed-hostname` are mutually exclusive; etcd refuses to start if both are set. `--client-cert-allowed-hostname` is independent and can be combined with either peer flag.

For example, in a three-node cluster whose members are all issued certificates with the Common Name `etcd.local`, starting every member with `--peer-cert-allowed-cn etcd.local` lets the members authenticate one another, while a node that presents a different Common Name is rejected with a `client certificate authentication failed` error.

## Notes for Host Whitelist

`etcd --host-whitelist` flag specifies acceptable hostnames from HTTP client requests. Client origin policy protects against ["DNS Rebinding"](https://en.wikipedia.org/wiki/DNS_rebinding) attacks to insecure etcd servers. That is, any website can simply create an authorized DNS name, and direct DNS to `"localhost"` (or any other address). Then, all HTTP endpoints of etcd server listening on `"localhost"` becomes accessible, thus vulnerable to DNS rebinding attacks. See [CVE-2018-5702](https://bugs.chromium.org/p/project-zero/issues/detail?id=1447#c2) for more detail.

Client origin policy works as follows:

1. If client connection is secure via HTTPS, allow any hostnames.
2. If client connection is not secure and `"HostWhitelist"` is not empty, only allow HTTP requests whose Host field is listed in whitelist.

Note that the client origin policy is enforced whether authentication is enabled or not, for tighter controls.

By default, `etcd --host-whitelist` and `embed.Config.HostWhitelist` are set *empty* to allow all hostnames. Note that when specifying hostnames, loopback addresses are not added automatically. To allow loopback interfaces, add them to whitelist manually (e.g. `"localhost"`, `"127.0.0.1"`, etc.).

## Frequently asked questions

### I'm seeing a SSLv3 alert handshake failure when using TLS client authentication?

The `crypto/tls` package of `golang` checks the key usage of the certificate public key before using it.
To use the certificate public key to do client auth, we need to add `clientAuth` to `Extended Key Usage` when creating the certificate public key.

Here is how to do it:

Add the following section to openssl.cnf:

```
[ ssl_client ]
...
  extendedKeyUsage = clientAuth
...
```

When creating the cert be sure to reference it in the `-extensions` flag:

```
$ openssl ca -config openssl.cnf -policy policy_anything -extensions ssl_client -out certs/machine.crt -infiles machine.csr
```

### With peer certificate authentication I receive "certificate is valid for 127.0.0.1, not $MY_IP"
Make sure to sign the certificates with a Subject Name the member's public IP address. The `etcd-ca` tool for example provides an `--ip=` option for its `new-cert` command.

The certificate needs to be signed for the member's FQDN in its Subject Name, use Subject Alternative Names (short IP SANs) to add the IP address. The `etcd-ca` tool provides `--domain=` option for its `new-cert` command, and openssl can make [it][alt-name] too.

### Does etcd encrypt data stored on disk drives?
No. etcd doesn't encrypt key/value data stored on disk drives. If a user need to encrypt data stored on etcd, there are some options:
* Let client applications encrypt and decrypt the data
* Use a feature of underlying storage systems for encrypting stored data like [dm-crypt]

### I’m seeing a log warning that "directory X exist without recommended permission -rwx------"
When etcd create certain new directories it sets file permission to 700 to prevent unprivileged access as possible. However, if user has already created a directory with own preference, etcd uses the existing directory and logs a warning message if the permission is different than 700.

[alt-name]: http://wiki.cacert.org/FAQ/subjectAltName
[auth]: ../authentication/
[cfssl]: https://github.com/cloudflare/cfssl
[dm-crypt]: https://en.wikipedia.org/wiki/Dm-crypt
[tls-guide]: https://github.com/coreos/docs/blob/master/os/generate-self-signed-certificates.md
[tls-setup]: https://github.com/etcd-io/etcd/tree/main/hack/tls-setup
[etcd help]: https://github.com/etcd-io/etcd/blob/main/server/etcdmain/help.go
