# Wildfly 10.1 AS image using a posgres 9.4 image on 172.17.0.2 (see other docker project)
Administration username/password is admin/password

Prerequisite: https://jdbc.postgresql.org/download/postgresql-9.4.1212.jar

## Build
docker build --tag wildfly-10.1-postgres .

## Run
docker run --rm --name wildfly-10.1-postgres -p 9990:9990 -p 8080:8080 wildfly-10.1-postgres
