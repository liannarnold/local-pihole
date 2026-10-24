#!/usr/bin/env sh
set -e

if [ -f .env ]; then
  echo ".env already exists — delete it first to re-run setup."
  exit 0
fi

printf "Timezone [US/Central]: "
read -r TZ_INPUT
TZ_VAL="${TZ_INPUT:-US/Central}"

printf "Upstream DNS [9.9.9.9;149.112.112.112]: "
read -r DNS_INPUT
DNS_VAL="${DNS_INPUT:-9.9.9.9;149.112.112.112}"

UPPER=$(openssl rand -base64 32 | tr -dc 'A-Z' | head -c 4)
LOWER=$(openssl rand -base64 32 | tr -dc 'a-z' | head -c 12)
NUMS=$(openssl rand -base64 32 | tr -dc '0-9' | head -c 4)
SYMS=$(awk 'BEGIN{srand(); s="!@#$%^&*-_"; printf "%s%s%s%s", substr(s,int(rand()*10)+1,1), substr(s,int(rand()*10)+1,1), substr(s,int(rand()*10)+1,1), substr(s,int(rand()*10)+1,1)}')
PASSWORD=$(printf '%s' "${UPPER}${LOWER}${NUMS}${SYMS}" | fold -w1 | sort -R | tr -d '\n')

cat > .env <<EOF
PIHOLE_WEB_PASSWORD='${PASSWORD}'
TZ='${TZ_VAL}'
FTL_DNS_UPSTREAMS='${DNS_VAL}'
EOF

chmod 600 .env
chmod +x init-pihole.sh

echo ""
echo "Pi-hole password (save this in your password manager):"
echo "  ${PASSWORD}"
echo ""
echo ".env created. Run 'make up' to start Pi-hole."
