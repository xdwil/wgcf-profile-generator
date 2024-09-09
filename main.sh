#!/bin/sh

# Function to print in red color
red() {
    echo -e "\033[31m\033[01m$1\033[0m"
}

# Function to print in green color
green() {
    echo -e "\033[32m\033[01m$1\033[0m"
}

# Function to print in yellow color
yellow() {
    echo -e "\033[33m\033[01m$1\033[0m"
}

# Remove existing configuration files
rm -f wgcf-account.toml wgcf-profile.conf

# Register a new WARP account
echo | ./wgcf register

# Clear the terminal screen
clear

# Instructions on how to get the CloudFlare WARP account key
yellow "Method to obtain CloudFlare WARP account key:"
green "PC: Download and install CloudFlare WARP → Settings → Preferences → Account → Copy the key into the script"
green "Mobile: Download and install the 1.1.1.1 APP → Menu → Account → Copy the key into the script"
echo ""
yellow "Important: Please ensure that the account status in the 1.1.1.1 APP is WARP+!"

# Prompt for WARP account license key
read -rp "Enter WARP account license key (26 characters): " warpkey
until [[ -z $warpkey || $warpkey =~ ^[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}-[A-Z0-9a-z]{8}$ ]]; do
  red "WARP account license key format is incorrect, please re-enter!"
  read -rp "Enter WARP account license key (26 characters): " warpkey
done

# Update the configuration file with the license key
if [[ -n $warpkey ]]; then
  sed -i "s/license_key.*/license_key = \"$warpkey\"/g" wgcf-account.toml
  read -rp "Please enter a custom device name, if not entered a default random name will be used: " devicename
  green "Registering WARP+ account, if you see '400 Bad Request', you will use a free WARP account"
  if [[ -n $devicename ]]; then
    wgcf update --name $(echo $devicename | sed s/[[:space:]]/_/g) > /etc/wireguard/info.log 2>&1
  else
    wgcf update
  fi
else
  red "No WARP account license key entered, will use a free WARP account"
fi

# Generate the WireGuard configuration file
./wgcf generate

# Clear the terminal screen
clear

# Display success message and configuration details
green "The WireGuard configuration file has been successfully generated!"
yellow "Here is the content of the configuration file:"
cat wgcf-profile.conf
yellow "Here is the QR code for the configuration file:"
qrencode -t ansiutf8 < wgcf-profile.conf