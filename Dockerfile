FROM alpine:3.10

COPY entrypoint.sh pkgccaas.sh /

ENTRYPOINT ["/entrypoint.sh"]
