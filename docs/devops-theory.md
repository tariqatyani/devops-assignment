# DevOps notes

Notes for the DevOps reading questions: Docker, Kubernetes, Git and the key concepts.

## What Docker is, use cases and basic commands

Docker packages an application together with everything it needs (runtime, libraries and settings) into an image, and runs that image as a container. Containers share the Linux kernel of the host, so they start in seconds and use much less memory than VMs. Each container is isolated using kernel features: namespaces (its own processes, network and files) and cgroups (CPU and memory limits).

| | Virtual machine | Container |
|---|---|---|
| Contains | A full OS with its own kernel | The app and its libraries only |
| Size and start time | GBs, minutes | MBs, seconds |
| Isolation | Strong (hypervisor) | Process level (shared kernel) |

Main terms:

- **Dockerfile:** the instructions to build an image.
- **Image:** a read-only template built in layers.
- **Container:** a running instance of an image.
- **Registry:** where images are stored, such as Docker Hub.
- **Volume:** data that stays when the container is removed.

Use cases: the same image runs the same way in development, testing and production, microservices, CI/CD pipelines, and quick test environments (I ran Oracle, PostgreSQL and Nginx in minutes for this assignment).

Basic commands:

```bash
docker build -t user/app:1.0 .           # build an image
docker images                            # list images
docker run -d --name web -p 8080:80 nginx   # run a container in the background
docker ps        /  docker ps -a         # running / all containers
docker logs -f web                       # container output
docker exec -it web sh                   # open a shell inside a container
docker stop web  /  docker start web  /  docker rm web
docker pull nginx  /  docker push user/app:1.0
docker login
docker compose up -d                     # start several containers from a compose file
```

## What is Kubernetes?

Kubernetes is a container orchestrator. You describe what you want in a YAML file, for example "2 copies of this image, reachable on port 80", and Kubernetes keeps it that way. It decides which node runs each pod, restarts containers that crash, replaces pods if a node goes down, scales up and down, and does rolling updates.

Main objects:

- **Pod:** the smallest unit, one or more containers sharing an IP.
- **Deployment:** keeps a number of identical pods running and handles updates.
- **Service:** a stable address that load balances over the pods (ClusterIP, NodePort or LoadBalancer).
- **Ingress:** HTTP routing by host name or path.
- **ConfigMap and Secret:** settings and passwords.
- **Namespace:** a separate group of objects in the same cluster.

## Master and worker nodes, and how to identify them

The **master (control plane)** manages the cluster and decides what runs where. Its components are:

- `kube-apiserver`: the entry point that `kubectl` and all other parts talk to
- `etcd`: the database that stores the state of the whole cluster
- `kube-scheduler`: chooses a node for each new pod
- `kube-controller-manager`: keeps the real state equal to the wanted state, for example the number of replicas

A **worker node** runs the application pods. Its components are:

- `kubelet`: starts the pods assigned to the node and reports their health
- `kube-proxy`: network rules that make Services work
- a container runtime such as containerd

**How to identify them:**

```bash
kubectl get nodes                                    # ROLES column: control-plane or worker
kubectl get nodes --show-labels                      # label node-role.kubernetes.io/control-plane
kubectl describe node <name> | grep -i taint         # the control plane usually has a NoSchedule taint
kubectl get pods -n kube-system -o wide              # etcd, apiserver and scheduler run on the control plane
```

In my cluster, `minikube` shows `control-plane` and `minikube-m02` shows `worker`. A worker shows `<none>` in the ROLES column by default, because the role is only a label, so I added it with `kubectl label node minikube-m02 node-role.kubernetes.io/worker=`.

## Common Git commands

| Command | What it does |
|---|---|
| `git init` / `git clone <url>` | Start a new repository / copy an existing one |
| `git status` / `git diff` | See what changed |
| `git add <file>` | Stage changes for the next commit |
| `git commit -m "message"` | Save a snapshot |
| `git log --oneline` | Show the history |
| `git branch` / `git switch -c <name>` | List branches / create and switch to a branch |
| `git merge <branch>` | Merge a branch into the current one |
| `git remote -v` | Show the remote repository |
| `git push` | Upload commits |
| `git pull` | Download and merge changes (fetch + merge) |
| `git fetch` | Download without merging |
| `git stash` | Put changes aside for later |
| `git revert <commit>` | Undo a commit with a new commit |

Areas in Git: working directory, then `git add` to the staging area, then `git commit` to the local repository, then `git push` to the remote.

## RAID

RAID combines several disks into one, for speed, protection or both.

| Level | How it works | Min. disks | Disk failures it survives | Usable space |
|---|---|---|---|---|
| RAID 0 | Striping | 2 | None | 100% |
| RAID 1 | Mirroring | 2 | 1 | 50% |
| RAID 5 | Striping with parity | 3 | 1 | (n-1)/n |
| RAID 6 | Striping with double parity | 4 | 2 | (n-2)/n |
| RAID 10 | Mirrors, then striping | 4 | 1 per mirror pair | 50% |

RAID 10 is common for databases because it is fast and safe. RAID can be hardware (a RAID controller) or software (`mdadm` on Linux). RAID is not a backup: if a file is deleted or encrypted by ransomware, the change is copied to all disks right away.

## DevOps

DevOps is a way of working where the development and operations teams share responsibility for the software, from writing the code to running it in production. The goal is to release small changes often, safely and automatically.

The main practices are version control, continuous integration (build and test on every push), continuous delivery, infrastructure as code (Vagrant, Terraform, Ansible), containers, and monitoring. The cycle is plan, code, build, test, release, deploy, operate and monitor, and then back to plan.

Common tools: Git, Jenkins, GitLab CI or GitHub Actions, Maven, Docker, Kubernetes, Ansible, Terraform, and Prometheus with Grafana.

## High Availability (HA) and Disaster Recovery (DR)

**HA** keeps the service running when one part fails, with little or no downtime. It works through redundancy (no single point of failure) and automatic failover, and it is measured as uptime: 99.99% is about 52 minutes of downtime per year.

**DR** brings the service back after a disaster that takes down a whole site, usually by moving to a second site. It is measured with two numbers:

- RPO (Recovery Point Objective): how much data you can afford to lose
- RTO (Recovery Time Objective): how long it takes to get the service back

Backups support both. The 3-2-1 rule means 3 copies, on 2 types of media, with 1 copy off site.

| Product | HA | DR |
|---|---|---|
| Oracle | RAC: several servers share one database, so if one fails the others keep working | Data Guard: a standby database at another site, kept in sync with the redo logs. Also RMAN backups and GoldenGate |
| PostgreSQL | Streaming replication with automatic failover (Patroni or repmgr), with PgBouncer or HAProxy in front | A replica at another site, and pgBackRest or Barman backups with WAL archiving for point-in-time recovery |
| Tomcat | Several Tomcat servers behind a load balancer (Nginx, HAProxy or Apache mod_jk), with session replication or sticky sessions | The same setup at a second site, with DNS or global load balancer failover |
| General | Keepalived (floating IP), Pacemaker, Kubernetes replicas | Storage and VM replication, multiple cloud regions |

## Cloud computing

Cloud computing means renting servers, storage, databases and software over the internet, paying for what you use, and scaling up or down in minutes.

| Model | I manage | The provider manages | Examples |
|---|---|---|---|
| IaaS (Infrastructure as a Service) | OS, runtime, application and data | Hardware, network and virtualization | AWS EC2, Azure Virtual Machines, Google Compute Engine |
| PaaS (Platform as a Service) | Application and data | Everything up to the runtime | AWS Elastic Beanstalk, Azure App Service, Heroku, AWS RDS |
| SaaS (Software as a Service) | Only my data and users | Everything | Gmail, Microsoft 365, Salesforce, Zoom |

**Deployment types:** public cloud (shared provider), private cloud (one organization, for example OpenStack or VMware in its own data center), hybrid (both connected), and multi-cloud (more than one public provider). Banks and payment companies often use private or hybrid clouds because of data residency rules.

**Vendors:** AWS, Microsoft Azure, Google Cloud, Oracle Cloud (OCI), IBM Cloud, Alibaba Cloud, and smaller ones such as DigitalOcean.

## DNS and load balancers

**DNS** translates names into IP addresses. When you open a name, the computer first checks its cache and the hosts file (this is how `ps-app.local` worked in the Tomcat part). Then it asks a recursive resolver (for example 8.8.8.8), which asks a root server, then the TLD server (`.com`), then the domain's authoritative server. The answer is cached for the record's TTL.

Common record types: `A` (IPv4), `AAAA` (IPv6), `CNAME` (alias), `MX` (mail), `TXT`, `NS` and `PTR` (reverse lookup). Useful tools are `nslookup` and `dig`.

**A load balancer** sits in front of several servers and spreads the requests between them. If a server fails its health check, it stops receiving traffic, which gives both scaling and HA.

- **Layer 4** works on IP and port only, so it is very fast (HAProxy in TCP mode, AWS NLB).
- **Layer 7** works on HTTP: it can route by URL or host, terminate SSL and use sticky sessions (Nginx, HAProxy in HTTP mode, AWS ALB, F5).
- **Algorithms:** round robin, weighted round robin, least connections and IP hash.

The load balancer itself is usually set up as an active/passive pair with a floating IP (Keepalived). In my Kubernetes test, the Service did the same job by spreading the requests over the two pods.
