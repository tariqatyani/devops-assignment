#!/usr/bin/env bash
# sysinfo.sh - display OS information and resource usage
# Usage: sudo ./sysinfo.sh

executed_by=$(whoami)
host_name=$(hostname)
server_ip=$(hostname -I | awk '{print $1}')
public_ip=$(curl -s --max-time 5 https://ifconfig.me || echo "unavailable")
os_version=$(. /etc/os-release && echo "$PRETTY_NAME")
kernel=$(uname -r)
arch=$(uname -m)

# systemd-detect-virt prints "oracle" for VirtualBox, "vmware", "kvm", or "none"
virt=$(systemd-detect-virt 2>/dev/null || echo "none")
[ "$virt" = "oracle" ] && virt="Oracle"

server_time=$(date)
tz_name=$(timedatectl show -p Timezone --value 2>/dev/null || cat /etc/timezone)
timezone="$tz_name ($(date +%Z))"
up_time=$(uptime -p | sed 's/^up //')

# free -h prints sizes like 1.9Gi / 297Mi -> add "B" to make GiB / MiB
mem_total=$(free -h | awk '/^Mem:/  {print $2}' | sed 's/i\b/iB/g')
mem_used=$(free -h  | awk '/^Mem:/  {print $3" / "$2}' | sed 's/i\b/iB/g')
swap_used=$(free -h | awk '/^Swap:/ {print $3" / "$2}' | sed 's/i\b/iB/g')
cpu_cores=$(nproc)

# put a space between number and unit: 1.9GiB -> 1.9 GiB
space() { sed -E 's/([0-9.])([KMGT]iB|B)/\1 \2/g'; }
mem_total=$(echo "$mem_total" | space)
mem_used=$(echo "$mem_used"   | space)
swap_used=$(echo "$swap_used" | space)

echo "System Information"
echo "  • Executed By: $executed_by"
echo "  • Hostname: $host_name"
echo "  • Server IP: $server_ip"
echo "  • Public IP: $public_ip"
echo "  • OS Type and Version: $os_version"
echo "  • Kernel Version: $kernel"
echo "  • Architecture: $arch"
echo "  • Virtualization: $virt"
echo "  • Server Time: $server_time"
echo "  • Timezone: $timezone"
echo "  • Uptime: $up_time"
echo
echo "Resource Usage"
echo "  • Total Memory: $mem_total"
echo "  • Memory Usage: $mem_used"
echo "  • Swap Usage: $swap_used"
echo "  • CPU Cores: $cpu_cores"
