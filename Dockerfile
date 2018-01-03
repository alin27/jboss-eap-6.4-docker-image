#######################################################################
# Creates a base Ubuntu image with JBoss EAP-6.4.x                #
#######################################################################

# Use the Ubuntu base image
FROM ubuntu

# Update the system
RUN apt-get -y update;apt-get clean all

##########################################################
# Install Java JDK
##########################################################
RUN apt-get -y install wget && \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151-linux-x64.tar.gz && \
    mkdir /usr/java && \
    tar -zxvf jdk-8u151-linux-x64.tar.gz -C /usr/java && \
    apt-get -y remove wget && \
    rm -f jdk-8u151-linux-x64.tar.gz

ENV JAVA_HOME /usr/java/jdk1.8.0_151

##########################################################
# Create jboss user
##########################################################

# add our user and group first to make sure their IDs get assigned consistently, regardless of whatever dependencies get added
RUN groupadd -r jboss && useradd -r -g jboss -m -d /home/jboss jboss && usermod --password jboss jboss

############################################
# Install EAP 6.4.0.GA
############################################
RUN apt-get -y install zip unzip

USER jboss
ENV INSTALLDIR /home/jboss/EAP-6.4.0
ENV JBOSS_HOME /home/jboss/EAP-6.4.0/jboss-eap-6.4

RUN mkdir $INSTALLDIR && \
   mkdir $INSTALLDIR/distribution && \
   mkdir $INSTALLDIR/resources

USER root
ADD distribution $INSTALLDIR/distribution
RUN chown -R jboss:jboss /home/jboss
RUN find /home/jboss -type d -execdir chmod 770 {} \;
RUN find /home/jboss -type f -execdir chmod 660 {} \;

USER jboss
RUN unzip $INSTALLDIR/distribution/jboss-eap-6.4.0.zip  -d $INSTALLDIR

# Add patch - EAP 6.4.9
RUN $JBOSS_HOME/bin/jboss-cli.sh "patch apply $INSTALLDIR/distribution/jboss-eap-6.4.9-patch.zip"

# Add patch - EAP 6.4.9
RUN $JBOSS_HOME/bin/jboss-cli.sh "patch apply $INSTALLDIR/distribution/jboss-eap-6.4.17-patch.zip"

############################################
# Create start script to run EAP instance
############################################
USER root

RUN apt-get -y install curl
RUN curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
&& chmod +x /usr/local/bin/gosu

############################################
# Remove install artifacts
############################################
RUN rm -rf $INSTALLDIR/distribution
RUN rm -rf $INSTALLDIR/resources

############################################
# Expose paths and start JBoss
############################################
EXPOSE 22 8080 8443 9990

USER root

RUN mkdir /etc/jboss-as
RUN mkdir /var/log/jboss/
RUN chown jboss:jboss /var/log/jboss/

COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh

############################################
# Start JBoss in stand-alone mode
############################################
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["start-jboss"]
