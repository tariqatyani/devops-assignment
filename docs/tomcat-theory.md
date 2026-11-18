# Tomcat notes

Answers to the three Tomcat questions.

## What is the JVM?

The JVM (Java Virtual Machine) is the program that runs Java code. When Java code is compiled, the result is not machine code for a real CPU. It is bytecode (`.class` files), and the JVM runs that bytecode on whatever system it is installed on. That is why the same Java program runs on Windows, Linux or macOS.

The JVM also loads classes when they are needed, compiles frequently used code to native code (JIT), and manages memory. Objects live on the heap, and the garbage collector removes objects that are no longer used. The heap size is set with `-Xms` and `-Xmx`; for example, I gave Tomcat `-Xmx512m`.

The JRE is the JVM plus the standard libraries, which is enough to run Java. The JDK adds the tools to build Java, such as `javac` and `jar`.

## What is an application server?

A web server like Nginx is good at serving files and passing requests on. An application server actually runs the application code and gives it ready services: it receives the HTTP requests and passes them to the right code (servlets and JSP), and it manages threads, sessions, database connection pools, security and deployments. This way developers only write the business logic.

Tomcat is a servlet container, which means it covers the web part of Java EE. Full Java EE (Jakarta EE) servers such as WildFly/JBoss, WebLogic and WebSphere also include EJB, JMS and distributed transactions.

A common setup is Nginx in front (port 80/443, SSL, static files, load balancing), Tomcat behind it running the Java code, and a database behind Tomcat. That is the setup I built in the practice tasks.

## What is a WAR file, how Tomcat handles it, and where to deploy it

A WAR (Web Application Archive) is a zip file with a fixed structure that holds a whole Java web application:

```
ps-app.war
  index.jsp, css/, images/     public files
  META-INF/MANIFEST.MF
  WEB-INF/                     private, the browser cannot open it
    web.xml                    deployment descriptor
    classes/                   compiled Java classes
    lib/                       libraries (.jar files)
```

**Where to deploy it:** copy it into Tomcat's `webapps` folder, for example `/opt/tomcat/webapps/ps-app.war`. It can also be uploaded through the Tomcat Manager app.

**How Tomcat handles it:** when Tomcat sees a new WAR in `webapps`, it unpacks it into a folder with the same name (`webapps/ps-app/`). The file name becomes the URL path, so `ps-app.war` is served at `http://server:port/ps-app/` (`ROOT.war` is served at `/`). Tomcat then reads `web.xml`, loads the classes and starts the app. Replacing the WAR redeploys the app, and deleting it removes the app.
