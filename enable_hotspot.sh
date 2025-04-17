#!/bin/bash
#
# enable_hotspot.sh
# Usage: sudo ./enable_hotspot.sh

# --- Configurable variables ---
IFACE="wlan0"
CON_NAME="Hotspot"
# HOTSPOT_SSID="MyHotspot"
# HOTSPOT_PASSWORD="yourpassword1234"

nmcli radio wifi off

nmcli connection delete "$CON_NAME" 2>/dev/null

nmcli connection add \
  type wifi ifname "$IFACE" con-name "$CON_NAME" autoconnect yes ssid "$HOTSPOT_SSID" \
  802-11-wireless.mode ap 802-11-wireless.band bg ipv4.method shared \
  wifi-sec.key-mgmt wpa-psk wifi-sec.psk "$HOTSPOT_PASSWORD"

nmcli connection up "$CON_NAME"
