#!/bin/bash

# URL for IVPN servers stats JSON
URL="https://api.ivpn.net/v4/servers/stats"

# Fetch JSON data from API
json=$(curl -s "$URL")

# Check if curl succeeded
if [ -z "$json" ]; then
  echo "Failed to fetch data from $URL"
  exit 1
fi

# Print Markdown table header
echo "| Gateway | City | Country | ISP | Load (%) | Protocols | Server Speed | Socks5 Proxy | WireGuard Public Key | Multihop Port | Active | In Maintenance | Latitude | Longitude |"
echo "|---------|------|---------|-----|----------|-----------|--------------|--------------|----------------------|---------------|--------|----------------|----------|-----------|"

# Parse and print each server as a row in the Markdown table
echo "$json" | jq -r '
  .servers[] |
  [
    .gateway,
    .city,
    .country,
    .isp,
    (.load|tostring),
    (.protocols | join(", ")),
    (.server_speed // "N/A"),
    (.socks5 // "N/A"),
    .wg_public_key,
    (.multihop_port|tostring),
    (.is_active|tostring),
    (.in_maintenance|tostring),
    (.latitude|tostring),
    (.longitude|tostring)
  ] |
  @tsv
' | while IFS=$'\t' read -r gateway city country isp load protocols speed socks5 wgkey port active maintenance lat lon; do
  # Escape pipes in data to not break Markdown table
  gateway="${gateway//|/\\|}"
  city="${city//|/\\|}"
  country="${country//|/\\|}"
  isp="${isp//|/\\|}"
  protocols="${protocols//|/\\|}"
  speed="${speed//|/\\|}"
  socks5="${socks5//|/\\|}"
  wgkey="${wgkey//|/\\|}"

  echo "| $gateway | $city | $country | $isp | $load | $protocols | $speed | $socks5 | $wgkey | $port | $active | $maintenance | $lat | $lon |"
done
