# Installation Instructions for MarkLogic v10.0.1 on a PKS K8s Cluster

- MarkLogic installation instructions for a v10.0.1 version of MarkLogic on a [PKS](https://pivotal.io/platform/pivotal-container-service) v1.5.0 K8s v1.14.5 Cluster 
- I'm using a Mac (not a Windows PC) and following the instructions in this [blog](https://www.marklogic.com/blog/docker-deploy-kubernetes/) with some changes to accommodate my target environment
- Start by cloning this repo into a `/work` directory:

```
cd /work
git clone https://github.com/rm511130/marklogic
cd /work/marklogic
```

- The [Dockerfile](https://github.com/rm511130/MarkLogic/blob/master/Dockerfile) in this folder points to a MarkLogic-10.0-1.x86_64.rpm file which must exist in the same directory.
- MarkLogic-10.0-1.x86_64.rpm needs to be downloaded directly from [MarkLogic's Product Web site](http://developer.marklogic.com/products)

```
docker build -t rmeira/marklogicv10:v1 .
docker push rmeira/marklogicv10:v1
```

- Now take a look at the `nginx` subdirectory and the steps you must execute there to get the Nginx image. We will start Nginx with the following sequence of commands:

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




