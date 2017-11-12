# Official Ubuntu 16.04
# FROM ubuntu:latest
FROM ubuntu:16.04

MAINTAINER Credy Engineering <engineering@credy.in>

# Make ports available to the world outside this container
EXPOSE 80
EXPOSE 443
EXPOSE 22

# Install latex
RUN apt-get update && apt-get install -y -q texlive-latex-recommended

# Install generic libs
RUN apt-get -y -q install curl wget xz-utils build-essential libsqlite3-dev libreadline-dev libssl-dev openssl git

# Install Python 3.5.4
WORKDIR /tmp
RUN wget https://www.python.org/ftp/python/3.5.4/Python-3.5.4.tar.xz
RUN tar -xf Python-3.5.4.tar.xz
WORKDIR /tmp/Python-3.5.4
RUN ./configure
RUN make
RUN make install
WORKDIR /
RUN rm -rf /tmp/Python-3.5.4.tar.xz /tmp/Python-3.5.4

# Install  and setup postgres
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt-get update && apt-get -y -q install python-software-properties software-properties-common && apt-get -y -q install postgresql-9.5 postgresql-client-9.5 postgresql-contrib-9.5 postgresql-server-dev-9.5 libpq-dev
USER postgres
RUN /etc/init.d/postgresql start && psql --command "CREATE USER ubuntu WITH PASSWORD '';"  && psql --command "CREATE DATABASE ubuntu;" && psql --command "grant all privileges on database ubuntu to ubuntu;"
USER root
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.5/main/pg_hba.conf
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.5/main/postgresql.conf
EXPOSE 5432
RUN mkdir -p /var/run/postgresql && chown -R postgres /var/run/postgresql
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]
USER postgres
CMD ["/usr/lib/postgresql/9.5/bin/postgres", "-D", "/var/lib/postgresql/9.5/main", "-c", "config_file=/etc/postgresql/9.5/main/postgresql.conf"]

