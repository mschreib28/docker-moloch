
## Docker Moloch on a fully secured Elasticsearch, Kibana stack!

Image is based on the [ubuntu](https://registry.hub.docker.com/u/ubuntu/) base image  
Designed to get up and running quickly. Loads the viewer by default allowing you to parse large PCAPS within minutes.  
## Built on the excellent work of these 4 projects

https://github.com/MathieM/docker-moloch  
https://github.com/MathieM/docker-compose-moloch  
https://github.com/danielguerra69  
https://github.com/piesecurity/docker-moloch

## Setup summary
1. Setup prerequisites
2. Clone the repository
3. Set variables
4. Generate Root and Elasticsearch, Kibana, Moloch certificates
5. Bring up the stack

## Quick Start - Linux
1. Prerequisites. Install Docker // Docker Compose // Configure Kernel
```
# Install Docker
curl -fsSL get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Increase Max Map Count for Elastic Search
sysctl -w vm.max_map_count=262144
```
2. Clone the repository
```
git clone https://github.com/rodgermoore/docker-moloch.git
cd ./docker-moloch
```
3. Change (environmental) variables in .env, ./certificates/instances.yml, config.ini
.env
```
# CERTIFICATES
CA_CN=The Change Me Organisation
CA_PASS=CHANGE_THIS_PASS
CERTS_DIR=/usr/share/elasticsearch/config/certificates

# ES KIBANA VERSION
ES_KI_VERSION=6.8.0

# ELASTICSEARCH
ELASTIC_NAME=es-node1
ELASTIC_USERNAME=elastic
ELASTIC_PASSWORD=ThisPassWordIsSoRandomItHurtsMyEyes

# KIBANA
KIBANA_NAME=kibana

# MOLOCH
MOLOCH_NAME=moloch
MOLOCH_VERSION=1.8.0
MOLOCH_ES_HOST=elasticsearch
MOLOCH_PASSWORD=ThisPasswordIsBadNews
```

./certificates/instances.yml
```
instances:
  - name: es-node1
    dns:
      - node1
      - localhost
      - es-node1.yourdomain.com
      - elasticsearch
    ip:
      - 127.0.0.1
  - name: kibana
    dns:
      - localhost
      - kibana.yourdomain.com
      - kibana
    ip:
      - 127.0.0.1
  - name: moloch
    dns:
      - moloch
      - localhost
      - moloch.yourdomain.com
    ip:
      - 127.0.0.1

```

config.ini
```
# Change this accordingly to password in .env.
elasticsearch=https://elastic:ThisPassWordIsSoRandomItHurtsMyEyes@elasticsearch:9200
```
**This needs to be re-coded with env variable in the future.**

4. Generate Root and Elasticsearch, Kibana, Moloch certificates
```
docker-compose -f create-certs.yml up
```
Backup your ca.crt and ca.key file from ./certificates/ca/ if you want to re-use it later.
Optionally, add the generated ./certificates/ca/ca.crt file to your OS's trust store to prevent browser warnings.

5. Bring up the stack
```
sudo docker-compose up
```
Moloch: Visit https://localhost:8005 with your favourite web browser
username: admin  
password: Defined in Step #3

Kibana: Visit https://localhost:5601 with your favourite web browser
username: elastic
password: Defined in Step #3
More info on how to use Kibana: https://www.elastic.co/guide/en/kibana/6.8/index.html
To create a Kibana index pattern define: "sessions*" to use Moloch data. Choose "firstPacket" as the "Time Filter Field Name".

## Importing PCAPs
1. Place all PCAPs in the folder ./tcpdump
2. Run the following command with the container running
```
docker exec **moloch_container_name** moloch-parse-pcap-folder.sh

```
## Running

### Keep ElasticSearch Persistant
Change this line in docker-compose.yml from 'true' to 'false'
```
INITALIZEDB=
```

### Wipe your ElasticSearch DB but keep all your users and configs
Run the following command with the container running
```
docker exec **moloch_container_name** wipemoloch.sh

```
### Configure ElasticSearch to wipe each startup but keep your users and configs
Change this line in docker-compose.yml from 'true' to 'false'
```
INITALIZEDB=
```
Change this line in docker-compose.yml from 'true' to 'false'
```
WIPEDB=
```

#HAVE FUN!
