#!/bin/bash


# Wait for Elasticsearch to start up before doing anything.
until curl -u elastic:changeme -s http://es01:9200/_cat/health -o /dev/null; do
    echo Waiting for Elasticsearch...
    sleep 1
done

echo "Setting Elasticsearch password to ${ES_PASSWORD}"
curl -s -XPUT -u elastic:changeme 'es01:9200/_xpack/security/user/elastic/_password' -H "Content-Type: application/json" -d "{
  \"password\" : \"${ES_PASSWORD}\"
}"

curl -s -XPUT -u elastic:${ES_PASSWORD} 'es01:9200/_xpack/security/user/kibana/_password' -H "Content-Type: application/json" -d "{
  \"password\" : \"${ES_PASSWORD}\"
}"

curl -s -XPUT -u elastic:${ES_PASSWORD} 'es01:9200/_xpack/security/user/logstash_system/_password' -H "Content-Type: application/json" -d "{
  \"password\" : \"${ES_PASSWORD}\"
}"


# Wait for Kibana to start up before doing anything.
until curl -s http://kibana:5601/login -o /dev/null; do
    echo Waiting for Kibana...
    sleep 1
done

# Set the default index pattern.
curl -s -XPUT http://elastic:${ES_PASSWORD}@es01:9200/.kibana/config/${ELASTIC_VERSION} \
     -d "{\"defaultIndex\" : \"${ES_DEFAULT_INDEX_PATTERN}\"}"
