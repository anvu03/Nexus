#!/bin/bash
echo "Installing mssql-tools"

# Detect architecture and install appropriate sqlcmd
ARCH=$(uname -m)
if [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then
    echo "Detected ARM64 architecture, installing go-sqlcmd"
    curl -L https://github.com/microsoft/go-sqlcmd/releases/latest/download/sqlcmd-linux-arm64.tar.bz2 -o /tmp/sqlcmd.tar.bz2
    tar -xjf /tmp/sqlcmd.tar.bz2 -C /usr/local/bin
    chmod +x /usr/local/bin/sqlcmd
    rm /tmp/sqlcmd.tar.bz2
else
    echo "Detected x86_64 architecture, installing mssql-tools18"
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc | (OUT=$(apt-key add - 2>&1) || echo $OUT)
    DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
    CODENAME=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-${DISTRO}-${CODENAME}-prod ${CODENAME} main" > /etc/apt/sources.list.d/microsoft.list
    apt-get update
    ACCEPT_EULA=Y apt-get -y install unixodbc-dev msodbcsql18 libunwind8 mssql-tools18
    
    # Add mssql-tools to PATH
    echo 'export PATH="$PATH:/opt/mssql-tools18/bin"' >> /etc/bash.bashrc
fi

echo "Installing sqlpackage"
curl -sSL -o sqlpackage.zip "https://aka.ms/sqlpackage-linux"
mkdir /opt/sqlpackage
unzip sqlpackage.zip -d /opt/sqlpackage 
rm sqlpackage.zip
chmod a+x /opt/sqlpackage/sqlpackage
