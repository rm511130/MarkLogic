# NGINX container to manage ingress/access to each MarkLogic node

- A few commands are necessary to create an Nginx Ingress image:

```
cd /work/marklogic/nginx
docker build -t rmeira/marklogic-nginx:v1 .
docker push rmeira/marklogic-nginx:v1
cd /work/marklogic
```
