# devops-assignment

My work for a technical assignment covering Linux administration, Oracle SQL and PL/SQL, Tomcat behind Nginx, Docker, Kubernetes and Git. Everything is in scripts and config files, so it can be rebuilt from this repository. There are no VM images or binaries here; the sample WAR is built from source.

## Setup

Windows 11 with VirtualBox 7.2 and Vagrant 2.4.9 for the two Ubuntu VMs (22.04 for the Linux part, 24.04 for the Tomcat part), and a Parrot OS VM for Docker, Oracle, minikube and Git.

## Folders

| Folder | What is inside | How to run |
|---|---|---|
| `linux/` | Ubuntu 22.04 Vagrant VM (`postgres02`), OS information script, user and group setup, MySQL and HAProxy, ufw firewall (only 3306 tcp/udp), port check script for Windows | `vagrant up`, then `vagrant ssh -c "sudo bash /vagrant/sysinfo.sh"` |
| `sql/` | Oracle tables with PK, FK, NOT NULL and CHECK constraints, the queries, function `F_HR_QUERY` and procedure `P_COPY_EMPLOYEE` | Oracle Free in Docker: run `00_grants.sql` as SYSTEM, then `ps_oracle.sql` |
| `tomcat/` | Ubuntu 24.04 Vagrant VM with Java 8, Tomcat 9 on port 7070 (forwarded to host port 9090) and Nginx on port 80 for `ps-app.local` | `vagrant up` |
| `app/` | Source of the sample JSP web app (packaged as `ps-app.war`) | Built by the Dockerfile and by `provision.sh` |
| `docker/` | Dockerfile (Tomcat 9 with the WAR), Nginx config, script that runs Tomcat, Nginx and PostgreSQL | `docker build -f docker/Dockerfile -t ps-tomcat:1.0 .` |
| `k8s/` | Deployment (2 replicas with health checks) and NodePort Service | `kubectl apply -f k8s/ps-tomcat.yaml` |
| `docs/` | My notes for the reading questions: Linux, SQL, Tomcat, Docker, Kubernetes, Git, RAID, DevOps, HA/DR, cloud, DNS and load balancers | |

Docker image: https://hub.docker.com/r/tariqatyani/ps-tomcat

Tested with Docker 29.1, Oracle Database Free 23ai, PostgreSQL 16, Nginx 1.27, Tomcat 9.0.124, OpenJDK 8u512, minikube 1.39 (Kubernetes 1.37), Vagrant 2.4.9 and VirtualBox 7.2.
