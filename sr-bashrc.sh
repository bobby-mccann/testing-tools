# Add the following to your ~/.bashrc file:
# source $HOME/Work/testing-tools/sr-bashrc.sh

export DEVELOPMENT=1
export GIT_REPOS=~/Work
export SR_ROOT=$GIT_REPOS

# shellcheck disable=SC2139
alias srd="$GIT_REPOS/docker-development-environment/sr-docker.pl"
# shellcheck disable=SC2139
alias failed_tests="$GIT_REPOS/testing-tools/failed_tests.pl"
# shellcheck disable=SC2139
alias wft="failed_tests -w"
# shellcheck disable=SC2139
alias srvpn="$GIT_REPOS/testing-tools/vpn-connect.sh"