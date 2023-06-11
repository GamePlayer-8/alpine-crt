FROM alpine

USER root

RUN mkdir /certs

WORKDIR /certs

COPY ./certs .

RUN cat * >> /etc/ssl/certs/ca-certificates.crt && \
	cp /etc/ssl/certs/ca-certificates.crt / && \
	mkdir -p /etc/ssl1.1 2>/dev/null || true && \
	rm -f /etc/ssl/cert.pem && \
	rm -f /etc/ssl1.1/cert.pem && \
	ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem && \
	ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl1.1/cert.pem

WORKDIR /

ENV XAVIAMA_CERTIFICATES=true
