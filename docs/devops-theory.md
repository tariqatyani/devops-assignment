# DevOps – theory notes

## Docker
**What it is:** a tool that packages an app together with everything it needs (runtime, libraries,
config) into an **image**, and runs that image as an isolated process called a **container**.
Containers share the host's Linux kernel, so they start in seconds and use far less RAM than VMs.
Isolation comes from kernel features: **namespaces** (each container sees its own processes, network
and files) and **cgroups** (limits on CPU and RAM).

| | Virtual machine | Container |
|---|---|---|
| Contains | Whole OS + kernel | App + libraries only |
| Size / start | GBs / minutes | MBs / seconds |
| Isolation | Strong (hypervisor) | Process level (shared kernel) |

**Key words:**
- **Dockerfile** – the recipe for an image.
- **Image** – a read-only template built from layers.
- **Container** – a running instance of an image.
- **Registry** – the store for images (Docker Hub, GitHub GHCR, AWS ECR, Harbor).
- **Volume** – data that outlives the container.
- **Network** – containers on the same user-defined network find each other by name.

**Use cases:**
- "works on my machine" problems go away
- the same image runs in dev, test and prod
- microservices
- CI/CD pipelines
- quick test environments (I ran Oracle, PostgreSQL and Nginx in minutes)
- packaging legacy apps

**Basic commands:**
```bash
docker build -t user/app:1.0 .        # build an image from a Dockerfile
docker images                         # list images
docker run -d --name web -p 8080:80 nginx   # start a container in the background, publish a port
docker ps / docker ps -a              # running / all containers
docker logs -f web                    # container output
docker exec -it web sh                # shell inside a running container
docker stop web / docker start web / docker rm web
docker pull nginx / docker push user/app:1.0
docker login                          # log in to a registry
docker volume ls / docker network ls
docker compose up -d                  # start several containers from docker-compose.yml
```
**My Dockerfile** uses a *multi-stage build*. Stage 1 (a JDK image) packages the WAR. Stage 2 is
`tomcat:9` and copies in only the WAR, so build tools don't end up in the final image.

## Kubernetes
**What it is:** a container **orchestrator**. You describe *what you want* in YAML (desired state):
"3 replicas of this image, reachable on port 80". Kubernetes keeps it that way: it places pods on
nodes, restarts crashed containers, replaces pods when a node dies, scales, and does rolling updates.

Main objects:
- **Pod** – the smallest unit: one or more containers that share an IP.
- **Deployment** – manages identical pods through a ReplicaSet and handles updates/rollbacks.
- **Service** – a stable IP/DNS name that load-balances over pods. Types: ClusterIP, NodePort, LoadBalancer.
- **Ingress** – HTTP routing by host/path.
- **ConfigMap / Secret** – configuration and passwords.
- **Namespace** – a separate group of objects inside one cluster.

### Master (control plane) vs worker nodes
- **Control plane (master)** – the *brain*. It decides what runs where but normally doesn't run your apps:
  - `kube-apiserver` – the front door; `kubectl` and every other component talk to it
  - `etcd` – a key-value database that stores the whole cluster state
  - `kube-scheduler` – picks a node for each new pod
  - `kube-controller-manager` – control loops that keep actual state = desired state (e.g. replica count)
  - `cloud-controller-manager` – talks to the cloud provider (load balancers, disks)
- **Worker node** – the *muscle*. It runs the application pods:
  - `kubelet` – an agent that starts the pods the API server assigns to it and reports their health
  - `kube-proxy` – network rules that make Services work
  - a **container runtime** – containerd or CRI-O

### How to tell if a node is master or worker
```bash
kubectl get nodes                       # ROLES column: control-plane (or master on old versions) vs worker / <none>
kubectl get nodes --show-labels         # label node-role.kubernetes.io/control-plane=
kubectl describe node <name> | grep -i taint   # control-plane often has NoSchedule taint
kubectl get pods -n kube-system -o wide # apiserver, etcd, scheduler, controller-manager pods run on the control-plane
```
In my minikube cluster, `minikube` shows **control-plane** and `minikube-m02` shows **worker**.
A worker's ROLES column is `<none>` by default, because the role is only a label; I added it with
`kubectl label node minikube-m02 node-role.kubernetes.io/worker=`.

**Distributions:**
- **kubeadm** – the "real" multi-node install
- **minikube** – local learning cluster; what I used, with the docker driver
- **k3s** – a lightweight single binary, good for edge or a VM
- **MicroK8s** – Canonical's snap package
- Managed clouds: EKS, AKS, GKE

## Git (version control)
Git keeps the full history of a project. Every clone is a complete copy, so it is *distributed*.
GitHub and GitLab host the shared copy (the *remote*) and add pull requests, issues and CI.

Areas: **working directory** → `git add` → **staging area** → `git commit` → **local repo**
→ `git push` → **remote**.

```bash
git init                         # start a repo        | git clone <url>       # copy an existing one
git status                       # what changed        | git diff               # line-by-line changes
git add <file> / git add .       # stage changes       | git commit -m "msg"    # save a snapshot
git log --oneline --graph        # history             | git show <commit>      # one commit
git branch / git switch -c feat  # list / create+switch branch
git merge feat                   # bring a branch in   | git rebase main        # replay commits on top of main
git remote add origin <url>      # link the remote     | git remote -v
git push -u origin main          # upload commits      | git pull               # download + merge (= fetch + merge)
git fetch                        # download without merging
git stash / git stash pop        # put work aside temporarily
git restore <file>               # discard local edits | git revert <commit>    # undo a commit with a new commit
git reset --soft HEAD~1          # undo last commit, keep changes staged
git tag v1.0                     # mark a release
```
`.gitignore` lists files that must never be committed (in this repo: private notes, `.vagrant/`, VM boxes).

## RAID (Redundant Array of Independent Disks)
RAID combines several disks into one so you get speed, safety, or both.

| Level | How | Min disks | Survives | Usable space | Notes |
|---|---|---|---|---|---|
| RAID 0 | Striping | 2 | **0** disk failures | 100% | Fastest, no protection |
| RAID 1 | Mirroring | 2 | 1 disk | 50% | Simple, good for OS disks |
| RAID 5 | Striping + 1 parity | 3 | 1 disk | (n-1)/n | Good balance; slow rebuild |
| RAID 6 | Striping + 2 parity | 4 | 2 disks | (n-2)/n | Safer for big disks |
| RAID 10 | Mirror, then stripe | 4 | 1 per mirror pair | 50% | Fast + safe, best for databases |

It can be done in hardware (a RAID controller card) or in software (Linux `mdadm`, ZFS, LVM).
**RAID is not a backup:** if you delete a file or ransomware encrypts it, the change is mirrored instantly.

## DevOps
DevOps is a way of working where **development** and **operations** share responsibility for software
all the way from code to production. The aim is to release small changes often, safely, and automatically.

Core practices:
- version control for everything
- **CI** – build and test on every push
- **CD** – automatic delivery/deployment
- **Infrastructure as Code** – Vagrantfile, Terraform, Ansible
- containers and orchestration
- monitoring and logging, with feedback loops

The loop: **plan → code → build → test → release → deploy → operate → monitor** → back to plan.

Typical tools:
- Git/GitHub/GitLab; Jenkins / GitLab CI / GitHub Actions
- Maven; Docker; Kubernetes
- Ansible/Puppet/Terraform
- Prometheus + Grafana, ELK

## High Availability (HA) and Disaster Recovery (DR)
- **HA** – keep the service running when *one part* fails, with little or no downtime, inside one site.
  Done with **redundancy** (no single point of failure) and **automatic failover**.
  Measured as uptime, e.g. 99.99% ≈ 52 minutes of downtime a year.
- **DR** – bring the service back after a *disaster* that takes out a whole site (fire, flood, region
  outage, ransomware), usually at a second site. Measured with:
  - **RPO** (Recovery Point Objective) – how much data you can afford to lose (e.g. the last 5 minutes)
  - **RTO** (Recovery Time Objective) – how long until the service is back (e.g. 1 hour)
- **Backups** sit under both: the 3-2-1 rule is 3 copies, on 2 kinds of media, 1 off-site.

Technologies:
| Product | HA (same site) | DR (other site) |
|---|---|---|
| **Oracle** | **RAC** – several servers share one database, so if one dies the others keep serving | **Data Guard** – a standby DB in another site kept in sync with redo logs (Active Data Guard = readable standby), plus **RMAN** backups, GoldenGate |
| **PostgreSQL** | Streaming replication + automatic failover with **Patroni** (with etcd) or repmgr; **PgBouncer** / HAProxy in front | Async replica in another region, **pgBackRest** / Barman backups with WAL archiving for point-in-time recovery |
| **Tomcat** | Several Tomcats behind a load balancer (Nginx / HAProxy / Apache `mod_jk`), **session replication** (DeltaManager cluster) or sticky sessions / sessions in Redis | Same stack deployed at a second site, DNS / global load balancer failover |
| General | Keepalived (VRRP floating IP), Pacemaker/Corosync, Kubernetes replicas, cloud availability zones | Storage replication, VM replication (VMware SRM), cloud multi-region |

## Cloud computing
Renting computing resources (servers, storage, databases, software) over the internet. You pay for what
you use and can scale up or down in minutes instead of buying hardware.

**Service models** – who manages what:
| | You manage | Provider manages | Examples |
|---|---|---|---|
| **IaaS** – Infrastructure | OS, runtime, app, data | Hardware, network, virtualization | AWS EC2, Azure VMs, Google Compute Engine |
| **PaaS** – Platform | Your app + data | Everything up to and including the runtime | AWS Elastic Beanstalk, Azure App Service, Heroku, Google App Engine, managed DBs (RDS) |
| **SaaS** – Software | Just use it (your data, users) | Everything | Gmail, Microsoft 365, Salesforce, Zoom |

The pizza analogy: IaaS = you get the kitchen, PaaS = pizza delivered and you set the table, SaaS =
eat at the restaurant.

**Deployment types:**
- **public** cloud – shared provider
- **private** cloud – one organization, e.g. OpenStack/VMware in your own datacenter
- **hybrid** – both, connected
- **multi-cloud** – several public providers

Banks and payment companies often use private/hybrid clouds because of
data-residency rules.

**Vendors:**
- **AWS** – the biggest
- **Microsoft Azure**
- **Google Cloud**
- **Oracle Cloud (OCI)**
- **IBM Cloud**, **Alibaba Cloud**
- smaller ones like DigitalOcean

## DNS
The **Domain Name System** is the internet's phone book: it turns names (`ps-app.local`, `google.com`)
into IP addresses.

**How a lookup works:**
1. Your PC first checks its own cache and the `hosts` file. That is how `ps-app.local` works in Part 3.
2. Then it asks a **recursive resolver** (your ISP, 8.8.8.8, 1.1.1.1).
3. The resolver asks a **root server** → the **TLD server** (`.com`) → the domain's **authoritative**
   server, which holds the answer.
4. The answer is cached for its **TTL**.

**Record types:**
- `A` (IPv4), `AAAA` (IPv6)
- `CNAME` (alias to another name)
- `MX` (mail server)
- `TXT` (verification, SPF)
- `NS` (which servers are authoritative)
- `PTR` (reverse: IP → name)
- `SOA`

Tools: `nslookup`, `dig`, `host`. DNS can also spread load (several A records) or fail over (health-checked DNS).

## Load balancers
A load balancer sits in front of several servers and spreads requests over them. If a server fails a
**health check**, it gets no more traffic. This gives scaling and HA. (In my Kubernetes test, the
Service split 6 requests 3/3 over two pods.)
- **Layer 4** (TCP/UDP) – routes by IP and port only; very fast. E.g. HAProxy in TCP mode, AWS NLB, LVS.
- **Layer 7** (HTTP) – looks at URL, host and headers/cookies; can do SSL termination, path routing and
  sticky sessions. E.g. Nginx, HAProxy HTTP mode, AWS ALB, F5.
- **Algorithms:** round robin, weighted round robin, least connections, IP hash (same client → same
  server), least response time.
- Hardware (F5 BIG-IP, Citrix ADC), software (HAProxy, Nginx, Envoy) or cloud (AWS ELB, Azure LB).
  The load balancer itself is made redundant with an active/passive pair and a floating IP (Keepalived/VRRP).
