FROM eclipse-temurin:11.0.14.1_1-jdk-centos7
LABEL maintainer="orlando.curieles@ingeint.com"

ENV IDEMPIERE_HOME=/opt/idempiere
ENV IDEMPIERE_VERSION=9 IDEMPIERE_PLUGINS_HOME=$IDEMPIERE_HOME/plugins IDEMPIERE_LOGS_HOME=$IDEMPIERE_HOME/log

WORKDIR $IDEMPIERE_HOME

RUN yum -y update && \
    yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm && \
    yum install -y postgresql14 && \
    yum install -y epel-release && \
    yum install -y dejavu-sans-fonts dejavu-serif-fonts dejavu-fonts-common dejavu-sans-mono-fonts && \
    yum install -y liberation-serif-fonts liberation-sans-fonts liberation-fonts liberation-fonts-common \
    liberation-narrow-fonts liberation-mono-fonts dejavu-lgc-serif-fonts dejavu-serif-fonts dejavu-fonts-common \
    dejavu-lgc-sans-mono-fonts dejavu-sans-fonts dejavu-sans-mono-fonts gnu-free-fonts-common gnu-free-serif-fonts \
    gnu-free-sans-fonts gnu-free-serif-fonts && \
    yum install -y fontconfig && \
    yum -y clean all && \
    yum -y autoremove

ARG BINARY_FILE
COPY $BINARY_FILE /tmp

#RUN wget --no-check-certificate $IDEMPIERE_BUILD -O /tmp/idempiere-server.zip && \
RUN binaryFile=/tmp/$BINARY_FILE && \
    echo "Hash: $(md5sum $binaryFile)" > $IDEMPIERE_HOME/MD5SUMS && \
    echo "Date: $(date)" >> $IDEMPIERE_HOME/MD5SUMS && \
    tar xf $binaryFile -C /tmp/ && \
    mv /tmp/x86_64/* $IDEMPIERE_HOME && \
    rm -rf /tmp/idempiere* && \
    rm -rdf /tmp/x86_64 && \
    cat $IDEMPIERE_HOME/MD5SUMS && \
    ln -s $IDEMPIERE_HOME/idempiere-server.sh /usr/bin/idempiere

#RUN sed -i -r 's|^#!/bin/sh|#!/bin/sh\nset -x|g' $IDEMPIERE_HOME/utils/postgresql/ImportIdempiere.sh

COPY docker-entrypoint.sh $IDEMPIERE_HOME

ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["idempiere"]
