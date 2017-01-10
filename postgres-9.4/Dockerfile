FROM debian:jessie

RUN export DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y postgresql-9.4
# ADD postgres.conf /etc/supervisor/postgres.conf

RUN apt-get install -y netcat

ADD host_setup.sh /tmp/setup.sh
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh && rm /tmp/setup.sh

ADD start-postgres.sh /start-postgres.sh
RUN chmod +x /start-postgres.sh
ENTRYPOINT /start-postgres.sh

ENV PG_MAJOR 9.4
ENV PGDATA /var/lib/postgresql/$PG_MAJOR/main
ENV PATH /usr/lib/postgresql/$PG_MAJOR/bin:$PATH

EXPOSE 5432

