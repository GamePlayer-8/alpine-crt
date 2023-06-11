FROM alpine

USER root

COPY ./certs /

RUN cat /certs/* >> /etc/ssl/certs/ca-certificates.crt && \
	cp /etc/ssl/certs/ca-certificates.crt / && \
	mkdir /etc/ssl1.1 2>/dev/null && \
	rm -f /etc/ssl/cert.pem && \
	rm -f /etc/ssl1.1/cert.pem && \
	ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl/cert.pem && \
	ln -s /etc/ssl/certs/ca-certificates.crt /etc/ssl1.1/cert.pem

ENV XAVIAMA_CERTIFICATES=true
