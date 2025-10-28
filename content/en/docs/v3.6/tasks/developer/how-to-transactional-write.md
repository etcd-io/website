---
title: How to make multiple writes in a transaction
description: Guide to making transactional writes
weight: 500
---


## Prerequisites

* Install [`etcd` and `etcdctl`](https://etcd.io/docs/v3.6/install/).
* A running `etcd` cluster.

## Terminology

Here are definitions of some key terms used in the [Example](#example) below.

| Terms | Definition |
| --- | --- |
| [etcdctl](https://github.com/etcd-io/etcd/blob/main/etcdctl/README.md#etcdctl) | The command line tool for interacting with the etcd server. |
| [`txn`](https://github.com/etcd-io/etcd/blob/main/etcdctl/README.md#txn-options) command | `txn` command is an abbreviation for "transaction". It reads multiple etcd requests from standard input and applies them as a single atomic transaction. A transaction consists of list of conditions, a list of requests to apply if all the conditions are true, and a list of requests to apply if any condition is false. View [etcdctl key-value commands](https://github.com/etcd-io/etcd/blob/main/etcdctl/README.md#key-value-commands) for more information.|
| `compare` | The `compare` clause within a transaction (`txn`) serves as a conditional check that determines whether the transaction's operations should proceed. It ensures changes are only applied if the current state of the key-value store matches expected conditions, thereby maintaining data consistency and preventing conflicts in concurrent environments. To see how the command is structured, view [Perform a transaction](#2-perform-a-transaction) section below.|

## Transactions

`txn` to process all the requests in one transaction:

```bash
etcdctl txn --help
```

Transactions in etcd allow you to execute multiple operations atomically, ensuring that either all operations are applied or none are. This is crucial for maintaining data consistency when performing related updates. Learn more about transactions in [the API documentation](https://etcd.io/docs/v3.6/learning/api/#transaction).

### Example

Let's consider a scenario where you want to update a user's email and phone number in a single transaction. This ensures that both updates are applied together.

![05_etcdctl_transaction_2024101213](https://github.com/user-attachments/assets/01320212-b824-40b0-8a33-c6d74c600248)

#### 0. Variables and Flags used

| Variables |
| :--- |
| `/users/{<user_id>/email` : etcd key representing a user's email address.|
| `/users/<user_id>/phone` : etcd key representing a user's phone number.|
| **Flags** |
| [`--interactive`](https://github.com/etcd-io/etcd/blob/main/etcdctl/README.md#options-3) : A flag to allow inputting transaction data manually|

#### 1. Set up initial data

First, create a user with some initial data.

   ```shell
   etcdctl put /users/12345/email "old.address@johndoe.com"
   etcdctl put /users/12345/phone "123-456-7890"
   ```

#### 2. Perform a transaction

Update the user's email and phone number in a single transaction.

   ```shell
   etcdctl txn --interactive

   compares:
   value("/users/12345/email") = "old.address@johndoe.com"

   success requests (get, put, delete):
   put /users/12345/email "new.address@johndoe.com"
   put /users/12345/phone "098-765-4321"

   failure requests (get, put, delete):
   get /users/12345/email
   ```

* **Compare**: Check if the current email is "<old.address@johndoe.com>". This ensures the transaction only proceeds if the data is as expected.
* **Success**: If the comparison is true, update both the email and phone number.
* **Failure**: If the comparison fails, retrieve the current email to understand why the transaction didn't proceed.

### Important considerations

* **Atomicity**: The transaction ensures that both the email and phone number are updated together. If the initial condition (comparison) is not met, neither update is applied.
* **Consistency**: Using transactions maintains data consistency, especially when dealing with multiple related updates.
* **Avoid multiple puts on the same key**: Do not put multiple values for the same key within a single transaction, as this can lead to unexpected results. Each key should be updated only once per transaction.
