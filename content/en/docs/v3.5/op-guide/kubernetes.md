---
title: Run etcd clusters as a Kubernetes StatefulSet
weight: 4200
description: Running etcd as a Kubernetes StatefulSet
---

Below demonstrates how to perform the [static bootstrap process](../clustering/#static) as a Kubernetes StatefulSet.

## Example Manifest
This manifest contains a service and statefulset for deploying a static etcd cluster in kubernetes.

If you copy the contents of the manifest into a file named `etcd.yaml`, it can be applied to a cluster with this command.

```shell
$ kubectl apply --filename etcd.yaml
```

Upon being applied, wait for the pods to become ready.

```shell
$ kubectl get pods
NAME     READY   STATUS    RESTARTS   AGE
etcd-0   1/1     Running   0          24m
etcd-1   1/1     Running   0          24m
etcd-2   1/1     Running   0          24m
```

The container used in the example includes etcdctl and can be called directly inside the pods.

```shell
$ kubectl exec -it etcd-0 -- etcdctl member list -wtable
+------------------+---------+--------+-------------------------+-------------------------+------------+
|        ID        | STATUS  |  NAME  |       PEER ADDRS        |      CLIENT ADDRS       | IS LEARNER |
+------------------+---------+--------+-------------------------+-------------------------+------------+
| 4f98c3545405a0b0 | started | etcd-2 | http://etcd-2.etcd:2380 | http://etcd-2.etcd:2379 |      false |
| a394e0ee91773643 | started | etcd-0 | http://etcd-0.etcd:2380 | http://etcd-0.etcd:2379 |      false |
| d10297b8d2f01265 | started | etcd-1 | http://etcd-1.etcd:2380 | http://etcd-1.etcd:2379 |      false |
+------------------+---------+--------+-------------------------+-------------------------+------------+
```

To deploy with a self-signed certificate, refer to the commented configuration headings starting with `## TLS` to find values that you can uncomment. Additional instructions for generating a cert with cert-manager is included in a section below.

```yaml
# file: etcd.yaml
---
apiVersion: v1
kind: Service
metadata:
  name: etcd
  namespace: default
spec:
  type: ClusterIP
  clusterIP: None
  selector:
    app: etcd
  ##
  ## Ideally we would use SRV records to do peer discovery for initialization.
  ## Unfortunately discovery will not work without logic to wait for these to
  ## populate in the container. This problem is relatively easy to overcome by
  ## making changes to prevent the etcd process from starting until the records
  ## have populated. The documentation on statefulsets briefly talk about it.
  ##   https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/#stable-network-id
  publishNotReadyAddresses: true
  ##
  ## The naming scheme of the client and server ports match the scheme that etcd
  ## uses when doing discovery with SRV records.
  ports:
  - name: etcd-client
    port: 2379
  - name: etcd-server
    port: 2380
  - name: etcd-metrics
    port: 8080
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  namespace: default
  name: etcd
spec:
  ##
  ## The service name is being set to leverage the service headlessly.
  ## https://kubernetes.io/docs/concepts/services-networking/service/#headless-services
  serviceName: etcd
  ##
  ## If you are increasing the replica count of an existing cluster, you should
  ## also update the --initial-cluster-state flag as noted further down in the
  ## container configuration.
  replicas: 3
  ##
  ## For initialization, the etcd pods must be available to eachother before
  ## they are "ready" for traffic. The "Parallel" policy makes this possible.
  podManagementPolicy: Parallel
  ##
  ## To ensure availability of the etcd cluster, the rolling update strategy
  ## is used. For availability, there must be at least 51% of the etcd nodes
  ## online at any given time.
  updateStrategy:
    type: RollingUpdate
  ##
  ## This is label query over pods that should match the replica count.
  ## It must match the pod template's labels. For more information, see the
  ## following documentation:
  ##   https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
  selector:
    matchLabels:
      app: etcd
  ##
  ## Pod configuration template.
  template:
    metadata:
      ##
      ## The labeling here is tied to the "matchLabels" of this StatefulSet and
      ## "affinity" configuration of the pod that will be created.
      ##
      ## This example's labeling scheme is fine for one etcd cluster per
      ## namespace, but should you desire multiple clusters per namespace, you
      ## will need to update the labeling schema to be unique per etcd cluster.
      labels:
        app: etcd
      annotations:
        ##
        ## This gets referenced in the etcd container's configuration as part of
        ## the DNS name. It must match the service name created for the etcd
        ## cluster. The choice to place it in an annotation instead of the env
        ## settings is because there should only be 1 service per etcd cluster.
        serviceName: etcd
    spec:
      ##
      ## Configuring the node affinity is necessary to prevent etcd servers from
      ## ending up on the same hardware together.
      ##
      ## See the scheduling documentation for more information about this:
      ##   https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
      affinity:
        ## The podAntiAffinity is a set of rules for scheduling that describe
        ## when NOT to place a pod from this StatefulSet on a node.
        podAntiAffinity:
          ##
          ## When preparing to place the pod on a node, the scheduler will check
          ## for other pods matching the rules described by the labelSelector
          ## separated by the chosen topology key.
          requiredDuringSchedulingIgnoredDuringExecution:
          ## This label selector is looking for app=etcd
          - labelSelector:
              matchExpressions:
              - key: app
                operator: In
                values:
                - etcd
            ## This topology key denotes a common label used on nodes in the
            ## cluster. The podAntiAffinity configuration essentially states
            ## that if another pod has a label of app=etcd on the node, the
            ## scheduler should not place another pod on the node.
            ##   https://kubernetes.io/docs/reference/labels-annotations-taints/#kubernetesiohostname
            topologyKey: "kubernetes.io/hostname"
      ##
      ## Containers in the pod
      containers:
      ## This example only has this etcd container.
      - name: etcd
        image: quay.io/coreos/etcd:{{< param git_version_tag >}}
        imagePullPolicy: IfNotPresent
        ports:
        - name: etcd-client
          containerPort: 2379
        - name: etcd-server
          containerPort: 2380
        - name: etcd-metrics
          containerPort: 8080
        ##
        ## These probes will fail over TLS for self-signed certificates, so etcd
        ## is configured to deliver metrics over port 8080 further down.
        ##
        ## As mentioned in the "Monitoring etcd" page, /readyz and /livez were
        ## added in v3.5.12. Prior to this, monitoring required extra tooling
        ## inside the container to make these probes work.
        ##
        ## The values in this readiness probe should be further validated, it
        ## is only an example configuration.
        readinessProbe:
          httpGet:
            path: /readyz
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 5
          successThreshold: 1
          failureThreshold: 30
        ## The values in this liveness probe should be further validated, it
        ## is only an example configuration.
        livenessProbe:
          httpGet:
            path: /livez
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        env:
        ##
        ## Environment variables defined here can be used by other parts of the
        ## container configuration. They are interpreted by Kubernetes, instead
        ## of in the container environment.
        ##
        ## These env vars pass along information about the pod.
        - name: K8S_NAMESPACE
          valueFrom:
            fieldRef:
             fieldPath: metadata.namespace
        - name: HOSTNAME
          valueFrom:
            fieldRef:
             fieldPath: metadata.name
        - name: SERVICE_NAME
          valueFrom:
            fieldRef:
              fieldPath: metadata.annotations['serviceName']
        ##
        ## Configuring etcdctl inside the container to connect to the etcd node
        ## in the container reduces confusion when debugging.
        - name: ETCDCTL_ENDPOINTS
          value: $(HOSTNAME).$(SERVICE_NAME):2379
        ##
        ## TLS client configuration for etcdctl in the container.
        ## These files paths are part of the "etcd-client-certs" volume mount.
        # - name: ETCDCTL_KEY
        #   value: /etc/etcd/certs/client/tls.key
        # - name: ETCDCTL_CERT
        #   value: /etc/etcd/certs/client/tls.crt
        # - name: ETCDCTL_CACERT
        #   value: /etc/etcd/certs/client/ca.crt
        ##
        ## Use this URI_SCHEME value for non-TLS clusters.
        - name: URI_SCHEME
          value: "http"
        ## TLS: Use this URI_SCHEME for TLS clusters.
        # - name: URI_SCHEME
        # value: "https"
        ##
        ## If you're using a different container, the executable may be in a
        ## different location. This example uses the full path to help remove
        ## ambiguity to you, the reader.
        ## Often you can just use "etcd" instead of "/usr/local/bin/etcd" and it
        ## will work because the $PATH includes a directory containing "etcd".
        command:
        - /usr/local/bin/etcd
        ##
        ## Arguments used with the etcd command inside the container.
        args:
        ##
        ## Configure the name of the etcd server.
        - --name=$(HOSTNAME)
        ##
        ## Configure etcd to use the persistent storage configured below.
        - --data-dir=/data
        ##
        ## In this example we're consolidating the WAL into sharing space with
        ## the data directory. This is not ideal in production environments and
        ## should be placed in it's own volume.
        - --wal-dir=/data/wal
        ##
        ## URL configurations are parameterized here and you shouldn't need to
        ## do anything with these.
        - --listen-peer-urls=$(URI_SCHEME)://0.0.0.0:2380
        - --listen-client-urls=$(URI_SCHEME)://0.0.0.0:2379
        - --advertise-client-urls=$(URI_SCHEME)://$(HOSTNAME).$(SERVICE_NAME):2379
        ##
        ## This must be set to "new" for initial cluster bootstrapping. To scale
        ## the cluster up, this should be changed to "existing" when the replica
        ## count is increased. If set incorrectly, etcd makes an attempt to
        ## start but fail safely.
        - --initial-cluster-state=new
        ##
        ## Token used for cluster initialization. The recommendation for this is
        ## to use a unique token for every cluster. This example parameterized
        ## to be unique to the namespace, but if you are deploying multiple etcd
        ## clusters in the same namespace, you should do something extra to
        ## ensure uniqueness amongst clusters.
        - --initial-cluster-token=etcd-$(K8S_NAMESPACE)
        ##
        ## The initial cluster flag needs to be updated to match the number of
        ## replicas configured. When combined, these are a little hard to read.
        ## Here is what a single parameterized peer looks like:
        ##   etcd-0=$(URI_SCHEME)://etcd-0.$(SERVICE_NAME):2380
        - --initial-cluster=etcd-0=$(URI_SCHEME)://etcd-0.$(SERVICE_NAME):2380,etcd-1=$(URI_SCHEME)://etcd-1.$(SERVICE_NAME):2380,etcd-2=$(URI_SCHEME)://etcd-2.$(SERVICE_NAME):2380
        ##
        ## The peer urls flag should be fine as-is.
        - --initial-advertise-peer-urls=$(URI_SCHEME)://$(HOSTNAME).$(SERVICE_NAME):2380
        ##
        ## This avoids probe failure if you opt to configure TLS.
        - --listen-metrics-urls=http://0.0.0.0:8080
        ##
        ## These are some configurations you may want to consider enabling, but
        ## should look into further to identify what settings are best for you.
        # - --auto-compaction-mode=periodic
        # - --auto-compaction-retention=10m
        ##
        ## TLS client configuration for etcd, reusing the etcdctl env vars.
        # - --client-cert-auth
        # - --trusted-ca-file=$(ETCDCTL_CACERT)
        # - --cert-file=$(ETCDCTL_CERT)
        # - --key-file=$(ETCDCTL_KEY)
        ##
        ## TLS server configuration for etcdctl in the container.
        ## These files paths are part of the "etcd-server-certs" volume mount.
        # - --peer-client-cert-auth
        # - --peer-trusted-ca-file=/etc/etcd/certs/server/ca.crt
        # - --peer-cert-file=/etc/etcd/certs/server/tls.crt
        # - --peer-key-file=/etc/etcd/certs/server/tls.key
        ##
        ## This is the mount configuration.
        volumeMounts:
        - name: etcd-data
          mountPath: /data
        ##
        ## TLS client configuration for etcdctl
        # - name: etcd-client-tls
        #   mountPath: "/etc/etcd/certs/client"
        #   readOnly: true
        ##
        ## TLS server configuration
        # - name: etcd-server-tls
        #   mountPath: "/etc/etcd/certs/server"
        #   readOnly: true
      volumes:
      ##
      ## TLS client configuration
      # - name: etcd-client-tls
      #   secret:
      #     secretName: etcd-client-tls
      #     optional: false
      ##
      ## TLS server configuration
      # - name: etcd-server-tls
      #   secret:
      #     secretName: etcd-server-tls
      #     optional: false
  ##
  ## This StatefulSet will uses the volumeClaimTemplate field to create a PVC in
  ## the cluster for each replica. These PVCs can not be easily resized later.
  volumeClaimTemplates:
  - metadata:
      name: etcd-data
    spec:
      accessModes: ["ReadWriteOnce"]
      ##
      ## In some clusters, it is necessary to explicitly set the storage class.
      ## This example will end up using the default storage class.
      # storageClassName: ""
      resources:
        requests:
          storage: 1Gi
```

## Generating Certificates
In this section, we use [Helm](https://helm.sh) to install an operator called [cert-manager](https://cert-manager.io/).

With cert-manager installed in the cluster, self-signed certificates can be generated in the cluster. These generated certificates get placed inside a secret object that can be attached as files in containers.

This is the helm command to install cert-manager.

```shell
$ helm upgrade --install --create-namespace --namespace cert-manager cert-manager cert-manager --repo https://charts.jetstack.io --set crds.enabled=true
```

This is an example ClusterIssuer configuration for generating self-signed certificates.

```yaml
# file: issuer.yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
```

This manifest creates Certificate objects for the client and server certs, referencing the ClusterIssuer "selfsigned". The dnsNames should be an exhaustive list of valid hostnames for the certificates that cert-manager creates.

```yaml
# file: certificates.yaml
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: etcd-server
  namespace: default
spec:
  secretName: etcd-server-tls
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
  commonName: etcd
  dnsNames:
  - etcd
  - etcd.default
  - etcd.default.svc.cluster.local
  - etcd-0
  - etcd-0.etcd
  - etcd-0.etcd.default
  - etcd-0.etcd.default.svc
  - etcd-0.etcd.default.svc.cluster.local
  - etcd-1
  - etcd-1.etcd
  - etcd-1.etcd.default
  - etcd-1.etcd.default.svc
  - etcd-1.etcd.default.svc.cluster.local
  - etcd-2
  - etcd-2.etcd
  - etcd-2.etcd.default
  - etcd-2.etcd.default.svc
  - etcd-2.etcd.default.svc.cluster.local
---
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: etcd-client
  namespace: default
spec:
  secretName: etcd-client-tls
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
  commonName: etcd
  dnsNames:
  - etcd
  - etcd.default
  - etcd.default.svc.cluster.local
  - etcd-0
  - etcd-0.etcd
  - etcd-0.etcd.default
  - etcd-0.etcd.default.svc
  - etcd-0.etcd.default.svc.cluster.local
  - etcd-1
  - etcd-1.etcd
  - etcd-1.etcd.default
  - etcd-1.etcd.default.svc
  - etcd-1.etcd.default.svc.cluster.local
  - etcd-2
  - etcd-2.etcd
  - etcd-2.etcd.default
  - etcd-2.etcd.default.svc
  - etcd-2.etcd.default.svc.cluster.local
```
