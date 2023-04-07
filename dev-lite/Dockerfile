FROM development-environment-base:1.12
LABEL maintainer = "SR-CORE <core@spareroom.co.uk>"

RUN ln -s /secure/ /opt/secure && ln -s /secure/s/spareroom3/Library.tx/dev.yaml /etc/sr/xslate_dev.yaml

ENV DEBIAN_FRONTEND=noninteractive

ENV DEVELOPMENT=1
# Set to UK from docker compose for test & running scripts. Prefix SERVER_POOL=.. on scripts where needed
ENV SERVER_POOL=UK
ENV SR_ROOT=/opt/
ENV DEV_NAMESPACE_GEARMAN=1
ENV HOSTNAME_SHORT=devapp
ENV PERL5LIB=/secure/lib:/secure/l/london3/flatshare:/secure/t/lib:/secure/t/no_parallel/lib:/secure/t/helpers

ADD dot-my.cnf /root/.my.cnf

RUN cpm install --no-test -g Bundle::Camelcade
