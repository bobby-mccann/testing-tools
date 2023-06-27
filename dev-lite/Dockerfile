FROM development-environment-base:1.12
LABEL maintainer = "SR-CORE <core@spareroom.co.uk>"

RUN cpm install --no-test -g Bundle::Camelcade

ENV DEBIAN_FRONTEND=noninteractive

ENV DEVELOPMENT=1
ENV SERVER_POOL=UK
ENV DEV_NAMESPACE_GEARMAN=1
ENV HOSTNAME_SHORT=devapp
ENV SENTRY_LOG=0
ENV NO_TEST_LIB=1

ADD dot-my.cnf /root/.my.cnf

# Create the symlink to /secure - we can't do this in the image because
# intellij doesn't show us any files when we look for the perl executable.
# I don't know why this happens.
# The exec "$@" is so that we can run the container with a command.
ENTRYPOINT ln -s $SR_ROOT/secure /secure && exec "$@"
CMD ["default", "arguments"]