## Wireguard VPN with udp2raw obfuscation

This project provides a simple setup for a Wireguard VPN with udp2raw obfuscation to bypass network restrictions.

## Features

* Easy setup with Docker Compose.
* Web interface for Wireguard management (wg-easy).
* udp2raw for traffic obfuscation.
* Automatic service startup and restart.
* **Ability to create a full-fledged VPN network**, unlike simple proxy gateways like shadowsocks or v2ray.

## Server setup

1. **Open ports on your server:**
   * `51821/tcp` (for web UI, unless changed in `docker-compose.yml`)
   * `UDP2RAW_LISTEN_PORT/tcp` (the port you specify for udp2raw in `docker-compose.yml`)
2. Clone the repository:
   ```bash
   git clone https://github.com/mikhailde/wg-udp2raw.git
   ```
3. Fill in the placeholders in `docker-compose.yml`:
   * `UDP2RAW_LISTEN_PORT` (port for udp2raw)
   * `UDP2RAW_KEY` (secret key for udp2raw)
   * `PASSWORD_HASH` (password hash for web UI access, generate with:
     `docker run -it --rm ghcr.io/wg-easy/wg-easy wgpw password`)
4. Start Docker Compose:
   ```bash
   docker-compose up -d
   ```

## Client setup

1. Download udp2raw for your system from the [releases](https://github.com/wangyu-/udp2raw/releases).
2. Copy `udp2raw.service` and `udp2raw/udp2raw.conf` from the repository to `/etc/systemd/system/` and `/etc/udp2raw/` respectively.
3. Fill in the placeholders in `/etc/udp2raw/udp2raw.conf`:
   * `YOUR_SERVER_IP` (your server's public IP or domain name)
   * `SERVER_PORT` (udp2raw listening port on the server, same as `UDP2RAW_LISTEN_PORT` in `docker-compose.yml`)
   * `YOUR_KEY` (secret key for udp2raw, same as in `docker-compose.yml`)
4. Open the Wireguard web UI at `http://YOUR_SERVER_IP:51821` and create a new client.
5. Download the client configuration file and save it as `/etc/wireguard/wg0.conf`.
6. **Important:** In the `[Peer]` section of your client configuration (`wg0.conf`), ensure that only the following is included in `AllowedIPs`:
   ```
   AllowedIPs = 0.0.0.0/0
   ```
   This means you should remove any IPv6 addresses to avoid potential connectivity issues.
7. Add the following lines to the `[Interface]` section of `/etc/wireguard/wg0.conf`:
   ```
   PreUp = ip route add YOUR_SERVER_IP via $(ip route | grep default | awk '{print $3}') && systemctl start udp2raw
   PostDown = ip route del YOUR_SERVER_IP && systemctl stop udp2raw
   ```
   Replace `YOUR_SERVER_IP` with your server's public IP or domain name.
8. Connect to the VPN:
   ```bash
   sudo wg-quick up wg0
   ```

## Additional information

* More information about wg-easy configuration can be found [here](https://github.com/wg-easy/wg-easy).
