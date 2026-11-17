#!/usr/bin/env bash
# firewall.sh - Task 5: allow TCP/UDP traffic ONLY on port 3306 (run LAST: sudo bash firewall.sh)
# NOTE: this also blocks new SSH sessions (port 22). Your current session stays open.
set -e
apt-get install -y ufw >/dev/null
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow 3306/tcp
ufw allow 3306/udp
ufw --force enable
ufw status verbose

# Same rule on RHEL/CentOS with firewalld (for the report):
#   firewall-cmd --permanent --add-port=3306/tcp
#   firewall-cmd --permanent --add-port=3306/udp
#   firewall-cmd --reload && firewall-cmd --list-ports
