#!/usr/bin/env bash
# provision.sh - runs as root inside the Ubuntu 24.04 VM (called by the Vagrantfile).
# Installs Java 8 + Apache Tomcat 9 on port 7070, deploys a sample WAR, and puts
# Nginx on port 80 in front of it as a reverse proxy for the DNS name ps-app.local.
# Safe to run more than once.
set -euo pipefail

TOMCAT_VERSION="${TOMCAT_VERSION:-9.0.124}"
TOMCAT_PORT=7070
APP_NAME="ps-app"
DNS_NAME="ps-app.local"
CATALINA_HOME=/opt/tomcat
JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export DEBIAN_FRONTEND=noninteractive

log() { echo; echo "==> $*"; }

log "1. Java 8 (OpenJDK 8 is still in Ubuntu 24.04 universe), Nginx, curl"
apt-get update -qq
apt-get install -y -qq --no-install-recommends openjdk-8-jdk-headless nginx curl ca-certificates >/dev/null
"$JAVA_HOME/bin/java" -version 2>&1 | head -1

log "2. Apache Tomcat $TOMCAT_VERSION (Ubuntu 24.04 has no tomcat9 package -> official tarball)"
id tomcat >/dev/null 2>&1 || useradd --system --home-dir "$CATALINA_HOME" --shell /usr/sbin/nologin tomcat
if [ ! -x "/opt/apache-tomcat-$TOMCAT_VERSION/bin/catalina.sh" ]; then
  tgz="apache-tomcat-$TOMCAT_VERSION.tar.gz"
  cd /tmp
  # dlcdn only keeps the newest release; archive.apache.org keeps all of them
  for base in "https://dlcdn.apache.org/tomcat/tomcat-9/v$TOMCAT_VERSION/bin" \
              "https://archive.apache.org/dist/tomcat/tomcat-9/v$TOMCAT_VERSION/bin"; do
    if curl -fsSLO "$base/$tgz" && curl -fsSLO "$base/$tgz.sha512"; then break; fi
  done
  sha512sum -c "$tgz.sha512"                     # stop if the download is corrupted / tampered
  tar -xzf "$tgz" -C /opt
  rm -f "$tgz" "$tgz.sha512"
  # remove the demo apps that should not be on a server
  rm -rf "/opt/apache-tomcat-$TOMCAT_VERSION/webapps/"{docs,examples}
fi
ln -sfn "/opt/apache-tomcat-$TOMCAT_VERSION" "$CATALINA_HOME"
chown -R tomcat:tomcat "/opt/apache-tomcat-$TOMCAT_VERSION"

log "3. Change the Tomcat HTTP port 8080 -> $TOMCAT_PORT (conf/server.xml)"
sed -i -E "s/<Connector port=\"[0-9]+\" protocol=\"HTTP\/1.1\"/<Connector port=\"$TOMCAT_PORT\" protocol=\"HTTP\/1.1\"/" \
  "$CATALINA_HOME/conf/server.xml"
grep -n "Connector port=\"$TOMCAT_PORT\"" "$CATALINA_HOME/conf/server.xml"

log "4. systemd service for Tomcat"
cat > /etc/systemd/system/tomcat.service <<UNIT
[Unit]
Description=Apache Tomcat $TOMCAT_VERSION
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat
Environment=JAVA_HOME=$JAVA_HOME
Environment=CATALINA_HOME=$CATALINA_HOME
Environment=CATALINA_BASE=$CATALINA_HOME
Environment=CATALINA_PID=$CATALINA_HOME/temp/tomcat.pid
Environment="CATALINA_OPTS=-Xms256m -Xmx512m"
ExecStart=$CATALINA_HOME/bin/startup.sh
ExecStop=$CATALINA_HOME/bin/shutdown.sh
PIDFile=$CATALINA_HOME/temp/tomcat.pid
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable tomcat >/dev/null 2>&1
systemctl restart tomcat

log "5. Build the sample WAR from /opt/ps-src and deploy it (Tomcat auto-deploys webapps/*.war)"
war=/tmp/$APP_NAME.war
if [ -d /opt/ps-src/sample-webapp ]; then
  (cd /opt/ps-src/sample-webapp && "$JAVA_HOME/bin/jar" -cf "$war" .)
else
  # fallback if the synced folder is missing: Apache's own sample WAR
  curl -fsSL -o "$war" https://tomcat.apache.org/tomcat-9.0-doc/appdev/sample/sample.war
fi
install -o tomcat -g tomcat -m 0644 "$war" "$CATALINA_HOME/webapps/$APP_NAME.war"

log "6. Nginx reverse proxy: http://$DNS_NAME:80 -> http://127.0.0.1:$TOMCAT_PORT"
cat > /etc/nginx/sites-available/$APP_NAME <<NGINX
server {
    listen 80;
    server_name $DNS_NAME;

    access_log /var/log/nginx/$APP_NAME.access.log;
    error_log  /var/log/nginx/$APP_NAME.error.log;

    location / {
        proxy_pass         http://127.0.0.1:$TOMCAT_PORT;
        proxy_set_header   Host              \$host;
        proxy_set_header   X-Real-IP         \$remote_addr;
        proxy_set_header   X-Forwarded-For   \$proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto \$scheme;
    }
}
NGINX
ln -sfn /etc/nginx/sites-available/$APP_NAME /etc/nginx/sites-enabled/$APP_NAME
rm -f /etc/nginx/sites-enabled/default
nginx -t
systemctl enable nginx >/dev/null 2>&1
systemctl reload-or-restart nginx

log "7. DNS name inside the VM (/etc/hosts)"
grep -q " $DNS_NAME\$" /etc/hosts || echo "127.0.0.1 $DNS_NAME" >> /etc/hosts
getent hosts "$DNS_NAME"

log "8. Checks"
for i in $(seq 1 60); do
  curl -fs "http://127.0.0.1:$TOMCAT_PORT/$APP_NAME/" >/dev/null && break
  sleep 2
done
echo "Tomcat  : $(systemctl is-active tomcat), listening on $TOMCAT_PORT"
echo "Nginx   : $(systemctl is-active nginx), listening on 80"
echo "Direct  : $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:$TOMCAT_PORT/$APP_NAME/)  http://127.0.0.1:$TOMCAT_PORT/$APP_NAME/"
echo "Via DNS : $(curl -s -o /dev/null -w '%{http_code}' http://$DNS_NAME/$APP_NAME/)  http://$DNS_NAME/$APP_NAME/"
echo
echo "From the host: http://localhost:9090/$APP_NAME/  (port forward 9090 -> 7070)"
echo "               http://$DNS_NAME/$APP_NAME/  (after adding '192.168.56.10 $DNS_NAME' to the hosts file)"
