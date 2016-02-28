# Using / Installation

```sh
#!/usr/bin/env bash

bake_require "github.com/kyleburton/bake-recipes/docker/docker.sh"

bake_task my-task "your tasks go here"
function my-task () {
  ... 
}
```

# Configuration

```sh
export DOCKER_IMAGE_TAG="mysql:latest"
export DOCKER_IMAGE_NAME="mysqld-test"
```


TODO: new task: cleanup old images w/the tag
TODO: new task: cleanup old containers w/the tag
TODO: new task: stop the running container
