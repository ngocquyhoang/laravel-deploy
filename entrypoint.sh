#!/bin/bash

SSH_USER=$1
SSH_HOST=$2
SSH_PORT=$3
PATH_SOURCE=$4
OWNER=$5

mkdir -p /root/.ssh
ssh-keyscan -H "$SSH_HOST" >> /root/.ssh/known_hosts

if [ -z "$DEPLOY_KEY" ];
then
	echo $'\n' "------ DEPLOY KEY NOT SET YET! ----------------" $'\n'
	exit 1
else
	printf '%b\n' "$DEPLOY_KEY" > /root/.ssh/id_rsa
	chmod 400 /root/.ssh/id_rsa

	echo $'\n' "------ CONFIG SUCCESSFUL! ---------------------" $'\n'
fi

if [ ! -z "$SSH_PORT" ];
then
        printf "Host %b\n\tPort %b\n" "$SSH_HOST" "$SSH_PORT" > /root/.ssh/config
	ssh-keyscan -p $SSH_PORT -H "$SSH_HOST" >> /root/.ssh/known_hosts
fi

rsync --progress -azh \
	--exclude='.git/' \
	--exclude='.git*' \
	--exclude='.editorconfig' \
	--exclude='.styleci.yml' \
	--exclude='.idea/' \
	--exclude='Dockerfile' \
	--exclude='readme.md' \
	--exclude='README.md' \
	-e "ssh -i /root/.ssh/id_rsa" \
	$SSH_USER@$SSH_HOST:$PATH_SOURCE

if [ $? -eq 0 ]
then
	echo $'\n' "------ SYNC SUCCESSFUL! -----------------------" $'\n'
	echo $'\n' "------ RELOADING PERMISSION -------------------" $'\n'

	ssh -i /root/.ssh/id_rsa -t $SSH_USER@$SSH_HOST "sudo chown -R $OWNER:$OWNER $PATH_SOURCE"
	ssh -i /root/.ssh/id_rsa -t $SSH_USER@$SSH_HOST "sudo chmod 775 -R $PATH_SOURCE"
	ssh -i /root/.ssh/id_rsa -t $SSH_USER@$SSH_HOST "sudo chmod 777 -R $PATH_SOURCE/storage"
	ssh -i /root/.ssh/id_rsa -t $SSH_USER@$SSH_HOST "sudo chmod 777 -R $PATH_SOURCE/public"
	ssh -i /root/.ssh/id_rsa -t $SSH_USER@$SSH_HOST "cd $PATH_SOURCE && php artisan migrate"

	echo $'\n' "------ CONGRATS! DEPLOY SUCCESSFUL!!! ---------" $'\n'
	exit 0
else
	echo $'\n' "------ DEPLOY FAILED! -------------------------" $'\n'
	exit 1
fi
