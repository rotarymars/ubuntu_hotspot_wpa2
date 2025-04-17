#!/bin/bash
#
# disable_hotspot.sh
# Usage: sudo ./disable_hotspot.sh

# --- Configurable variables ---
CON_NAME="Hotspot"
# To auto-reconnect to a saved Wi‑Fi to SSID, uncomment and set:
# WIFI_CONN="YourSavedSSID"

# 1) Deactivate the hotspot
nmcli connection down "$CON_NAME" 2>/dev/null

# 2) Re-enable Wi‑Fi radio
nmcli radio wifi on

# 3) (Optional) Reconnect to a saved network
# nmcli connection up "$WIFI_CONN"
