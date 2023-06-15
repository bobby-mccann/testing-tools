# shellcheck disable=SC2139

# Add the following to your ~/.bashrc file:
# source $HOME/Work/testing-tools/sr-bashrc.sh

export DEVELOPMENT=1
export SR_ROOT=$GIT_REPOS
export SENTRY_LOG=0

alias srd="$GIT_REPOS/docker-development-environment/sr-docker.pl"
alias failed_tests="$GIT_REPOS/testing-tools/failed_tests.pl"
alias wft="failed_tests -w"
alias srvpn="$GIT_REPOS/testing-tools/vpn-connect.pl"
alias sync_localisations="$GIT_REPOS/secure/bin/dev/localisation/sync_localisations"
alias migration="$GIT_REPOS/secure/bin/dev/create_migration"
alias txp="srd bash txp"