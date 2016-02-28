#!/usr/bin/env bash


# this is a library of helper functions

#bake_task docker-container-is-running
function docker-container-is-running () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  local image_name="$(echo "$tag" | tr : -)"
  local containerid="$(docker-running-container-id "$image_name")"
  test -n "$containerid"
}

bake_task docker-shell "Execute a shell on the running container"
function docker-shell () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  local image_name="$(echo "$tag" | tr : -)"
  local container_id="$(docker-running-container-id "$image_name")"
  if [ -z "$container_id" ]; then
    bake_echo_red "Error: the container $image_name does not seem to be running."
    return 1
  fi
  # docker exec -it "$container_id" bash
  docker exec -it "$container_id" /bin/bash -c "export TERM=xterm-256color; exec bash"
}

bake_task docker-logs "Show the logs for the running container"
function docker-logs () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"

  if [ -n "${1:-}" ]; then
    shift
  fi

  local container_id="$(docker-running-container-id "$tag")"

  if [ -z "$container_id" ]; then
    container_id="$(docker-stopped-container-id "$tag")"
  fi

  if [ -z "$container_id" ]; then
    bake_echo_red "Error: no container with tag=$tag"
    return 1
  fi

  docker logs "$@" "$container_id"
}

function docker-build () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  local dpath="${2:-.}"
  docker build --tag="$DOCKER_IMAGE_TAG" "$dpath"
}

function docker-running-container-id () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  local name="$(echo $tag | tr : -)"
  docker ps -q -f "name=$name"
}

function docker-stopped-container-id () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  local name="$(echo $tag | tr : -)"
  docker ps -q -a -f "name=$name" -f "status=exited"
}

bake_task docker-shell "Open a shell on your container."
function docker-shell () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  if docker-container-is-running "$tag"; then
    echo "runing a bash in the running container"
    docker exec -i -t "$(docker-running-container-id "$tag")" /bin/bash -c "export TERM=xterm-256color; exec bash"
  else
    echo "runing a bash in a fresh container"
    docker run -i -t "$tag" /bin/bash -c "export TERM=xterm-256color; exec bash"
  fi
}

bake_task docker-status "See if the container is running"
function docker-status () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"
  if docker-container-is-running "$tag"; then
    echo "container is running: $tag"
    docker ps -f "image=$tag"
  else
    echo "container is NOT running: $tag"
    return 1
  fi
}

bake_task docker-start "Start your container"
function docker-start () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"

  if [ "$#" -eq 0 -o "$#" -eq 1 ]; then
    if docker-container-is-running "$tag"; then
      bake_echo_green "Container $tag is already running"
      return 0
    fi

    local prev_container_id="$(docker-stopped-container-id "$tag")"
    if [ -n "$prev_container_id" ]; then
      bake_echo_green "Removing old (exited) container: $prev_container_id"
      docker rm "$prev_container_id"
    fi
    local name="$(echo $tag | tr : -)"
    # remove the non-runing container (if there is one)
    exec docker run ${DOCKER_RUN_OPTS:-} --name="$name" -d "$tag"
  fi

  docker run "$@"
}

bake_task docker-stop "Stop your container"
function docker-stop () {
  local tag="${1:-$DOCKER_IMAGE_TAG}"

  if docker-container-is-running "$tag"; then
    local container_id="$(docker-running-container-id "$tag")"
    docker stop "$container_id"
    bake_echo_green "Stopped container: $tag id=$container_id"
    return 0
  fi

  bake_echo_red "Container $tag is not running"
  return 1
}

bake_task docker-restart "Restar the container"
function docker-restart () {
  docker-stop || bake_echo_green "OK: container is not running"
  docker-start
}

# TODO: cleanup stopped containers
