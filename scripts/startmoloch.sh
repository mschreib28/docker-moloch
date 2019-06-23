#!/bin/sh

echo "Step 0"
echo "Update root certificate trust store..."
dpkg-reconfigure -f noninteractive ca-certificates
update-ca-certificates
export NODE_EXTRA_CA_CERTS=/usr/local/share/ca-certificates/root-certificate/ca.crt
echo "Added our own root certificate to trust store."

echo "Step 1"
echo "Giving ElasticSearch time to start..."
sleep 30
until curl -u ${ELASTIC_USERNAME}:${ELASTIC_PASSWORD} -sS "https://elasticsearch:9200/_cluster/health?wait_for_status=green"
do
    echo "Waiting for ES to start"
    sleep 1
done
echo

echo "Step 2"
echo "Update elasticsearch ssl cert to OS"
openssl s_client -CAfile /usr/local/share/ca-certificates/root-certificate/ca.crt -showcerts -connect elasticsearch:9200 </dev/null 2>/dev/null|openssl x509 -outform PEM > /tmp/elasticsearch.crt
mkdir /usr/local/share/ca-certificates/elasticsearch/
cp /tmp/elasticsearch.crt /usr/local/share/ca-certificates/elasticsearch/elasticsearch.pem
update-ca-certificates --fresh

echo "Step 3"
#Configure Moloch to Run
if [ ! -f /data/configured ]; then
	touch /data/configured
  chmod +x /data/moloch/bin/Configure
	/data/moloch/bin/Configure
fi
echo "Step 4"
#Give option to init ElasticSearch
if [ "$INITALIZEDB" = "true" ] ; then
	echo INIT | /data/moloch/db/db.pl https://$ELASTIC_USERNAME:$ELASTIC_PASSWORD@elasticsearch:9200 init
	/data/moloch/bin/moloch_add_user.sh admin "Admin User" $MOLOCH_PASSWORD --admin
fi
echo "Step 5"
#Give option to wipe ElasticSearch
if [ "$WIPEDB" = "true" ]; then
	/data/wipemoloch.sh
fi

echo "Look at log files for errors"
echo "  /data/moloch/logs/viewer.log"
echo "  /data/moloch/logs/capture.log"
echo "Visit http://127.0.0.1:8005 with your favorite browser."
echo "  user: admin"
echo "  password: $MOLOCH_PASSWORD"

if [ "$CAPTURE" = "on" ]
then
    echo "Launch capture..."
    if [ "$VIEWER" = "on" ]
    then
        # Background execution
        $MOLOCHDIR/bin/moloch-capture >> $MOLOCHDIR/logs/capture.log 2>&1 &
    else
        # If only capture, foreground execution
        $MOLOCHDIR/bin/moloch-capture |tee -a $MOLOCHDIR/logs/capture.log 2>&1
    fi
fi
echo "Step 6"
if [ "$VIEWER" = "on" ]
then
    echo "Launch viewer..."
   /bin/sh -c 'cd $MOLOCHDIR/viewer; export MOLOCH_NAME=$MOLOCH_NAME; $MOLOCHDIR/bin/node viewer.js -c $MOLOCHDIR/etc/config.ini | tee -a $MOLOCHDIR/logs/viewer.log 2>&1'
fi

echo "Step 7"
# Gotcha! I saved you, lets keep this sucker running :)
echo
echo
echo "Gotcha! I saved you, lets keep this sucker running :) Tailing /dev/null"
tail -f /dev/null
