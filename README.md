# Infrastructure
Infrastructure repository to coordinate common service components like metrics, logging and gateways

As of March 2021, this repo works with:
* [authentication-service](https://github.com/terepaii/authentication-service) 
* [LeaderboardService](https://github.com/terepaii/LeaderboardService)


# Requirements
- [Docker](https://docs.docker.com/get-docker/)
- [Docker-Compose](https://docs.docker.com/compose/install/)


# Setup
## Docker Network
**If using the ELK stack**, the application and logstash need to be on the same docker bridge network. The docker compose files assume `logging` as the network.

Run: `docker network create logging`


## ELK Stack
This project uses the docker ELK stack provided by deviantony: [deviantony/docker-elk](https://github.com/deviantony/docker-elk)

### ELK Stack Start
To start the ELK stack, use the `docker-compose up` in the `docker-elk` submodule. This starts up the following containers and ports:

**Logstash**
 - 5000/tcp/udp - Logstash TCP/UDP input 
 - 5044/http - Logstash beats input
 - 8085/http - Logstash http input for Serilog
 - 9600/http - Logstash monitoring API

**Elasticsearch**
 - 9200/http - Elasticsearch http API
 - 9300/tcp - Elasticsearch tcp input

**Kibana**
 - 5601/http - Kibana Frontend


# Usage

## To Start Up a Cluster

The command spins up a cluster

```
./manage_cluster.sh -s
```

## To Teardown a Cluster

The command spins up a cluster

```
./manage_cluster.sh -t
```




