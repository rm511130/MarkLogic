/work/mlcp/bin/mlcp.sh import -host 10.0.110.10 -port 8011 -username admin -password password -input_file_path /work/marklogic/mls-projects/news/docs_to_load -mode local -input_file_type documents -output_collections "http://www.bbc.co.uk/news/content" -output_uri_replace "/work/marklogic/mls-projects/news/docs_to_load,`content/news`"

