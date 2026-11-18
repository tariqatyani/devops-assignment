# Linux notes

Notes for Linux task 7 (architecture, directories, distributions).

## About Linux

**What Linux is.** Linux is the kernel: the core program that controls the hardware (CPU, memory, disks, network) and shares it between programs. A distribution adds the rest: tools, a package manager, systemd and default settings.

**Architecture,** from the bottom up:

1. Hardware
2. Kernel: process scheduling, memory, drivers, file systems, networking. It runs in kernel space with full access to the hardware.
3. System libraries such as glibc, which programs use to call the kernel (system calls like `open`, `read`, `fork`)
4. Shell and utilities: `bash`, `ls`, `grep`, `systemctl`
5. Applications such as MySQL, Tomcat and Nginx, which run in user space

**Main directories.** Linux has one tree that starts at `/`.

| Path | What it holds |
|---|---|
| `/etc` | Configuration files (`/etc/passwd`, `/etc/hosts`, `/etc/nginx/`) |
| `/home`, `/root` | Home folders of users, and of root |
| `/var` | Data that changes: logs in `/var/log`, MySQL data in `/var/lib/mysql` |
| `/bin`, `/usr/bin`, `/sbin` | Commands for users, and admin commands |
| `/opt` | Extra software (I installed Tomcat in `/opt/tomcat`) |
| `/tmp` | Temporary files |
| `/boot` | Kernel and boot loader files |
| `/dev`, `/proc`, `/sys` | Devices and kernel information shown as files |

**Distributions.**

- Debian family: Debian, Ubuntu, Parrot, Kali. They use `.deb` packages with `apt`.
- Red Hat family: RHEL, CentOS Stream, Rocky Linux, AlmaLinux, Fedora. They use `.rpm` packages with `dnf` or `yum`.
- Others: SUSE (`zypper`), Arch (`pacman`), Alpine (`apk`, very small and common in Docker images).

Company servers usually run RHEL-compatible systems or Ubuntu LTS.

**Users and permissions.** Users are stored in `/etc/passwd`, password hashes in `/etc/shadow`, and groups in `/etc/group`. Each file has read, write and execute permissions for the owner, the group and others (for example `750`). `root` can do anything, and `sudo` lets a normal user run a command as root.

**Boot process:** BIOS/UEFI, then the GRUB boot loader, then the kernel, then systemd (process 1), which starts all the services.
