FROM openjdk:8-alpine

COPY keycloak/providers/ providers/

RUN apk update && \
    apk upgrade && \
    apk add maven

RUN cd providers/authenticator/hmda && \
	mvn --quiet clean install && \
	cd target && \
	ls


