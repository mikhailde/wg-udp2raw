FROM alpine:latest as builder

WORKDIR /app

RUN apk add --no-cache --virtual .build-deps git build-base linux-headers

RUN git clone https://github.com/wangyu-/udp2raw.git && \
    cd udp2raw && \
    make

FROM alpine:latest

RUN apk add --no-cache libstdc++ iptables

COPY --from=builder /app/udp2raw/udp2raw /usr/bin/

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
