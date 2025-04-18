#!/bin/bash
#
# enable_hotspot.sh
# Usage: ./enable_hotspot.sh

# === Configurable variables ===
IFACE="wlp8s0"
CON_NAME="Hotspot"

# Check if environment variables are set
if [ -z "$HOTSPOT_SSID" ] || [ -z "$HOTSPOT_PASSWORD" ]; then
  echo "Error: HOTSPOT_SSID and HOTSPOT_PASSWORD environment variables must be set"
  exit 1
fi


# Stop services if they're running
sudo systemctl stop hostapd
sudo systemctl stop dnsmasq

# Configure hostapd
cat << EOF | sudo tee /etc/hostapd/hostapd.conf
interface=$IFACE
driver=nl80211
ssid=$HOTSPOT_SSID
hw_mode=g
channel=6
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$HOTSPOT_PASSWORD
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
EOF

# Configure dnsmasq
cat << EOF | sudo tee /etc/dnsmasq.conf
interface=$IFACE
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

# Configure network interface
sudo ifconfig $IFACE 192.168.4.1 netmask 255.255.255.0

# Start services
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
sudo systemctl start hostapd
sudo systemctl start dnsmasq

# Enable IP forwarding
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# Configure NAT
sudo iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE

echo "Hotspot '$HOTSPOT_SSID' has been created and activated successfully"
echo "Devices should now be able to connect to the WiFi network"
