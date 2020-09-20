#!/bin/bash

ARCHIVE_DIR=/archive

usage(){
	echo   "Usage: ${0} -dra [USER] [ARGUMENTS]" >&2
	echo   'This system is used to deleting/disabling or archiving the users'
	echo   '-d        To delete the user' >&2 
	echo   '-r        To delete the user home directory' >&2
	echo   '-a        To archive the user home directory' >&2
	exit 1
}

if [[ "${UID}" -ne 0 ]]
then
	echo 'Use sudo or run this script via root account'
	exit 1
fi 

while getopts dra OPTION
do
	case ${OPTION} in
	        d) USER_DELETION='true' ;;
		r) USER_HOME_DELETION='-r' ;;
		a) USER_HOME_ARCHIVE='true' ;;
		?) usage ;;
	esac
done

shift "$(( OPTIND - 1 ))"

if [[ "${#}" -lt 1 ]]
then
	usage
fi


for USERNAME in "${@}"
do
	echo "Processing for requested user: ${USERNAME}"


	USER_ID=$(id -u ${USERNAME})
	if [[ "${USER_ID}" -lt 1000 ]]
	then
		echo "Sorry, we cannot process with user ${USERNAME}" >&2
		exit 1
	fi

	if [[ "${USER_HOME_ARCHIVE}" = 'true' ]] 
	then
		if [[ ! -d "${ARCHIVE_DIR}" ]]
		then
			echo "Creating ${ARCHIVE_DIR} directory"
			mkdir -p ${ARCHIVE_DIR}
		if [[ "${?}" -ne 0 ]]
		then
			echo 'Sorry, archive directory cannot be created.' >&2
			exit 1
		fi
	fi

	HOME_DIR="/home/${USERNAME}"
	ARCHIVE_FILE="${ARCHIVE_DIR}/${USERNAME}.tgz"
	if [[ -d "${HOME_DIR}" ]]
	then
		echo "Archiving ${HOME_DIR} into ${ARCHIVE_FILE}"
		tar -zcf ${ARCHIVE_FILE} ${HOME_DIR} &> /dev/null
		if [[ "${?}" -ne 0 ]]
		then
			echo "Sorry, we're unable to create the archive ${ARCHIVE_FILE}" >&2 
			exit 1
		fi
	else
		echo "${HOME_DIR} does not exist" >&2
		exit 1 
	fi
fi 


	if [[ "${USER_DELETION}" = 'true' ]]
	then
	userdel ${USER_HOME_DELETION} ${USERNAME}
	if [[ "${?}" -ne 0 ]]
	then 
		echo "Sorry, the account ${USERNAME} is not deleted" >&2
		exit 1
	fi
	echo "The account ${USERNAME} is successfully deleted"
else
	chage -E 0 ${USERNAME}
	if [[ "${?}" -ne 0 ]]
	then
		echo "Sorry, the account with username ${USERNAME} is not disabled." >&2
		exit 1
	fi 
	echo "The account ${USERNAME} is successfully disabled." 
fi
done

exit 0

