---
title: 
spelling: 
author:  
date: 2021-08-17
draft: false
---
Please read the article by [Article by Martin](https://martin.kleppmann.com/2016/02/08/how-to-do-distributed-locking.html) before going to this blog.
Why can't lease based lock service provide a mutual exclusion to processes?
Reason : This is because such a lease mechanism depends on the physical clock of both the lock service and client processes. Many factors.

Now the question arises, how can we solve this problem? Such a problem can be solved with a technique called version number validation or fencing tokens. With this technique a shared resource needs to validate requests from clients based on their tokens.

What is Version Number Validation or fencing tokens?
When using a lock or lease to protect access to some resource, such as the file storage in Figure 8-4, we need to ensure that a node that is under a false belief of being “the chosen one” cannot disrupt the rest of the system.

The directory contains two programs: 
1. client. 
2. storage.

With etcd, you can reproduce the expired lease problem of distributed locking and a simple example solution of the validation technique which can avoid incorrect access from a client with an expired lease.

How does it work?
1. storage : storage works as a very simple key value in-memory store which is accessible through HTTP and a custom JSON protocol.
2. client : client works as client processes which tries to write a key/value to storage with coordination of etcd locking.

How to build them?
In order to  build client and storage, just execute go build in each directory.

How to try them?
1. At first you need to start an etcd cluster
2. On top of the etcd source directory, execute commands like:
- $ ./build      # build etcd
$ goreman start

3. Then run storage command in storage directory:
- $ ./storage

4. Now client processes ("Client 1" and "Client 2" in the figures) can be started. At first, execute below command for starting a client process which corresponds to "Client 1":
- $ GODEBUG=gcstoptheworld=2 ./client 1

5. The output will come like this:
- client 1 starts
creted etcd client
acquired lock, version: 1029195466614598192
took 6.771998255s for allocation, took 36.217205ms for GC
emulated stop the world GC, make sure the /lock/* key disappeared and hit any key after executing client 2:

6. The process causes stop the world GC pause for making lease expiration intentionally and waits a keyboard input. Now another client process can be started like this:
- $ ./client 2
client 2 starts
creted etcd client
acquired lock, version: 4703569812595502727
this is client 2, continuing

7. If things go well the second client process invoked as ./client 2 finishes soon. It successfully writes a key to storage process. After checking this, please hit any key for ./client 1 and resume the process. It will show an output like below:
- resuming client 1
failed to write to storage: error: given version (4703569812595502721) differ from the existing version (4703569812595502727)

Parameters related to stop the world GC pause:
- client program includes two constant values: nrGarbageObjects and sessionTTL. 
- These parameters are configured for causing lease expiration with stop the world GC pause of go runtime. 
- They heavily rely on resources of a machine for executing the example. If lease expiration doesn't happen on your machine, update these parameters and try again.


