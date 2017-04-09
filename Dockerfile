FROM openjdk:8-jre-alpine

ENV NEXUS_VERSION=3.2.1-01

ENV NEXUS_BASE /usr/local
ENV NEXUS_HOME ${NEXUS_BASE}/nexus
ENV NEXUS_DATA /var/lib/nexus
ENV NEXUS_CONTEXT ''

# install nexus
#RUN apt-get update && apt-get install openssl && rm -fr /var/cache/apk/*
#RUN wget https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz -O - \
#  | tar zx -C "${NEXUS_BASE}" \
#  && mv "${SONATYPE_DIR}/nexus-${NEXUS_VERSION}" "${NEXUS_HOME}"

WORKDIR ${NEXUS_BASE}

COPY nexus-${NEXUS_VERSION}-unix.tar.gz ${NEXUS_BASE}/

RUN tar -zxf nexus-${NEXUS_VERSION}-unix.tar.gz -C ${NEXUS_BASE}/ \
    && rm -rf nexus-${NEXUS_VERSION}-unix.tar.gz \
    && rm -rf ${NEXUS_BASE}/sonatype-work \
    && mv /usr/local/nexus-${NEXUS_VERSION} ${NEXUS_HOME}

# configure nexus
RUN sed \
    -e '/^nexus-context/ s:$:${NEXUS_CONTEXT}:' \
    -i ${NEXUS_HOME}/etc/nexus-default.properties

## create nexus user
RUN adduser -S -u 200 -D -H -h "${NEXUS_DATA}" -s /bin/false nexus nexus

RUN mkdir -p "${NEXUS_DATA}"

## prevent warning: /${NEXUS_HOME}/etc/org.apache.karaf.command.acl.config.cfg (Permission denied)
RUN chown -R nexus "${NEXUS_HOME}/etc/"

COPY nexus.vmoptions ${NEXUS_HOME}/bin/nexus.vmoptions

COPY docker-entrypoint.sh /usr/local/bin/

RUN ln -s usr/local/bin/docker-entrypoint.sh /entrypoint.sh

VOLUME ${NEXUS_DATA}

EXPOSE 8081

WORKDIR ${NEXUS_HOME}

ENV JAVA_MAX_MEM 1200m
ENV JAVA_MIN_MEM 1200m
ENV EXTRA_JAVA_OPTS ""

ENTRYPOINT ["docker-entrypoint.sh"]
