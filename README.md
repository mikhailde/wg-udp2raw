# Wireguard with udp2raw

Этот проект предоставляет простую настройку Wireguard с использованием udp2raw для обхода блокировок.

## Особенности

* Легкая установка с помощью Docker Compose.
* Web-интерфейс для управления Wireguard (wg-easy).
* udp2raw для обфускации трафика.
* Автоматический запуск и перезапуск сервисов.
* **Возможность создания полноценной VPN-сети**, в отличие от простых прокси-шлюзов, таких как shadowsocks или v2ray.

## Установка сервера

1. **Откройте порты на вашем сервере:**
   * `51821/tcp` (для web-интерфейса, если не меняли порт в `docker-compose.yml`)
   * `UDP2RAW_LISTEN_PORT/tcp` (порт, который вы укажете для udp2raw в `docker-compose.yml`)
2. Клонируйте репозиторий:
   ```bash
   git clone https://github.com/mikhailde/wireguard-udp2raw.git
   ```
3. Заполните плейсхолдеры в файле `docker-compose.yml`:
   * `UDP2RAW_LISTEN_PORT` (порт, на котором будет слушать udp2raw)
   * `UDP2RAW_KEY` (секретный ключ для udp2raw)
   * `PASSWORD_HASH` (хэш пароля для доступа к web-интерфейсу, генерируется командой:
     ```bash
     docker run -it --rm ghcr.io/wg-easy/wg-easy wgpw password
     ```
     )
4. Запустите Docker Compose:
   ```bash
   docker-compose up -d
   ```

## Настройка клиента

1. Скачайте udp2raw для вашей системы с [релизов](https://github.com/wangyu-/udp2raw/releases).
2. Скопируйте файл `udp2raw.service` из репозитория в `/etc/systemd/system/`.
3. Скопируйте файл `udp2raw/udp2raw.conf` из репозитория в `/etc/udp2raw/`.
4. Заполните плейсхолдеры в файле `/etc/udp2raw/udp2raw.conf`:
   * `YOUR_SERVER_IP` (публичный IP или доменное имя вашего сервера)
   * `SERVER_PORT` (порт, на котором слушает udp2raw на сервере, тот же, что и `UDP2RAW_LISTEN_PORT` в `docker-compose.yml`)
   * `YOUR_KEY` (секретный ключ для udp2raw, тот же, что и в `docker-compose.yml`)
5. Откройте web-интерфейс Wireguard по адресу `http://YOUR_SERVER_IP:51821` и создайте нового клиента.
6. Скачайте конфигурационный файл клиента и сохраните его как `/etc/wireguard/wg0.conf`.
7. Добавьте следующие строки в раздел `[Interface]` файла `/etc/wireguard/wg0.conf`:
   ```
   PreUp = ip route add YOUR_SERVER_IP via $(ip route | grep default | awk '{print $3}') && systemctl start udp2raw
   PostDown = ip route del YOUR_SERVER_IP && systemctl stop udp2raw
   ```
   Замените `YOUR_SERVER_IP` на публичный IP или доменное имя вашего сервера.
8. Подключитесь к VPN:
   ```bash
   sudo wg-quick up wg0
   ```
