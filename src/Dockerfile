# Use Tomcat 9 as base image
FROM tomcat:9.0

# Copy your built WAR into Tomcat’s webapps folder
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

# Start Tomcat
CMD ["catalina.sh", "run"]