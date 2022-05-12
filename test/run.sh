#! /usr/bin/env bash
#
# Author: Joshua Gilman <joshuagilman@gmail.com>
#
#/ Usage: run.sh
#/
#/ Runs tests against the devcontainer
#/

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

readonly yellow='\e[0;33m'
readonly reset='\e[0m'

# Usage: log [ARG]...
#
# Prints all arguments on the standard output stream
log() {
    printf "${yellow}>> %s${reset}\n" "${*}"
}

log "Starting test..."

# Build the container locally
log "Building container..."
docker build -t test .

# Run container and mount local directory
log "Running container..."
docker run -v "$(PWD)/test:/workspace" --entrypoint /bin/bash test -c 'cd /workspace && ./test.sh'
