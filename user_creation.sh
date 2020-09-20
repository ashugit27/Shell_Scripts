#!/bin/bash

if [[ "${UID}" -ne 0 ]]
then
   echo 'Please run with sudo or as root.'
   exit 1
fi

read -p 'Enter the username to create: ' USER_NAME

read -p 'Enter the name of the person or application that will be using this account: ' COMMENT
 
read -p 'Enter the password to use for the account: ' -s PASSWORD

useradd -c "${COMMENT}" -m ${USER_NAME}

if [[ "${?}" -ne 0 ]]
then
  echo 'The account could not be created.'
  exit 1
fi

echo ${PASSWORD} | passwd --stdin ${USER_NAME}

if [[ "${?}" -ne 0 ]]
then
  echo 'The password for the account could not be set.'
  exit 1
fi

passwd -e ${USER_NAME}

echo
echo 'username:'
echo "${USER_NAME}"
echo
echo
echo 'host:'
echo "${HOSTNAME}"
exit 0
