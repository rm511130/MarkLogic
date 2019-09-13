# Installation Instructions for MarkLogic on a PKS K8s Cluster

- [MarkLogic](https://www.marklogic.com/) v10.0.1 installation on a [PKS](https://pivotal.io/platform/pivotal-container-service) v1.5.0 Kubernetes v1.14.5 Cluster 
- I'm using a Mac (not a Windows PC) and following the instructions in Bill Miller's [blog](https://www.marklogic.com/blog/docker-deploy-kubernetes/) with some changes to accommodate my target environment
- I also have Docker Desktop Community v2.1.0.2 (37877) on my Mac.

## 1. Start by cloning this repo into a `/work` directory:

```
mkdir -p /work; cd /work
git clone https://github.com/rm511130/marklogic
cd /work/marklogic
```

## 2. Optional creation of MarkLogic Docker Image

- You can skip step #2 by opting to use the [Marklogic v10 Image](https://cloud.docker.com/u/rmeira/repository/docker/rmeira/marklogic10) I have already built. There's actually nothing to be downloaded at this point in time because the scripts we will be using later on, already point to the Docker Images in my Docker Hub repo.

- If you'd like to build your own Docker Image of Marklogic, then follow the instructions below.
- First, you will need to downlad [MarkLogic-10.0-1.x86_64.rpm](https://developer.marklogic.com/products/marklogic-server/10.0) directly from [MarkLogic's Product Web site](http://developer.marklogic.com/products) and this step will entail creating a MarkLogic user account.
- If you open the [Dockerfile](https://github.com/rm511130/MarkLogic/blob/master/Dockerfile) in this folder, you will see that it points to a `MarkLogic-10.0-1.x86_64.rpm` file which must exist in the same `/work/marklogic` directory. When you download the `.rpm` file its name or version may have changed, so you'll need to update your Dockerfile contents to match the new name.
- You can find more details [here](https://www.marklogic.com/blog/docker-deploy-kubernetes/) about the four initialization scripts `mlconfig.sh`, `entry-point.sh`, `setup-child.sh` and `setup-master.sh` used by the Dockerfile to create the MarkLogic v10 Docker Image. Please look through [`mlconfig.sh`](https://github.com/rm511130/MarkLogic/blob/master/mlconfig.sh) because it contains passwords you may wish to change.
- The specific `docker build` and `docker push` commands shown below serve to create a [MarkLogic Docker Image](https://cloud.docker.com/u/rmeira/repository/docker/rmeira/marklogic10) in my (rmeira) public Docker Hub repo. You should replace the `rmeira` part of the commands with your own Docker Username.

```
cd /work/marklogic
docker build -t rmeira/marklogic10:v1 .   # the dot is important, do not delete it
docker push rmeira/marklogic10:v1
```

- Check your [Docker Hub](https://hub.docker.com/) repo to make sure your `marklogic10` image was uploaded properly.

## 3. Optional creation of an Nginx Ingress Controller Docker Image 

- Just like in the previous step #2, you can simply opt to use the [Nginx Docker Image](https://cloud.docker.com/u/rmeira/repository/docker/rmeira/marklogic-nginx) I've already built using the very same steps described below. If you plan to do so, go ahead and skip to step #4. There's no need to download anything at this point, because the scripts we will be using already point to my `rmeira/marklogic-nginx` docker image.

- If you'd like to build your own Nginx Docker Image, then follow the instructions below.
- Execute `cd /work/marklogic/nginx` and take a look at `nginx` subdirectory. There's a [Dockerfile](https://github.com/rm511130/MarkLogic/blob/master/nginx/Dockerfile) that describes how to build an Nginx Ingress controller Docker Image. Make sure to replace `rmeira` with your own Docker Username before executing the commands below.

```
cd /work/marklogic/nginx
docker build -t rmeira/marklogic-nginx:v1 .   # the dot is important
docker push rmeira/marklogic-nginx:v1
cd /work/marklogic
```

- Note that the Dockerfile instructs the build process to copy [`nginx.conf`](https://github.com/rm511130/MarkLogic/blob/master/nginx/nginx.conf) and [`upstream-defs.conf`](https://github.com/rm511130/MarkLogic/blob/master/nginx/upstream-defs.conf). You should take a quick look at these two files.
- Check your [Docker Hub](https://hub.docker.com/) repo to make sure your `marklogic-nginx` image was uploaded properly.

## 4. Creation of a Kubernetes Cluster

- I'm leveraging an existing PKS installation, so the process to create a K8s Cluster is quite simple:

```
pks login --api https://api.pks.pcf4u.com -k -u pks_admin -p password
pks create-cluster small --plan small --num-nodes 8 --external-hostname small.pks.pcf4u.com
```

- Proceed as follows:

```
pks cluster small  
```

- You should wait until you see `CREATE` and `succeeded` as shown below:

```
PKS Version:              1.5.0-build.32
Name:                     small
K8s Version:              1.14.5
Plan Name:                small
UUID:                     d08412d5-835b-47e3-83a3-eedb549ab892
Last Action:              CREATE
Last Action State:        succeeded
Last Action Description:  Instance provisioning completed
Kubernetes Master Host:   small.pks.pcf4u.com
Kubernetes Master Port:   8443
Worker Nodes:             8
Kubernetes Master IP(s):  10.0.110.1
Network Profile Name:
```

- A DNS entry was made to map `small.pks.pcf4u.com` to `10.0.110.1`

```
nslookup small.pks.pcf4u.com
```
```
Server:		1.1.1.1
Address:	1.1.1.1#53

Non-authoritative answer:
Name:	small.pks.pcf4u.com
Address: 10.0.110.1
```
- And let's get the cluster credentials so we can issue Kubectl commands:

```
pks get-credentials small
```
```
Fetching credentials for cluster small.
Context set for cluster small.

You can now switch between clusters by using:
$kubectl config use-context <cluster-name>
```
```
kubectl cluster-info
```
```
Kubernetes master is running at https://small.pks.pcf4u.com:8443
CoreDNS is running at https://small.pks.pcf4u.com:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

## 5. Registry Secret

- The [`registry-secret.yml`](https://github.com/rm511130/MarkLogic/blob/master/registry-secret.yml) contains instructions that need to be followed for the creation of your specific `dockerconfigjson` base64 secret.

- In my case, I had to execute:

```
openssl base64 -in /Users/rmeria/.docker/config.json -out /Users/rmeira/.docker/config_base64.txt
cat /Users/rmeria/.docker/config_base64.txt
```

## 6. Accessing the Kubernetes Dashboard

- Execute the following command to access your K8s Dashboard:

```
kubectl proxy --port=9999
```
- Open a browser using the following URL:

```
http://localhost:9999/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview
```

- When challenged to sign-in, follow the five steps shown below:

![](./images/k8s-dashboard.png)

- Leave the browser open and proceed to step #7.


## 7. Creating a MarkLogic v10 DB on K8s 

- With the `small` K8s cluster up and running, we need only execute the following commands:

```
cd /work/marklogic                      
kubectl create -f registry-secret.yml
kubectl create -f ml-service.yml
kubectl create -f stateful-set.yml
```

- Wait until you see the nine objects pointed out below by the yellow arrows, before proceeding with step #8.

![](./images/all-is-well.png)

- You may see a _SchedulerPredicates failed due to PersistentVolumeClaim is not bound_ error message, but, if you wait a couple of minutes, you will see that the message goes away once all the components are up and running.


## 8. Creating an Ingress Controller for our MarkLogic v10 on K8s 

- Execute the following commands:

```
cd /work/marklogic/nginx
kubectl create -f nginx-ingress.rc.yml
```

- And wait until you see:

   - a working nginx-rc ingress Pod
   - a working nginx-ingress-rc Replication Controller

- Now let's take a look at MarkLogic's Admin GUI. Follow the steps shown below:

![](./images/ml-dashboard.png)

- The MarkLogic Admin Interface enables you to:
- Manage basic software configuration
- Create and configure groups
- Create and manage databases
- Create and manage new forests
- Back up and restore forest content
- Create and manage new web server and Java-language access paths
- Create and manage security configurations
- Tune system performance
- Configure namespaces and schemas
- Check the status of resources on your systems





