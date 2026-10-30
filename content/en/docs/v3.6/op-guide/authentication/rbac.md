---
title: Role-based access control
weight: 4100
description: A basic authentication and role-based access control guide
---

## Overview

Authentication was added in etcd 2.1. The etcd v3 API slightly modified the authentication feature's API and user interface to better fit the new data model. This guide is intended to help users set up basic authentication and role-based access control in etcd v3.

## Special users and roles

There is one special user, `root`, and one special role, `root`.

### User `root`

The `root` user, which has full access to etcd, must be created before activating authentication. The idea behind the `root` user is for administrative purposes: managing roles and ordinary users. The `root` user must have the `root` role and is allowed to change anything inside etcd.

### Role `root`

The role `root` may be granted to any user, in addition to the root user. A user with the `root` role has both global read-write access and permission to update the cluster's authentication configuration. Furthermore, the `root` role grants privileges for general cluster maintenance, including modifying cluster membership, defragmenting the store, and taking snapshots.

## Working with users

The `user` subcommand for `etcdctl` handles all things having to do with user accounts.

A listing of users can be found with:

```
$ etcdctl user list
```

Creating a user is as easy as

```
$ etcdctl user add myusername
```

Creating a new user will prompt for a new password. The password can be supplied from standard input when an option `--interactive=false` is given. `--new-user-password` can also be used for supplying the password.

Creating a user which cannot be authenticated with password is also possible like below:

```
$ etcdctl user add myusername --no-password
```

Such a user can only be [authenticated with TLS Common Name](#using-tls-common-name).

{{% alert title="Note" %}}
etcd does not support authentication with an empty password via `--user username:`. For example, a user created with an empty password, such as `etcdctl user add anonymous:''`, cannot authenticate through username/password requests and requests such as `etcdctl --user anonymous: get foo` fail with `user name is empty`.
{{% /alert %}}

Roles can be granted and revoked for a user with:

```
$ etcdctl user grant-role myusername foo
$ etcdctl user revoke-role myusername bar
```

The user's settings can be inspected with:

```
$ etcdctl user get myusername
```

And the password for a user can be changed with

```
$ etcdctl user passwd myusername
```

Changing the password will prompt again for a new password. The password can be supplied from standard input when an option `--interactive=false` is given.

Delete an account with:
```
$ etcdctl user delete myusername
```


## Working with roles

The `role` subcommand for `etcdctl` handles all things having to do with access controls for particular roles, as were granted to individual users.

List roles with:

```
$ etcdctl role list
```

Create a new role with:

```
$ etcdctl role add myrolename
```

A role has no password; it merely defines a new set of access rights.

Roles are granted access to a single key or a range of keys.

The range can be specified as an interval [start-key, end-key) where start-key should be lexically less than end-key in an alphabetical manner.

Access can be granted as either read, write, or both, as in the following examples:

```
# Give read access to a key /foo
$ etcdctl role grant-permission myrolename read /foo

# Give read access to keys with a prefix /foo/. The prefix is equal to the range [/foo/, /foo0)
$ etcdctl role grant-permission myrolename --prefix=true read /foo/

# Give write-only access to the key at /foo/bar
$ etcdctl role grant-permission myrolename write /foo/bar

# Give full access to keys in a range of [key1, key5)
$ etcdctl role grant-permission myrolename readwrite key1 key5

# Give full access to keys with a prefix /pub/
$ etcdctl role grant-permission myrolename --prefix=true readwrite /pub/
```

To see what's granted, we can look at the role at any time:

```
$ etcdctl role get myrolename
```

Revocation of permissions is done the same logical way:

```
$ etcdctl role revoke-permission myrolename /foo/bar
```

As is removing a role entirely:

```
$ etcdctl role delete myrolename
```

## Enabling authentication

The minimal steps to enabling auth are as follows. The administrator can set up users and roles before or after enabling authentication, as a matter of preference.

Make sure the root user is created:

```
$ etcdctl user add root
Password of root:
```

Enable authentication:

```
$ etcdctl auth enable
```

After this, etcd is running with authentication enabled. To disable it for any reason, use the reciprocal command:

```
$ etcdctl --user root:rootpw auth disable
```

## Security Scope of Authentication

When authentication is enabled with `etcdctl auth enable`, it protects the V3 gRPC API operations (get, put, delete, watch, etc.).

The `/metrics` and `/health` HTTP endpoints operate on a separate handler and are **not** protected by V3 RBAC authentication. This design allows Prometheus and load balancers to scrape metrics without requiring gRPC authentication, while still protecting the key-value data.

To secure these observability endpoints:

- Enable mTLS with `--cert-file`, `--key-file`, and `--client-cert-auth`
- Or bind metrics to a private interface using `--listen-metrics-urls`
- Or use network policies/firewall rules to restrict access

## Using `etcdctl` to authenticate

`etcdctl` supports a similar flag as `curl` for authentication.

```
$ etcdctl --user user:password get foo
```

The password can be taken from a prompt:

```
$ etcdctl --user user get foo
```

The password can also be taken from a command line flag `--password`:

```
$ etcdctl --user user --password password get foo
```


Otherwise, all `etcdctl` commands remain the same. Users and roles can still be created and modified, but require authentication by a user with the root role.

## Using TLS Common Name

As of etcd v3.2, when the server is started with `--client-cert-auth=true`, clients can authenticate **as an etcd user without a password** by putting that username in the certificate **Common Name (CN)**.

### How it works

1. Create an etcd user whose name matches the certificate CN (for example user `alice`).
2. Grant that user the roles it needs (`etcdctl user grant-role ...`).
3. Issue a client certificate whose **Subject CN** is exactly that username.
4. Start etcd with client certificate authentication enabled (and a trusted CA):

```bash
etcd --client-cert-auth --trusted-ca-file=ca.crt \
  --cert-file=server.crt --key-file=server.key \
  # ... other flags
```

5. Call etcd with the client cert (no `--user` / password required):

```bash
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=ca.crt --cert=alice.crt --key=alice.key \
  get /foo
```

etcd maps the cert CN to the etcd user and applies that user's RBAC permissions.

### Password vs CN: which wins?

If the client sends **both**:

1. a client certificate with a CN (and `--client-cert-auth=true` on the server), **and**
2. username/password credentials,

**username/password authentication is preferred.** The CN is ignored for that request.

### Limitations (gRPC-proxy and gRPC-gateway)

TLS Common Name authentication **does not work** through:

| Component | Why |
|-----------|-----|
| **gRPC-proxy** | The proxy terminates client TLS and re-connects with its own cert. Every downstream client would look like the proxy identity. If a client cert presents a non-empty CN, gRPC-proxy errors and stops. |
| **gRPC-gateway** | HTTP is translated to gRPC over an internal TLS connection that does not forward the original client CN. |

Use password users (or terminate auth at another layer) for traffic that must go through the proxy or gateway.

## Notes on password strength
The `etcdctl` and etcd API do not enforce a specific password length during user creation or user password update operations. It is the responsibility of the administrator to enforce these requirements. For avoiding security risks related to password strength, [TLS Common Name based authentication](#using-tls-common-name) and users created with `--no-password` option can be utilized.
