#!/usr/bin/env sh
set -eu

PIHOLE_URL="http://pihole"

echo "Authenticating to Pi-hole API..."
attempt=1
SID=""
while [ $attempt -le 5 ]; do
  SID=$(curl -sf -X POST "${PIHOLE_URL}/api/auth" \
    --data "{\"password\":\"${PIHOLE_WEB_PASSWORD}\"}" | jq -r '.session.sid')
  [ -n "${SID}" ] && [ "${SID}" != "null" ] && break
  echo "  Auth attempt ${attempt}/5 failed, retrying in 5s..."
  attempt=$((attempt + 1))
  sleep 5
done

if [ -z "${SID}" ] || [ "${SID}" = "null" ]; then
  echo "ERROR: Failed to authenticate to Pi-hole API after 5 attempts" >&2
  exit 1
fi

add_list() {
  url="$1"
  comment="$2"
  code=$(curl -s -o /tmp/resp.json -w "%{http_code}" -X POST "${PIHOLE_URL}/api/lists" \
    -H "X-FTL-SID: ${SID}" \
    -H "Content-Type: application/json" \
    --data "{\"address\":\"${url}\",\"type\":\"block\",\"comment\":\"${comment}\",\"enabled\":true}")
  case "$code" in
    201) echo "  added: ${comment}" ;;
    400) echo "  skipped (already exists?): ${comment}" ;;
    *) echo "  FAILED (${code}): ${comment} -- $(cat /tmp/resp.json)" >&2 ;;
  esac
}

# Suspicious
add_list "https://raw.githubusercontent.com/PolishFiltersTeam/KADhosts/master/KADhosts.txt" "KADhosts"
add_list "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Spam/hosts" "FadeMind Spam"
add_list "https://v.firebog.net/hosts/static/w3kbl.txt" "w3kbl"
add_list "https://raw.githubusercontent.com/matomo-org/referrer-spam-blacklist/master/spammers.txt" "Matomo referrer spam"
add_list "https://someonewhocares.org/hosts/zero/hosts" "someonewhocares"
add_list "https://raw.githubusercontent.com/RooneyMcNibNug/pihole-stuff/master/SNAFU.txt" "SNAFU"

# Advertising
add_list "https://adaway.org/hosts.txt" "AdAway"
add_list "https://v.firebog.net/hosts/AdguardDNS.txt" "AdguardDNS"
add_list "https://v.firebog.net/hosts/Admiral.txt" "Admiral"
add_list "https://raw.githubusercontent.com/anudeepND/blacklist/master/adservers.txt" "anudeepND adservers"
add_list "https://v.firebog.net/hosts/Easylist.txt" "Easylist"
add_list "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext" "yoyo adservers"
add_list "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/UncheckyAds/hosts" "UncheckyAds"
add_list "https://raw.githubusercontent.com/bigdargon/hostsVN/master/hosts" "hostsVN"

# Tracking & Telemetry
add_list "https://v.firebog.net/hosts/Easyprivacy.txt" "Easyprivacy"
add_list "https://v.firebog.net/hosts/Prigent-Ads.txt" "Prigent-Ads"
add_list "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.2o7Net/hosts" "2o7Net"
add_list "https://raw.githubusercontent.com/crazy-max/WindowsSpyBlocker/master/data/hosts/spy.txt" "WindowsSpyBlocker"
add_list "https://hostfiles.frogeye.fr/firstparty-trackers-hosts.txt" "Frogeye first-party trackers"

# Malicious
add_list "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/Alternate%20versions%20Anti-Malware%20List/AntiMalwareHosts.txt" "AntiMalwareHosts"
add_list "https://v.firebog.net/hosts/Prigent-Crypto.txt" "Prigent-Crypto"
add_list "https://v.firebog.net/hosts/Prigent-Malware.txt" "Prigent-Malware"
add_list "https://raw.githubusercontent.com/FadeMind/hosts.extras/master/add.Risk/hosts" "Risk"
add_list "https://phishing.army/download/phishing_army_blocklist_extended.txt" "Phishing Army"
add_list "https://malware-filter.gitlab.io/malware-filter/phishing-filter-hosts.txt" "phishing-filter"
add_list "https://gitlab.com/quidsup/notrack-blocklists/raw/master/notrack-malware.txt" "NoTrack Malware"
add_list "https://raw.githubusercontent.com/Spam404/lists/master/main-blacklist.txt" "Spam404"
add_list "https://raw.githubusercontent.com/AssoEchap/stalkerware-indicators/master/generated/hosts" "Stalkerware"
add_list "https://urlhaus.abuse.ch/downloads/hostfile/" "URLhaus"
add_list "https://lists.cyberhost.uk/malware.txt" "Cyberhost malware"
add_list "https://raw.githubusercontent.com/jarelllama/Scam-Blocklist/main/lists/wildcard_domains/scams.txt" "Scam Blocklist"
add_list "https://v.firebog.net/hosts/RPiList-Malware.txt" "RPiList Malware"
add_list "https://v.firebog.net/hosts/RPiList-Phishing.txt" "RPiList Phishing"

echo "Triggering gravity update..."
curl -sf -X POST "${PIHOLE_URL}/api/action/gravity" -H "X-FTL-SID: ${SID}" >/dev/null

echo "Done."
