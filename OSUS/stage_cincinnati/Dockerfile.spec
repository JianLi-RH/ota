FROM alpine:latest

WORKDIR /

COPY . .

RUN chmod +x ./check_cincinnati_spec.sh

USER root
CMD source ./check_cincinnati_spec.sh
