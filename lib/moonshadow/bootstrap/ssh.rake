#!/bin/bash

USER="moonshine"
SRV="$1"
ORIG_USER="$2"
HASH=`cat /etc/shadow | grep $ORIG_USER | sed -e "s/^$ORIG_USER://" -e "s/:.*//"`

ADD=useradd -d /home/$USER -m -U $USER -p $HASH; \
usermod -a -s /bin/bash -G admin $USER; \
echo "$USER ALL=NOPASSWD: ALL" >> /etc/sudoers;


REMOVE="
deluser --remove-all-files $USER
"

ssh $ORIG_USER@$SRV sudo su -c "$ADD"

cat ~/.ssh/id_rsa.pub | ssh $ORIG_USER@$SRV "mkdir /home/$USER/.ssh; cat >> /home/$USER/.ssh/authorized_keys"
ssh $ORIG_USER@$SRV "chown -R $USER:$USER /home/$USER/.ssh"
ssh $ORIG_USER@$SRV "chmod 700 /home/$USER/.ssh"
ssh $ORIG_USER@$SRV "chmod 600 /home/$USER/.ssh/authorized_keys"


namespace :ssh do
  desc "Add ssh user"
  task :add_user do
	# require 'rubygems'
	require 'net/ssh'

	HOST = '192.168.1.113'
	USER = 'username'
	PASS = 'password'

	Net::SSH.start( HOST, USER, :password => PASS ) do|ssh|
	  output = ssh.exec!('ls')
	  puts output
	end

  end
end

rake ssh:add_user username=dreamcat4 password=p

