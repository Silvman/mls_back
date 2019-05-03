FROM ubuntu:18.04

USER root

ENV PGVER 11
RUN apt update -y &&\
    apt install -y wget gnupg &&\
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bionic-pgdg main 11" > /etc/apt/sources.list.d/pgdg.list &&\
    apt update -y  &&\
    apt install -y postgresql-$PGVER

RUN wget https://dl.google.com/go/go1.12.4.linux-amd64.tar.gz &&\
    tar -xvf go1.12.4.linux-amd64.tar.gz &&\
    mv go /usr/local

ENV GOROOT /usr/local/go
ENV GOPATH /opt/go
ENV PATH $GOROOT/bin:$GOPATH/bin:/usr/local/go/bin:$PATH

WORKDIR $GOPATH/src/mls_back/
ADD . $GOPATH/src/mls_back/

RUN go build -ldflags "-s -w" ./cmd/server-public-api/main.go

EXPOSE 3000

# postgres settings
RUN mv pg_hba.conf /etc/postgresql/$PGVER/main/ 

USER postgres
RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker &&\
    psql -q docker -f base.sql &&\
    /etc/init.d/postgresql stop

CMD service postgresql start && ./main