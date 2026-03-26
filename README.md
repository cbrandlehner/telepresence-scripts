# Project Overview
This project provides scripts and configuration files to automate the repurposing of CISCO MX300 G2 Telepresence Screens as external displays for Mac/PC using DVI or HDMI connections.

Why This Matters:
The CISCO MX300 G2 is an enterprise-grade telepresence screen discontinued by CISCO. However, with proper repurposing, these units offer exceptional display quality and can become valuable external monitors.

# Why This Project Exists
I created this project after discovering a cheap used CISCO MX300 G2 rendered obsolete by CISCO. The device itself remains high-quality, and through automation, I was able to unlock its full potential as an external display.

# Problem Statement:

CISCO MX300 G2 screens are becoming available second-hand at extremely low prices
The devices lack native support for modern video conferencing tools
Most users cannot take full advantage of these screens' capabilities
Solution:
This project provides:

Automated configuration tools
Custom scripts for HDMI/DVI connection management

# Script Repository Overview
### deploy-mx300-cert.sh
Uploads a SSL certificate to be used by the integrated web server. You can then access https://devicename.home.arpa without a certificate warning.
### check_ports.sh
Lists the ports (camera, DVI and HDMI) indicating if there is an input signal.
### set_volume.sh
Set the device volume
### show_hdmi.sh
The device will display the HDMI input signal full screen.
### stop_presentation.sh
Stops the HDMI display
### standby.sh
Sends the device into standby mode.

# Configuration

Edit the files to configure the device hostname and your SSH username.

Create a file (.mx300-pass) which contains your ssh password.
