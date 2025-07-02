#!/bin/bash

# Update the system
sudo apt update

# Install JDK 17
sudo apt install openjdk-17-jdk -y

# Install other necessary utilities
sudo apt install git wget unzip -y
sudo apt install awscli -y

# Download Tomcat 9
TOMURL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.62/bin/apache-tomcat-9.0.62.tar.gz"
cd /tmp/
wget $TOMURL -O tomcatbin.tar.gz

# Extract the downloaded file
EXTOUT=`tar xzvf tomcatbin.tar.gz`
TOMDIR=`echo $EXTOUT | cut -d '/' -f1`

# Add tomcat user
useradd --shell /sbin/nologin tomcat

# Install Tomcat to the correct directory
rsync -avzh /tmp/$TOMDIR/ /usr/local/tomcat9/

# Clean up default Tomcat configuration files
rm -rf /usr/local/tomcat9/conf/tomcat-users.xml
rm -rf /usr/local/tomcat9/webapps/manager/META-INF/context.xml

# Create new configuration files
touch /usr/local/tomcat9/webapps/manager/META-INF/context.xml
touch /usr/local/tomcat9/conf/tomcat-users.xml

# Add necessary roles and users to tomcat-users.xml
cat <<EOT>> /usr/local/tomcat9/conf/tomcat-users.xml
<?xml version="1.0" encoding="UTF-8"?>
<tomcat-users xmlns="http://tomcat.apache.org/xml"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
version="1.0">
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="tomcat" password="admin123" roles="manager-gui,manager-script"/>
</tomcat-users>
EOT

# Add configuration to context.xml
cat <<EOT>> /usr/local/tomcat9/webapps/manager/META-INF/context.xml
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
</Context>
EOT

# Change ownership to tomcat user
chown -R tomcat.tomcat /usr/local/tomcat9

# Create a setenv.sh file to configure JVM arguments
cat <<EOT>> /usr/local/tomcat9/bin/setenv.sh
#!/bin/bash
# Set JVM options (adjust values as needed)
export CATALINA_OPTS="-Xms512m -Xmx1024m -Dmyproperty=value"
EOT

# Make the setenv.sh file executable
chmod +x /usr/local/tomcat9/bin/setenv.sh

# Create a systemd service for Tomcat
cat <<EOT>> /etc/systemd/system/tomcat.service
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat9
Environment=CATALINA_HOME=/usr/local/tomcat9
Environment=CATALINA_BASE=/usr/local/tomcat9
ExecStart=/usr/local/tomcat9/bin/catalina.sh run
ExecStop=/usr/local/tomcat9/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOT

# Reload systemd to recognize the new service
systemctl daemon-reload

# Start and enable Tomcat to run on boot
systemctl start tomcat
systemctl enable tomcat
