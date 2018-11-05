#!/bin/sh -ex

SOURCE_DOCKER_IMAGE_NAME='tomcat'
SOURCE_DOCKER_IMAGE_VERSION='latest'
DOCKER_NAME='warehouse_rest_api'

Cleanup () {
    if [ $(docker ps | grep -c "${DOCKER_NAME}") -gt 0 ]; then
        docker stop "${DOCKER_NAME}"
    fi
    if [ $(docker ps -a | grep -c "${DOCKER_NAME}") -gt 0 ]; then
        docker rm "${DOCKER_NAME}"
    fi
    if [ $(docker images | grep -c -E "${DOCKER_NAME}[[:space:]]+latest") -gt 0 ]; then
        docker rmi ${DOCKER_NAME}:latest
    fi
}

CreateDockerfile () {
    echo "FROM ${SOURCE_DOCKER_IMAGE_NAME}:${SOURCE_DOCKER_IMAGE_VERSION}"                              >  Dockerfile
    echo 'COPY /target/warehouse_management_rest_api-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/'       >> Dockerfile
    echo 'EXPOSE 8080 8080'                                                                             >> Dockerfile
}

DockerImageBuild () {
    echo "Building docker image..."
    docker build -t ${DOCKER_NAME}:latest -f Dockerfile .
}

StartDockerContainer () {
    containerVolumePath="$(cd ..; pwd)"
    docker run --rm -it -p 8080:8080 --name ${DOCKER_NAME} ${DOCKER_NAME}
}

mvn clean install
Cleanup
CreateDockerfile
DockerImageBuild
StartDockerContainer