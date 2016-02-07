#!/usr/bin/env bash

bake_task docker-container-id
function docker-container-id () {
  local image_name="${1:-$DOCKER_IMAGE_NAME}"
  docker ps -q -f "name=$image_name"
}

bake_task docker-container-is-running
function docker-container-is-running () {
  local image_name="${1:-$DOCKER_IMAGE_NAME}"
  local containerid="$(docker-container-id "$image_name")"
  test -n "$containerid"
}

bake_task docker-ensure-container "Ensure a container is running (by name and image tag)"
function docker-ensure-container () {
  local image_name="${1:-$DOCKER_IMAGE_NAME}"
  local image_tag="${1:-$DOCKER_IMAGE_TAG}"
  #docker build dockefiles/mysql-test
  if ! docker-container-is-running "$image_name"; then
    bake_echo_green "Starting container: $image_name $image_tag"
    docker run --name "$image_name" -e "MYSQL_ROOT_PASSWORD=password" -d "$image_tag"
  else
    bake_echo_green "Already running: $image_name $image_tag => $(docker-container-id "$image_name")"
  fi
}

bake_task docker-shell "Execute a shell on the running container"
function docker-shell () {
  local image_name="${1:-$DOCKER_IMAGE_NAME}"
  local container_id="$(docker-container-id "$image_name")"
  if [ -z "$container_id" ]; then
    bake_echo_red "Error: the container $image_name does not seem to be running."
    return 1
  fi
  # docker exec -it "$container_id" bash
  docker exec -it "$container_id" /bin/bash -c "export TERM=xterm-256color; exec bash"
}

bake_task docker-logs "Show the logs for the running container"
function docker-logs () {
  local image_name="${1:-$DOCKER_IMAGE_NAME}"
  local container_id="$(docker-container-id "$image_name")"
  docker logs "$container_id"
}

# TODO: cleanup stopped containers

