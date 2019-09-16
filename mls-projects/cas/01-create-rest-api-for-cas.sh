curl --anyauth \
     --user admin:password \
     -X POST -d"@/work/marklogic/mls-projects/cas/rest-config.json" \
     -i -H "Content-type: application/json" \
     http://10.0.110.7:8002/v1/rest-apis
