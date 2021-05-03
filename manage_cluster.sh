#!/bin/bash

LEADERBOARD_API="../LeaderboardService"
AUTHENTICATION_API="../authentication-service"

# Check if git exists and repos exist
if ! command -v git &> /dev/null
then
    echo "git could not be found"
    exit
else
    if [[ ! -d $LEADERBOARD_API ]]
    then
        echo "Cloning LeaderboardService.."
        git clone https://github.com/terepaii/LeaderboardService.git ..
    else
        echo "LeaderboardService found.."
    fi
    if [[ ! -d $AUTHENTICATION_API ]]
    then
        echo "Cloning authentication-service.."
        git clone https://github.com/terepaii/authentication-service.git ..
    else
        echo "authentication-service found.."
    fi
fi

DOCKER_INFRASTRUCTURE="mongo grafana reverse_proxy prometheus mongo-express"
DOCKER_LEADERBOARD_API="leaderboardapi"
DOCKER_AUTHENTICATION_API="authenticationapi"

while getopts :st opt; do
    case $opt in
        s)
            for service in $DOCKER_INFRASTRUCTURE 
            do
                docker_name=$(docker ps --filter "status=running" --format {{.Names}} | grep ${service}_1)
                
                if [[ $docker_name = "infrastructure_${service}_1" ]]
                then
                    echo "${service} is up"
                else
                    docker-compose up -d ${service}
                fi
            done

            leaderboard_api_docker_name=$(docker ps --filter "status=running" --format {{.Names}} | grep ${DOCKER_LEADERBOARD_API}_1)
            if [[ $leaderboard_api_docker_name = "service_${DOCKER_LEADERBOARD_API}_1" ]]
            then
                echo "${DOCKER_LEADERBOARD_API} is up"
            else
                docker-compose -f "${LEADERBOARD_API}/Service/docker-compose.yml" up -d --remove-orphans
            fi

            authentication_api_docker_name=$(docker ps --filter "status=running" --format {{.Names}} | grep ${DOCKER_AUTHENTICATION_API}_1)
            if [[ $authentication_api_docker_name = "authentication-service_${DOCKER_AUTHENTICATION_API}_1" ]]
            then
                echo "${DOCKER_AUTHENTICATION_API} is up"
            else
                docker-compose -f "$AUTHENTICATION_API/docker-compose.yml" up -d --remove-orphans
            fi
            ;;
        t)
            for service in $DOCKER_INFRASTRUCTURE 
            do
                docker_name=$(docker ps --filter "status=exited" --format {{.Names}} | grep ${service}_1) # Add the _1 for uniqueness, otherwise multiple containers can be returned
                if [[ $docker_name = "infrastructure_${service}_1" ]]
                then
                    echo "${service} is down"
                else
                    docker-compose stop ${service}
                fi
            done
            
            leaderboard_api_docker_name=$(docker ps --filter "status=exited" --format {{.Names}} | grep ${DOCKER_LEADERBOARD_API}_1)
            if [[ $leaderboard_api_docker_name = "service_${DOCKER_LEADERBOARD_API}_1" ]]
            then
                echo "${DOCKER_LEADERBOARD_API} is down"
            else
                docker-compose -f "${LEADERBOARD_API}/Service/docker-compose.yml" stop
            fi

            authentication_api_docker_name=$(docker ps --filter "status=exited" --format {{.Names}} | grep ${DOCKER_AUTHENTICATION_API}_1)
            if [[ $authentication_api_docker_name = "authentication-service_${DOCKER_AUTHENTICATION_API}_1" ]]
            then
                echo "${DOCKER_AUTHENTICATION_API} is down"
            else
                docker-compose -f "$AUTHENTICATION_API/docker-compose.yml" stop
            fi
            ;;
        \?)
            echo "Invalid Option: -$OPTARG" >&2
            ;;
    esac
done
