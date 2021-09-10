#!/bin/bash -e
# Basic script to manage XE database options
# set -x

############
#  Function to echo usage
############
usage (){
	program=`basename $0`
cat << EOF
	Usage: ${program} [-o start|stop] [-h]
	Options: -o start or -o stop will start or stop the Xe database and listener
EOF
	exit 1
}

###########################################
#  Function to change database environments
###########################################
set_env ()
{

   REC=`grep "^${1}" /etc/oratab | grep -v "^#"`
   if test -z $REC
   then
	 echo "Database NOT in ${v_oratab}"
	 exit 1

   else
	 echo "Database in ${v_oratab} - setting environment"
	 export ORAENV_ASK=NO
	 export ORACLE_SID=${1}
	 . oraenv >> /dev/null
	 export ORAENV_ASK=YES
   fi

}

####################################
#  setup_parameters Function 
####################################
setup_parameters ()
{

  ## This function will set the Oracle Environment to XE using “oraenv” - see set_env function
  ## it will then update the listener.ora and tnsnames.ora to use the docker container hostname 
  ## which will allow you to start the listener and do remote connections.
  ##
  set_env XE
  TNS_ADMIN=${ORACLE_HOME}/network/admin
  EDITOR=vi
  NLS_DATE_FORMAT="dd/mm/yyyy:hh24:mi:ss"

  if [ -e ${TNS_ADMIN}/listener.ora ]; then
	sed -i -e "s/^.*HOST.*/\ \ \ \ \ \ \ (ADDRESS = (PROTOCOL = TCP)(HOST = $HOSTNAME)(PORT = 1521))/" ${TNS_ADMIN}/listener.ora
  fi

  if [ -e ${TNS_ADMIN}/tnsnames.ora ]; then
	sed -i -e "s/^.*HOST.*/\ \ \ \ \ \ \ (ADDRESS = (PROTOCOL = TCP)(HOST = $HOSTNAME)(PORT = 1521))/" ${TNS_ADMIN}/tnsnames.ora
  fi

  ## Echo back the hostname and IP. - this is just informational 
  ##
  echo $HOSTNAME - $(echo $(ip addr show dev eth0 | sed -nr 's/.*inet ([^ ]+).*/\1/p') | cut -f 1 -d '/')
}

####################################
#  enableDBExpress Function 
####################################
enableDBExpress ()
{

## This is needed to allow DBExpress, we set the environment to XE then run the updates
##
set_env XE
sqlplus / as sysdba << EOF
  exec dbms_xdb_config.setlistenerlocalaccess(false);
  exec dbms_xdb_config.setglobalportenabled(true);
  exit
EOF
}


###################
###################
## Main Section
###################
###################

## We check for input parameters if not we display usage, if we get the expected arguments example
## -o start we continue

if test $# -lt 2
then
  usage
fi

## Get all input values
while test $# -gt 0
do
   case ${1} in
   -o)
		   shift
		   v_option=${1}
		   ;;
   -h)
		   usage
		   ;;
   *)      usage
		   ;;
   esac
   shift
done

## Call function to update listener and tnsnames
setup_parameters
##
# execute what is needed, start or stop the XE database
# when starting the XE database we will continue to tail the alert log 
#

case ${v_option} in
"start")
		  sudo /etc/init.d/oracle-xe-18c start
		  enableDBExpress
		  tail -F -n 0 /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
		  ;;
"stop")

		  sudo /etc/init.d/oracle-xe-18c stop
		  tail -50 /opt/oracle/diag/rdbms/xe/XE/trace/alert_XE.log
		  ;;
esac 