#! /usr/bin/env bash
#
# Author: Joshua Gilman <joshuagilman@gmail.com>
#
#/ Usage: test.sh
#/
#/ Contains tests for smoketesting the devcontainer
#/

set -o errexit  # abort on nonzero exitstatus
set -o nounset  # abort on unbound variable
set -o pipefail # don't hide errors within pipes

readonly yellow='\e[0;33m'
readonly green='\e[0;32m'
readonly red='\e[0;31m'
readonly reset='\e[0m'

# Usage: log [ARG]...
#
# Prints all arguments on the standard output stream
log() {
    printf "${yellow}(cont)>> %s${reset}\n" "${*}"
}

# Usage: success [ARG]...
#
# Prints all arguments on the standard output stream
success() {
    printf "${green}(cont)>> %s${reset}\n" "${*}"
}

# Usage: error [ARG]...
#
# Prints all arguments on the standard error stream
error() {
    printf "${red}(cont)!!! %s${reset}\n" "${*}" 1>&2
}

# Usage: die MESSAGE
# Prints the specified error message and exits with an error status
die() {
    error "${*}"
    exit 1
}

success "Entered container"

log "Loading environment..."
source /home/vscode/.nix-profile/etc/profile.d/nix.sh

log "Validating home-manager environment..."
JQ="$(which jq)"
if [ ! "$JQ" = "/home/vscode/.nix-profile/bin/jq" ]; then
    die "Failed validation"
fi

log "Validating nix can build shell"
HELLO="$(nix develop -c 'hello')"
if [[ $? -gt 0 ]]; then
    die "Failed running nix-develop: ${HELLO}"
elif [ ! "$HELLO" = "Hello, world!" ]; then
    die "Hello program failed: ${HELLO}"
fi

success "Done!"
