# Local Pi-hole With Docker

This repo runs Pi-hole locally via Docker Compose. Pi-hole is a DNS sinkhole — it blocks ads, trackers, and malware by intercepting DNS queries before they reach ad servers. **It only works if your device's DNS is pointed at it** (see "Making it block ads" below).


## Prerequisites

- Docker Desktop installed and running
- `make` available (macOS/Linux; Windows users can run the `docker compose` commands directly)
- `openssl` available (used by `setup.sh` to generate a password)

## Files

- `docker-compose.yml` — Pi-hole service definition
- `init-pihole.sh` — adds blocklists and triggers a gravity update on startup
- `setup.sh` — generates `.env` with a random password (run this first)
- `Makefile` — shortcuts for common operations
- `.env` — local environment variables (not committed)

## Setup

### 1. Generate .env

```bash
make setup
# Windows (Git Bash or WSL): bash setup.sh
```

This prompts for [timezone](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) and upstream DNS (both have defaults), generates a random password, and writes `.env`. The password is shown once — **save it in your password manager**.

### 2. Start Pi-hole

```bash
make up
```

> **Important:** Run `make up` before `make dns-on`. Docker needs your normal system DNS to pull images from the internet. If DNS is already pointed at `127.0.0.1` and Pi-hole isn't running yet, image pulls will fail with a DNS resolution error. If that happens, run `make dns-off` first, then retry `make up`.

### 3. Access the web UI

Navigate to `http://localhost/admin` and log in with the password from step 1.

## Making it block ads

Pi-hole only filters traffic when your device's DNS queries go through it. Once Pi-hole is running (`make up`), point your DNS to `127.0.0.1`:

**macOS**
```bash
make dns-on    # point DNS to Pi-hole (may prompt for admin password)
make dns-off   # restore automatic DNS
```
Defaults to the `Wi-Fi` interface. Override with `make dns-on MACOS_IFACE=Ethernet`.

**Linux**
```bash
make dns-on    # uses resolvectl, auto-detects active interface
make dns-off   # reverts interface DNS
```
Override with `make dns-on LINUX_IFACE=eth0`. Requires `systemd-resolved`.

**Windows (PowerShell — run as Administrator)**
```powershell
# Enable
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ServerAddresses "127.0.0.1"

# Restore
Set-DnsClientServerAddress -InterfaceAlias "Wi-Fi" -ResetServerAddresses
```
Replace `"Wi-Fi"` with your adapter name (check with `Get-NetAdapter`).

**Verify it's working**
```bash
dig @127.0.0.1 doubleclick.net   # should return 0.0.0.0
dig @127.0.0.1 google.com        # should resolve normally
```

## Updating blocklists

Edit `init-pihole.sh` to add or remove lists. [Source of current lists.](https://firebog.net/)

Apply without restarting Pi-hole:

```bash
make update-lists
```

Existing lists respond with a graceful "already exists"; only new entries are registered. Gravity runs automatically at the end.

## Troubleshooting

**Pi-hole logs**
```bash
make logs
```

**Blocklist registration logs**
```bash
make init-logs
```

**Recreate containers**
```bash
make down
make up
```
