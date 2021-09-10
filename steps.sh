#!/bin/bash

ORA_PASSWORD = "ORADBXE18c"

docker pull oracle-linux:7-slim
docker run -it oraclelinux:7-slim bash
# curl -o oracle-database-preinstall-18c.rpm https://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/getPackage/oracle-database-preinstall-18c-1.0-1.el7.x86_64.rpm
# yum -y localinstall oracle-database-preinstall-18c.x86_64.rpm 
# curl -o oracle-database-xe-18c https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-xe-18c-1.0-1.x86_64.rpm
# yum -y localinstall oracle-database-xe-18c.rpm > /xe_logs/XEsilentinstall.log 2>&1
# $ sudo -s
# /etc/init.d/oracle-xe-18c configure
#(echo $ORA_PASSWD; echo ORA_PASSWD;) | /etc/init.d/oracle-xe-18c configure >> /xe_logs/XEsilentinstall.log 2>&1

export ORACLE_SID=XE
export ORAENV_ASK=NO

. /opt/oracle/product/18c/dbhomeXE/bin/oraenv

# systemctl start oracle-xe-18c
# systemctl stop oracle-xe-18c
# systemctl restart oracle-xe-18c
