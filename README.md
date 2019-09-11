# Installation Instructions for MarkLogic on a PKS K8s Cluster

- [MarkLogic](https://www.marklogic.com/) v10.0.1 installation on a [PKS](https://pivotal.io/platform/pivotal-container-service) v1.5.0 Kubernetes v1.14.5 Cluster 
- I'm using a Mac (not a Windows PC) and following the instructions in this [blog](https://www.marklogic.com/blog/docker-deploy-kubernetes/) with some changes to accommodate my target environment

## 1. Start by cloning this repo into a `/work` directory:

```
mkdir -p /work; cd /work
git clone https://github.com/rm511130/marklogic
cd /work/marklogic
```

## 2. Creation of MarkLogic Docker Image

- You can skip step #2 by opting to use the [Marklogic Image](https://cloud.docker.com/u/rmeira/repository/docker/rmeira/marklogic10) I have already built. There's actually nothing to be downloaded at this point in time because the scripts we will be using, later on, already point to the Docker Images in my Docker Hub repo.

- If you'd like to build your own Docker Image of Marklogic, then follow the instructions below.
- First, you will need to downlad [MarkLogic-10.0-1.x86_64.rpm](https://developer.marklogic.com/products/marklogic-server/10.0) directly from [MarkLogic's Product Web site](http://developer.marklogic.com/products) and this step will entail creating a MarkLogic user account.
- If you open the [Dockerfile](https://github.com/rm511130/MarkLogic/blob/master/Dockerfile) in this folder, you will see that it points to a MarkLogic-10.0-1.x86_64.rpm file which must exist in the same `/work/marklogic` directory. If when you download the .rpm file its name has changed, you'll need to update your Dockerfile contents.
- The specific `docker build` and `docker push` commands shown below serve to create a [MarkLogic Docker Image](https://cloud.docker.com/u/rmeira/repository/docker/rmeira/marklogic10) in my (rmeira) public Docker Hub repo. You should replace the `rmeira` part of the commands with your own Docker Username or you can leverage the image I've already built.

```
docker build -t rmeira/marklogicv10:v1 .   # the dot is important, do not delete it
docker push rmeira/marklogicv10:v1
```

## 3. Creation of an Nginx Ingress Controller Docker Image 

- Once again, just like in the previous step #2, you can simply opt to use the [Nginx Docker Image](https://cloud.docker.com/u/rmeira/repository/docker/rmeira/marklogic-nginx) I've already built using the very same steps described below. If you plan to do so, go ahead and skip to step #4. There's no need to download anything at this point, because the scripts we will be using already point to `rmeira/marklogic-nginx`.

- If you'd like to build your own Nginx Docker Image, then follow the instructions below.
- Execute `cd /work/marklogic/nginx` and take a look at `nginx` subdirectory. There's a Dockerfile 



and the steps you must execute there to get the Nginx image. We will start Nginx with the following sequence of commands:

```
cd /work/marklogic                           # to make sure we're back from the /work/marklogic/nginx directory
kubectl create -f registry-secret.yml
kubectl create -f ml-service.yml
kubectl create -f stateful-set.yml
cd /work/marklogic-nginx
kubectl create -f nginx-ingress.rc.yml
```

- Now let's take a look:

```
kubectl proxy
open http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview
```




