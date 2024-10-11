#!/bin/sh

/usr/bin/udp2raw -s \
  -l 0.0.0.0:"$UDP2RAW_LISTEN_PORT" \
  -r 127.0.0.1:"$WIREGUARD_PORT" \
  -k "$UDP2RAW_KEY" \
  --raw-mode faketcp \
  -a \
  --cipher-mode xor &

wait $!
