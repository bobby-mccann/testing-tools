# shellcheck disable=SC2139

# Add the following to your ~/.bashrc file:
# source $HOME/Work/testing-tools/sr-bashrc.sh

export DEVELOPMENT=1
export SENTRY_LOG=0

alias srd="$SR_ROOT/docker-development-environment/sr-docker.pl"
alias failed_tests="$SR_ROOT/testing-tools/failed_tests.pl"
alias wft="failed_tests -w"
alias srvpn="$SR_ROOT/testing-tools/vpn-connect.pl"