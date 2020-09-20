#!/bin/bash

if [[ "${UID}" -ne 0 ]]
then
   echo 'Please run with sudo or as root.' >&2
   exit 1
fi

if [[ "${#}" -lt 1 ]]
then
  echo "Usage: ${0} USER_NAME [COMMENT]..." >&2
  echo 'Create an account on the local system with the name of USER_NAME and a comments field of COMMENT.' >&2
  exit 1
fi

USER_NAME="${1}"

shift
COMMENT="${@}"

PASSWORD=$(date +%s%N | sha256sum | head -c48)

useradd -c "${COMMENT}" -m ${USER_NAME} &> /dev/null

if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.' >&2
  exit 1
fi

echo ${PASSWORD} | passwd --stdin ${USER_NAME} &> /dev/null

if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.' >&2
  exit 1
fi

passwd -e ${USER_NAME}

echo 'username:'
echo "${USER_NAME}"
echo
echo "${PASSWORD}"
echo 'host:'
echo "${HOSTNAME}"
exit 0
