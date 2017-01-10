FROM debian:jessie

RUN export DEBIAN_FRONTEND=noninteractive

RUN echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/webupd8team-java.list
RUN echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/webupd8team-java.list
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886
RUN apt-get update
RUN echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections
RUN apt-get install -y oracle-java8-installer
RUN apt-get install -y oracle-java8-set-default
RUN apt-get install -y curl

RUN groupadd -r wildfly -g 1000 && useradd -u 1000 -r -g wildfly -m -d /opt/wildfly -s /sbin/nologin -c "JBoss user" wildfly && chmod 755 /opt/wildfly

WORKDIR /opt/wildfly

USER wildfly

ENV WILDFLY_VERSION 10.1.0.Final
ENV WILDFLY_SHA1 9ee3c0255e2e6007d502223916cefad2a1a5e333
ENV JBOSS_HOME /opt/wildfly/as

RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
    && tar xf wildfly-$WILDFLY_VERSION.tar.gz \
    && rm wildfly-$WILDFLY_VERSION.tar.gz

RUN cd /opt/wildfly && ln -s wildfly-$WILDFLY_VERSION as

USER root

# Create directories and symbolic links for working directories
RUN mkdir -p /var/log/wildfly \
 && ln -s /var/log/wildfly /opt/wildfly/as/standalone/log \
 && mkdir -p /var/data/wildfly/data \
 && ln -s /var/data/wildfly/data /opt/wildfly/as/standalone/data \
 && mkdir /var/data/wildfly/tmp \
 && rm -r /opt/wildfly/as/standalone/tmp \
 && ln -s /var/data/wildfly/tmp /opt/wildfly/as/standalone/tmp \
 && mkdir /var/data/wildfly/tmp/auth \
 && mkdir /opt/wildfly/as/standalone/releases \
 && chown -R wildfly:wildfly /var/log/wildfly \
 && chown -R wildfly:wildfly /var/data/wildfly

RUN mkdir /etc/wildfly && mkdir /var/run/wildfly

WORKDIR /opt/wildfly/as

USER wildfly

RUN mkdir hibernate-jars && cp modules/system/layers/base/org/hibernate/main/*.jar hibernate-jars/

USER root
ADD wildfly_execute.sh /execute.sh
RUN chown wildfly:wildfly /execute.sh && chmod +x /execute.sh

USER wildfly

RUN cat bin/standalone.conf |sed -e "s/ -XX:MaxPermSize=256m//" > bin/standalone.conf.new && mv bin/standalone.conf.new bin/standalone.conf

ADD postgresql-9.4.1212.jar /tmp/postgresql-9.4.1212.jar

RUN cp standalone/configuration/standalone-full.xml /tmp/
ADD replaceH2withPostgresql.cli /tmp/replaceH2withPostgresql.cli
RUN /execute.sh standalone standalone-full.xml /tmp/replaceH2withPostgresql.cli
RUN cat standalone/configuration/standalone-full.xml\
    |sed -e "s/pool-name=\"DefaultDS\" enabled=\"true\"/pool-name=\"DefaultDS\" use-java-context=\"true\"/"\
    |sed -e "s#java:jboss/datasources/ExampleDS#java:/DefaultDS#"\
     > standalone-full.xml && mv standalone-full.xml standalone/configuration/

#Fix for: WFLYCTL0056: Could not rename /opt/wildfly/as/standalone/configuration/standalone_xml_history/current to ...
RUN rm -rf ${JBOSS_HOME}/standalone/configuration/standalone_xml_history

RUN ${JBOSS_HOME}/bin/add-user.sh admin password --silent
RUN ${JBOSS_HOME}/bin/add-user.sh -a admin password --silent

EXPOSE 8080
EXPOSE 9990

# More needed:
VOLUME ["/var"]

CMD ["/opt/wildfly/as/bin/standalone.sh", "--server-config", "standalone-full.xml", "-b", "0.0.0.0", "-bmanagement", "0.0.0.0"]

