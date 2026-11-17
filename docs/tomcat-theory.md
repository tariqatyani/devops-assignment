# Tomcat – theory notes (in my own words)

## 1. What is the JVM?
The **Java Virtual Machine** is a program that runs Java programs. The Java compiler (`javac`) doesn't
make code for a real CPU. It makes **bytecode** (`.class` files), and the JVM runs that bytecode on
whatever machine it is installed on. That is why Java is "write once, run anywhere": the same `.jar`
runs on Windows, Linux or macOS, as long as there is a JVM.

What the JVM does for you:
- **Class loader** – loads `.class` files when they are needed.
- **Execution engine** – interprets bytecode, and the **JIT compiler** turns hot code into fast native code.
- **Memory management** – objects live on the **heap**, and the **garbage collector** frees objects nobody
  uses any more, so there's no manual `free()`. Heap size is set with `-Xms` (start) and `-Xmx` (max),
  e.g. `CATALINA_OPTS=-Xmx512m` in my Tomcat service.
- **Stack per thread** – local variables and method calls.

Related terms:
- **JRE** = JVM + standard libraries (enough to *run* Java).
- **JDK** = JRE + tools such as `javac` and `jar` (needed to *build*; I used `jar` to package the WAR).

## 2. What is an application server?
A web server like Nginx is good at serving files and passing requests along. An **application server**
*runs your application code* and gives it ready-made services, so developers only write business logic.
Those services include:
- receiving HTTP requests and handing them to the right code (servlets/JSP)
- managing threads, sessions and cookies
- database connection pools (JNDI data sources)
- security (login/roles), logging, deploying and undeploying apps

Examples:
- **Apache Tomcat** – strictly a *servlet container* / web container: the web part of Java EE only.
- **Full Java EE / Jakarta EE servers** – WildFly/JBoss, Oracle WebLogic, IBM WebSphere, Payara. These add
  EJB, JMS messaging and distributed transactions.

The usual setup is **Nginx/Apache in front** (port 80/443, SSL, static files, load balancing) →
**Tomcat behind it** (runs the Java code) → **database**. That is exactly the Part 3 setup.

## 3. What is a WAR file, how does Tomcat handle it, and where is it deployed?
A **WAR** (Web Application aRchive) is a ZIP file with a fixed layout that holds a whole Java web app:
```
ps-app.war
├── index.jsp, css/, images/      <- public content
├── META-INF/MANIFEST.MF
└── WEB-INF/                      <- private, the browser can't fetch it
    ├── web.xml                   <- deployment descriptor (servlets, URL mappings, welcome page)
    ├── classes/                  <- compiled .class files of the app
    └── lib/                      <- .jar libraries the app needs
```
I built mine with `jar -cf ps-app.war .` inside `app/sample-webapp` (Maven's `mvn package` does the same
in real projects).

**Where to deploy:** copy it into `$CATALINA_HOME/webapps/`, e.g. `/opt/tomcat/webapps/ps-app.war`.
Other ways:
- the **Manager app** (`/manager/html`) upload page
- a context XML file in `conf/Catalina/localhost/`
- CI/CD tools that copy the file for you

**What Tomcat does with it** (when `autoDeploy`/`deployOnStartup` are on, which is the default in `server.xml`):
1. The *HostConfig* checks `webapps/` and sees a new `ps-app.war`.
2. It **unpacks** it into a folder `webapps/ps-app/` (`unpackWARs="true"`).
3. It creates a **context** whose path is the file name: `ps-app.war` → `http://host:port/ps-app/`.
   `ROOT.war` is special and maps to `/`.
4. It reads `WEB-INF/web.xml`, loads the classes with a separate class loader per app, and starts it.
   The log says `Deployment of web application archive [...ps-app.war] has finished`.
5. Replacing the WAR **redeploys** the app, and deleting it **undeploys** it.

JSP pages are turned into servlets (Java code) and compiled the first time they are requested. The
generated code lives under `work/`.

## Practice notes (Part 3)
- **Port change:** `conf/server.xml` → `<Connector port="7070" protocol="HTTP/1.1" .../>`, then restart Tomcat.
- **Reverse proxy:** Nginx listens on 80 for `server_name ps-app.local` and does
  `proxy_pass http://127.0.0.1:7070`. The DNS name comes from `/etc/hosts` (on the VM, and on the
  Windows host in `C:\Windows\System32\drivers\etc\hosts`). In a company it would be a DNS A record.
- **Java 8 + Tomcat 9:** Tomcat 9 needs Java 8 or newer. Tomcat 10+ moved from `javax.*` to `jakarta.*`,
  so old apps stay on Tomcat 9.
