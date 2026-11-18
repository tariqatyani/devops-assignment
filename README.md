# ps-assignment

My work for a DevOps / support-engineering take-home assignment: Linux administration, Oracle SQL and
PL/SQL, Tomcat behind Nginx, Docker, Kubernetes and Git. Everything is scripted, so it can be rebuilt
from this repo. No VM images or binaries are stored here; the sample WAR is built from source.

| Folder | What's inside | How to run |
|---|---|---|
| `linux/` | Ubuntu 22.04 Vagrant VM (`postgres02`), system-info script, user/group + MySQL + HAProxy setup, ufw firewall (only 3306 tcp/udp), Windows port check | `vagrant up`, then `vagrant ssh -c "sudo bash /vagrant/sysinfo.sh"` |
| `sql/` | Oracle schema with PK/FK/NOT NULL/CHECK constraints, queries, function `F_HR_QUERY` (ref cursor), procedure `P_COPY_EMPLOYEE` | Oracle Free in Docker: run `00_grants.sql` as SYSTEM, then `ps_oracle.sql` |
| `tomcat/` | Ubuntu 24.04 Vagrant VM: Java 8, Tomcat 9 on port 7070 (forwarded to host 9090), Nginx reverse proxy on port 80 for `ps-app.local` | `vagrant up` |
| `app/` | Source of the sample JSP web app (packaged into `ps-app.war`) | built by Docker / provision script |
| `docker/` | Multi-stage Dockerfile (Tomcat 9 + WAR), Nginx config, script that runs Tomcat + Nginx + PostgreSQL | `docker build -f docker/Dockerfile -t ps-tomcat:1.0 .` |
| `k8s/` | Deployment (replicas, probes) + NodePort Service | `kubectl apply -f k8s/ps-tomcat.yaml` |
| `docs/` | Theory notes: Linux, SQL, Tomcat/JVM/WAR, Docker, Kubernetes, Git, RAID, DevOps, HA/DR, cloud, DNS, load balancers | – |

Tested with: Docker 29.1, Oracle Database Free 23ai, PostgreSQL 16, Nginx 1.27, Tomcat 9.0.124,
OpenJDK 8u512, minikube 1.39 (Kubernetes 1.37), Vagrant + VirtualBox 7.2.

**Setup:** Windows 11 host with VirtualBox + Vagrant (Ubuntu 22.04 and 24.04 VMs for the Linux and Tomcat parts), and a Parrot OS VM for Docker, Oracle, minikube and Git.
