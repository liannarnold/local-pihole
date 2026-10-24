# Available targets:
#   setup         — create .env with a generated password (run this first)
#   up            — start the Pi-hole stack
#   down          — stop the stack
#   restart       — restart the Pi-hole container
#   logs          — stream Pi-hole logs
#   init-logs     — show blocklist registration output
#   update-lists  — re-register blocklists against a running Pi-hole (no restart needed)
#   status        — show container status
#   dns-on        — point system DNS to 127.0.0.1 (may need sudo on some systems)
#   dns-off       — restore system DNS to automatic
#
# Interface overrides:
#   macOS: make dns-on MACOS_IFACE=Ethernet   (default: Wi-Fi)
#   Linux: make dns-on LINUX_IFACE=eth0       (default: auto-detected via ip route)

UNAME       := $(shell uname -s)
MACOS_IFACE ?= Wi-Fi
LINUX_IFACE ?= $(shell ip route get 1.1.1.1 2>/dev/null | grep -oP 'dev \K\S+' 2>/dev/null | head -1)

.PHONY: setup up down restart logs init-logs update-lists status dns-on dns-off

setup:
	bash setup.sh

up:
	docker compose up -d
	@echo ""
	@echo "Pi-hole is running. To block ads, point your DNS to 127.0.0.1:"
	@echo "  make dns-on        (macOS / Linux)"
	@echo "  See README for Windows instructions."

down:
	docker compose down

restart:
	docker compose restart pihole

logs:
	docker logs -f pihole

init-logs:
	docker compose logs pihole-init

update-lists:
	docker compose run --rm pihole-init

status:
	docker compose ps

dns-on:
ifeq ($(UNAME),Darwin)
	networksetup -setdnsservers "$(MACOS_IFACE)" 127.0.0.1
	@echo "DNS → 127.0.0.1 on $(MACOS_IFACE). Run 'make dns-off' to restore."
else ifeq ($(UNAME),Linux)
	resolvectl dns $(LINUX_IFACE) 127.0.0.1
	@echo "DNS → 127.0.0.1 on $(LINUX_IFACE). Run 'make dns-off' to restore."
else
	@echo "Automatic DNS setup is not supported on this OS. See README for Windows instructions."
endif

dns-off:
ifeq ($(UNAME),Darwin)
	networksetup -setdnsservers "$(MACOS_IFACE)" empty
	@echo "DNS restored to automatic on $(MACOS_IFACE)."
else ifeq ($(UNAME),Linux)
	resolvectl revert $(LINUX_IFACE)
	@echo "DNS reverted on $(LINUX_IFACE)."
else
	@echo "Automatic DNS restore is not supported on this OS. See README for Windows instructions."
endif
