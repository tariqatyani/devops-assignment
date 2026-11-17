# Tomcat 9 image with the sample WAR deployed.
# Build from the REPO ROOT so app/ is in the build context:
#   docker build -f docker/Dockerfile -t <dockerhub-user>/ps-tomcat:1.0 .

# ---- Stage 1: package app/sample-webapp into a WAR (a WAR is just a zip/jar) ----
FROM eclipse-temurin:17-jdk AS build
WORKDIR /src
COPY app/sample-webapp/ .
RUN jar -cvf /ps-app.war .

# ---- Stage 2: the runtime image ----
FROM tomcat:9.0-jre17-temurin
LABEL org.opencontainers.image.title="ps-tomcat" \
      org.opencontainers.image.description="Tomcat 9 with a sample WAR"
# Tomcat auto-deploys every WAR in webapps/: ps-app.war -> http://host:8080/ps-app/
COPY --from=build /ps-app.war /usr/local/tomcat/webapps/ps-app.war
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s \
  CMD curl -fs http://localhost:8080/ps-app/ >/dev/null || exit 1
CMD ["catalina.sh", "run"]
