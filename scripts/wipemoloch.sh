#!/bin/bash
echo "Checking ES"
until curl -u $ELASTIC_USERNAME:$ELASTIC_PASSWORD -sS "https://elasticsearch:9200/_cluster/health?wait_for_status=green"
do
    echo "Waiting for ES to start"
    sleep 1
done
#Wipe is the same initalize except it keeps users intact
echo WIPE | /data/moloch/db/db.pl http://$ES_HOST:$ES_PORT wipe
