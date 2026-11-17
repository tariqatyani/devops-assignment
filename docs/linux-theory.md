# Linux – theory notes

## What Linux is
Linux is strictly the **kernel**: the core program that talks to the hardware (CPU, memory, disks,
network) and shares it between running programs. A **distribution** (distro) wraps the kernel with
everything else you need: GNU tools, a package manager, an init system (systemd), and default configs.

## Architecture (layers, bottom to top)
1. **Hardware** – CPU, RAM, disks, network cards.
2. **Kernel** – process scheduling, memory management, device drivers, file systems, networking, security.
   Runs in *kernel space* with full access to the hardware.
3. **System libraries** (e.g. glibc) – give programs a standard way to ask the kernel for things
   (**system calls** such as `open`, `read`, `fork`).
4. **Shell and utilities** – `bash`, `ls`, `grep`, `systemctl`... The shell reads your commands and runs them.
5. **Applications** – MySQL, Tomcat, Nginx. These run in *user space* and can't touch the hardware directly.

## Directory layout (Filesystem Hierarchy Standard)
| Path | What lives there |
|---|---|
| `/` | Root of everything – Linux has one tree, no C:/D: drives |
| `/bin`, `/usr/bin` | Commands for all users (`ls`, `cp`) |
| `/sbin`, `/usr/sbin` | Admin commands (`useradd`, `ufw`) |
| `/etc` | Configuration files (`/etc/passwd`, `/etc/hosts`, `/etc/nginx/`) |
| `/home` | Users' home folders; `/root` is root's home |
| `/var` | Data that changes: logs (`/var/log`), databases (`/var/lib/mysql`), mail, caches |
| `/tmp` | Temporary files, often cleared on reboot |
| `/opt` | Optional / third-party software (Tomcat went into `/opt/tomcat`) |
| `/boot` | Kernel and bootloader files |
| `/dev` | Devices shown as files (`/dev/sda` = first disk) |
| `/proc`, `/sys` | Virtual files that show kernel and process info (`/proc/cpuinfo`) |
| `/lib`, `/usr/lib` | Shared libraries and kernel modules |
| `/mnt`, `/media` | Mount points for extra disks / USB |

"Everything is a file": devices, processes and settings can all be read like files.

## Distributions
- **Debian family** – Debian, Ubuntu, Linux Mint, Parrot, Kali. Packages: `.deb`, tools `apt` / `dpkg`.
- **Red Hat family** – RHEL, CentOS Stream, Rocky Linux, AlmaLinux, Fedora. Packages: `.rpm`, tools `dnf` / `yum` / `rpm`.
- **Others** – SUSE (`zypper`), Arch (`pacman`), Alpine (`apk`, tiny – common in Docker images).

Servers in companies mostly run RHEL-compatible systems or Ubuntu LTS (long-term support, 5+ years of updates).

## Users, groups and permissions
- Users are in `/etc/passwd`, password hashes in `/etc/shadow`, groups in `/etc/group`.
- Every user has one **primary group** (owns the files they create) and can be in many **secondary groups**.
  Task 2: `useradd -m -g PSgroup -G dba PS`.
- Permissions: `rwx` for **u**ser, **g**roup, **o**thers – e.g. `-rwxr-x---` = `750`.
  Change them with `chmod`, change the owner with `chown`.
- `root` (UID 0) can do anything. `sudo` lets a normal user run one command as root.

## Commands worth knowing
- Files: `ls -l`, `cd`, `pwd`, `cp`, `mv`, `rm`, `mkdir`, `find`, `cat`, `less`, `tail -f`, `grep`
- Disk: `df -h`, `du -sh`
- Processes: `ps aux`, `top`, `kill`
- Services: `systemctl status|start|stop|enable <svc>`, logs with `journalctl -u <svc>`
- Network: `ip a`, `ss -tlnp`, `ping`, `curl`, `nc -zv host port`
- Packages: `apt update`, `apt install`; on Red Hat, `dnf install`
- Users: `useradd`, `usermod`, `passwd`, `id`

## Boot process (short)
BIOS/UEFI → bootloader (GRUB) → kernel + initramfs → **systemd** (PID 1) → services and targets → login.

## Firewalls
The kernel filter is **netfilter**. You manage it with `iptables` / `nftables`, or with the friendlier
**ufw** (Ubuntu) and **firewalld** (Red Hat). Task 5: by default deny incoming traffic, allow only 3306 tcp+udp.

## Ways to copy a file to a Linux server (Task 6)
- `scp` – copy over SSH.
- `sftp` – interactive FTP-like session over SSH.
- `rsync` – copies only what changed, can resume.
- GUI tools: FileZilla / WinSCP (SFTP).
- Vagrant extras: `vagrant upload`, and the shared folder `/vagrant`.
- Classic FTP (`vsftpd`) – plain text and insecure, so SFTP is preferred.
