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