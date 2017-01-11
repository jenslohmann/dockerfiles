docker build --tag wildfly-10.1-postgres .
docker run --rm --name wildfly-10.1-postgres -p 9990:9990 -p 8080:8080 wildfly-10.1-postgres

