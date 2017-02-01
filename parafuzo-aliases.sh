# PFZ functions

# Run docker shell with sh
function dsh() {
  APP_DIR=${PWD##*/};
  docker-compose run --rm $APP_DIR /bin/sh;
}

# Run docker shell with bash
function dbash() {
  APP_DIR=${PWD##*/};
  docker-compose run --rm $APP_DIR /bin/bash;
}

# Run shell command
function ds() {
  APP_DIR=${PWD##*/};
  docker-compose run --rm $APP_DIR $*;
}

# Show logs from current app
function dl() {
  APP_DIR=${PWD##*/};
  docker-compose logs --follow $APP_DIR
}

# Start a docker container
function dstart() {
  docker-compose up -d $1;
}

# Stop a docker container
function dstop() {
  docker-compose stop $1;
}

# Restart a docker container
function drestart() {
  docker-compose restart $1;
}

# List docker containers
function dps() {
  docker-compose ps $*;
}

# Run ruby test
function dt() {
  ds "bin/rake test $*"
}

# Run rspec
function dr() {
  ds "bundle exec rspec $*";
}

# Run mix test
function dm() {
  ds "MIX_ENV=test mix test $*"
}

# Run go test
function dgt() {
  ds "GO_ENV=test go test $*"
}

# Kubernetes console
function konsole() {
  if [ "$1" = "" ] || [ "$2" = "" ]; then
    echo "Usage: konsole <namespace> <cmd>"
    return;
  fi

  COLUMNS=`tput cols`
  LINES=`tput lines`
  APP_DIR=${PWD##*/};
  CONTAINER=$(kubectl get pods --namespace $1 | grep -E -o "^"$APP_DIR"[a-z0-9-]+" | head -n 1)
  DEFAULT_CMD="scripts/console"
  kubectl exec $CONTAINER --namespace $1 -it env COLUMNS=$COLUMNS LINES=$LINES /entrypoint.sh $2
}

# Kubernetes log
function klog() {
  if [ "$1" = "" ]; then
    echo "Usage: klog <namespace>"
    return;
  fi

  APP_DIR=${PWD##*/};
  CONTAINER=$(kubectl get pods --namespace $1 | grep -E -o "^"$APP_DIR"[a-z0-9-]+" | head -n 1)
  kubectl logs $CONTAINER --namespace $*
}

# Kubernetes list pods
function klist() {
  if [ "$1" = "" ]; then
    echo "Usage: klist <namespace>"
    return;
  fi
  kubectl get pods --namespace $1
}
