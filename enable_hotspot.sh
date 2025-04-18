#!/bin/bash
#
# enable_hotspot.sh
# Usage: ./enable_hotspot.sh

# === Configurable variables ===
IFACE="wlp8s0"
CON_NAME="Hotspot"
# HOTSPOT_SSID="MyHotspot"
# HOTSPOT_PASSWORD="yourpassword1234"

# Check if environment variables are set
if [ -z "$HOTSPOT_SSID" ] || [ -z "$HOTSPOT_PASSWORD" ]; then
  echo "Error: HOTSPOT_SSID and HOTSPOT_PASSWORD environment variables must be set"
  exit 1
fi

# Check if the interface exists
if ! nmcli device show "$IFACE" >/dev/null 2>&1; then
  echo "Error: Interface $IFACE not found"
  exit 1
fi

# Check if interface is already in use
if nmcli device show "$IFACE" | grep -q "GENERAL.STATE.*connected"; then
  echo "Warning: Interface $IFACE is currently connected to a network"
  echo "Disconnecting current connection..."
  nmcli device disconnect "$IFACE"
  # Wait for interface to be fully disconnected
  sleep 5
fi

# 1) Turn off the regular Wi‑Fi radio
sudo nmcli radio wifi off
sleep 2

# 2) Delete any old Hotspot profile (ignore errors if it doesn't exist)
sudo nmcli connection delete "$CON_NAME" 2>/dev/null

# 3) Create a new Wi‑Fi connection profile with the SSID
sudo nmcli connection add \
  type wifi ifname "$IFACE" con-name "$CON_NAME" autoconnect yes \
  ssid "$HOTSPOT_SSID"

# 4) Configure AP mode, band, and IPv4 sharing
sudo nmcli connection modify "$CON_NAME" \
  802-11-wireless.mode ap \
  802-11-wireless.band bg \
  ipv4.method shared

# 5) Enforce WPA2‑PSK with AES encryption
sudo nmcli connection modify "$CON_NAME" \
  wifi-sec.key-mgmt wpa-psk
sudo nmcli connection modify "$CON_NAME" \
  wifi-sec.proto rsn
sudo nmcli connection modify "$CON_NAME" \
  wifi-sec.pairwise ccmp
sudo nmcli connection modify "$CON_NAME" \
  wifi-sec.group ccmp
sudo nmcli connection modify "$CON_NAME" \
  wifi-sec.psk "$HOTSPOT_PASSWORD"

# 6) Turn on Wi-Fi radio
sudo nmcli radio wifi on
sleep 2

# 7) Activate the hotspot
if ! nmcli connection up "$CON_NAME"; then
  echo "Error: Failed to activate hotspot"
  # Show detailed device status for debugging
  echo "Current device status:"
  sudo nmcli device show "$IFACE"
  exit 1
fi

echo "Hotspot '$HOTSPOT_SSID' has been created and activated successfully"
