FROM eclipse-temurin:17 AS builder

COPY ./private-ca.crt /certificates/
ENV USE_SYSTEM_CA_CERTS=1
RUN bash __cacert_entrypoint.sh
RUN cp ${JAVA_HOME}/lib/security/cacerts /tmp/cacerts

FROM sonarqube:lts-community AS sonarqube

USER root
ENV TZ='Asia/Taipei'
ADD ./private-ca.crt /usr/local/share/ca-certificates/private-ca.crt
RUN update-ca-certificates
COPY --from=builder /tmp/cacerts ${JAVA_HOME}/lib/security/cacerts
USER sonarqube

FROM postgres:15 AS db

ENV TZ='Asia/Taipei'
RUN <<EOF
apt-get update -q
DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends ca-certificates
rm -rf /var/lib/apt/lists/*
EOF
ADD ./private-ca.crt /usr/local/share/ca-certificates/private-ca.crt
RUN update-ca-certificates


FROM nginx:1.25 AS proxy

ENV TZ='Asia/Taipei'
ADD ./private-ca.crt /usr/local/share/ca-certificates/private-ca.crt
RUN update-ca-certificates

FROM sonarsource/sonar-scanner-cli AS sonar-scanner

ENV TZ='Asia/Taipei'
COPY --from=builder /tmp/cacerts ${JAVA_HOME}/lib/security/cacerts
