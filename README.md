# Local Pi-hole With Docker

This repo contains a Docker Compose setup to run Pi-hole locally, including:

- Upstream DNS
- Automatic installation of selected ad/malware/phishing blocklists via an init script
- A `.env` based secret so the Pi-hole web/API password is not committed

## Prerequisites

- Docker Desktop installed and running
- Docker Compose available (Compose V2 is recommended)
- A place on your computer to persist Pi-hole data (created automatically by Docker volume mounts)

## Files

- `docker-compose.yml` — Pi-hole service definition
- `init-pihole.sh` — script that adds blocklists and runs `pihole -g`
- `init-pihole.sh` is mounted into the container read-only
- `.env` — local environment variables (not committed)

## Instructions

### 1) Create `.env`

Create a file named `.env` in the same folder as `docker-compose.yml`:

```bash
PIHOLE_WEB_PASSWORD='your-strong-password'
TZ='US/Central'
FTL_DNS_UPSTREAMS='9.9.9.9;149.112.112.112'
```

Note: 
- Choose a strong, unique password for `PIHOLE_WEB_PASSWORD`
- [Timezone Codes](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
- `FTL_DNS_UPSTREAMS` can be changed to other resolvers
    - The example is pointed to Quad9

### 2) Make Script Executable

```bash
chmod +x init-pihole.sh
```

### 3) Start Pi-hole
```bash
docker compose up -d
```

### 4) Access Pi-hole web UI
1. In a browser, navigate to `http://localhost/admin`
2. Log in with `PIHOLE_WEB_PASSWORD` from `.env`

## Notes

### Updating Blocklists
1. Edit `init-pihole.sh`
2. Restart container
```bash
docker compose restart
```

## Troubleshooting

### Logs
```bash
docker logs -f pihole
```

### Recreate Container
```bash
docker compose down
docker compose up -d
```
