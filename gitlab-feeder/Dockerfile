FROM alpine:latest

RUN apk add --no-cache bash

ADD scripts/ /

RUN \
  bash /remove.sh &&\
  bash /create.sh
