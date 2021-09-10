FROM oraclelinux:7-slim

USER root

RUN groupadd -g 501 oinstall \
	&& groupadd -g 502 dba \
	&& groupadd -g 503 oper \
	&& useradd -m -g oinstall -G oinstall,dba,oper -u 501 oracle \
	&& echo 'oracle:ORADBXE18c' | chpasswd



RUN rpm --rebuilddb \
	&& yum -y install file openssl lsof sudo sysstat tree wget which  \
	&& yum clean all \
	&& rm -rf /var/cache/yum/*


RUN echo "oracle ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers \
	&& echo "Defaults !requiretty"  >> /etc/sudoers \
	&& mkdir -p /opt/oracle \
	&& mkdir -p /install \
	&& mkdir -p /home/oracle/bin \
	&& chown -R oracle:oinstall /opt/oracle \
	&& chown -R oracle:oinstall /home/oracle/bin


COPY software/oracle-database-preinstall-18c.rpm /install
COPY software/oracle-database-xe-18c.rpm /install/
ENV ORACLE_DOCKER_INSTALL=true
RUN cd /install \
	&& yum -y localinstall oracle-database-*18c*  \
	&& yum clean all \
	&& rm -rf /var/cache/yum/* \
	&& rm -rf /install/oracle*.rpm


# EXPOSE 5500
EXPOSE 1521 

RUN sed -i -e "s/^.*memlock.*//g" /etc/security/limits.d/oracle-database-preinstall-18c.conf \
 && printf ORADBXE18c\\nORADBXE18c\\n  | /etc/init.d/oracle-xe-18c configure


COPY scripts/manage-xe.sh /home/oracle/bin
RUN chown oracle:oinstall /home/oracle/bin/manage-xe.sh \
	&& chmod 775 /home/oracle/bin/manage-xe.sh

USER oracle
WORKDIR /home/oracle


ENV ORACLE_DOCKER_INSTALL=true \
		ORACLE_BASE=/opt/oracle \
		ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE \
		PATH=/home/oracle/bin:/opt/oracle/product/18c/dbhomeXE/bin:$PATH \
		NLS_DATE_FORMAT="dd/mm/yyyy:hh24:mi:ss" \
		ORACLE_SID=XE


RUN history -c

## 
#  The last instruction is to specify what will be executed when the container is created 
#  from the image.  There are a few options, you could just start a bash shell and then 
#  manually start the Oracle 18c XE database, or, you could call the custom manage-xe.sh
#  script with the “start” parameter to start the listener and XE database on container 
#  creation (run time)
#
# CMD ["/bin/bash”]
#
CMD ["/home/oracle/bin/manage-xe.sh", "-o", "start"]