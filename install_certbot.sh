#!/bin/bash
##################################################
#
#   Author  : Viki ( @ ) Vignesh Natarajan
#   Contact : vikiworks.io
#
##################################################

########## COMMON_CODE_BEGIN()   ########
CMD=""
CLEAN=0

ARG0=$0
ARG1=$1
ARG2=$2
ARG3=$3

os_support_check(){
    OS_SUPPORTED=0

    #Check Ubuntu 18.04 Support    
    cat /etc/lsb-release | grep 18.04 2> /dev/null 1> /dev/null
    if [ $? -eq 0 ]; then
        OS_SUPPORTED=1
    fi

    #Check Ubuntu 16.04 Support    
    cat /etc/lsb-release | grep 18.04 2> /dev/null 1> /dev/null
    if [ $? -eq 0 ]; then
        OS_SUPPORTED=1
    fi

    if [ $OS_SUPPORTED -eq 0 ]; then
	echo
	echo "Utility is not supported in this version of linux"
	echo
	exit 1
    fi

}


get_command(){
    if [ "$ARG0" == "sudo" ]; then
        CMD="$ARG1"
    else
        CMD="$ARG0"
    fi

    if [ "$ARG1" = "clean" ]; then
	CLEAN=1
    fi

    if [ "$ARG2" = "clean" ]; then
	CLEAN=1
    fi

    if [ "$ARG3" = "clean" ]; then
	CLEAN=1
    fi

}

check_permission(){
    touch /bin/test.txt 2> /dev/null 1>/dev/null

    if [ $? -ne 0 ]; then
	echo "permission error, try to run this script wih sudo option"; 
	echo ""
	echo "Example: sudo $CMD"
	echo ""
	exit 1; 
    fi 
    
    rm /bin/test.txt
}

check_utility(){
	which $1 2> /dev/null  1> /dev/null
	if [ $? -eq 0 ]; then
		echo
		echo "[ status ] $1 already installed"
		echo ""
		echo "For clean install try,"
		echo
		echo "$CMD clean"
		echo
		echo "(or)"
		echo
	        echo "sudo $CMD clean"
		echo ""
		exit 0
	fi
}

init_bash_installer(){
    os_support_check
    get_command
    check_permission
}
########## COMMON_CODE_END()   ########


update_repo(){
    apt-get update 
}

clean_certbot(){
    if [ $CLEAN -eq 1 ]; then
	apt-get purge certbot -y
        apt autoremove -y
	snap remove certbot
    fi
}

install_curl(){
    which curl 2> /dev/null  1> /dev/null
    if [ $? -ne 0 ]; then
        apt-get install curl
    fi
}

install_snapd(){
    apt install -y snapd
    #[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
}

install_certbot(){
	#Install Certbot
	snap install core; 
    	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
       	snap refresh core
    	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
	snap install --classic certbot
    	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }

	unlink /usr/bin/certbot 2>/dev/null 1>/dev/null

	ln -s /snap/bin/certbot /usr/bin/certbot
    	[ $? -ne 0 ] && { echo "error line ( ${LINENO} )"; exit 1; }
}

init_bash_installer
clean_certbot
check_utility "certbot"
update_repo
install_snapd
install_curl
install_certbot


