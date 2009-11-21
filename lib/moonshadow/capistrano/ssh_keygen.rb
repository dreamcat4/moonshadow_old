##Run using cap SSH###

set(:remoteHost) do
 Capistrano::CLI.ui.ask "Hostname or IP address of remote server: "
end

# set(:ms_user) do
#  Capistrano::CLI.ui.ask "Username for SSH: "
# end
set :ms_user, "dreamcat4"

# set :hosts, ["#{admin_user}@#{remoteHost}"]
set :hosts, ["ubuntu910server"]

ssh_options[:keys] = %w(~/.ssh/id_dsa ~/.ssh/id_rsa)

# puts ssh_rb.inspect
puts cmd_args.inspect
# puts somehash.inspect
puts cmd_opts.inspect

# require File.expand_path("./hosts.rb")
require File.expand_path(File.join(File.dirname(__FILE__), "../config/hosts.rb"))
puts read_hosts_file().inspect

namespace :SSH do
   
   task :default do
      keygen
      # add_ms_user
      # write_known_hosts
      # write_ssh_config
   end
   
   # ssh config
   # Host php-fpm.org
   #   Hostname clients.mikehost.net
   #   User php-fpm
   #   IdentityFile ~/.ssh/php-fpm_rsa
   # 
   # Host *.debian.org
   #         UserKnownHostsFile ~/.ssh/debian_known_hosts

   # *Capturing output with run
   # run "sudo ls -la" do |channel, stream, data|
   #   if data =~ /^Password:/
   #     logger.info "#{channel[:host]} asked for password"
   #     channel.send_data "mypass\n"
   #   end
   # end

   # Hash of additional options passed to the SSH connection routine.
   # This lets you set (among other things) a non-standard port to connect on:
   # (ssh_options[:port] = 2345)
   # :ssh_options Hash.new  

   desc "Check for existance of a public key, otherwise generate it. Then trigger sendFile"
   task :keygen do
      if !File.exist?(File.expand_path("~/.ssh/#{ms_user}_rsa.pub"))
        passphrase = ""
        system "ssh-keygen -t rsa -N \"#{passphrase}\" -C #{ms_user} -f ~/.ssh/#{ms_user}_rsa"
      end
   end

   # desc "Send the id_rsa.pub file from the local machine to the remote machine's home dir, then trigger checkDirectory"
   desc "Create Moonshadow user \"#{ms_user}\" and add the #{ms_user}_rsa.pub file to its authorized_keys"
   # task :add_ms_user do
   # task :add_ms_user, :hosts => hosts do
   # 
   #    system "scp ~/.ssh/id_rsa.pub #{ms_user}@#{remoteHost}:~/id_rsa.pub"
   #    # upload("../my_dir", "#{shared_path}/my_dir", :via => :scp, :recursive => true)
   #    # upload(”LOCAL_DIR_PATH”, “REMOTE_PATH”, :via=> :scp, :recursive => true)
   #    # download(”REMOTE_PATH”, “LOCAL_DIR_PATH”, :via=> :scp, :recursive => true)
   # 
   #    # upload(”LOCAL_DIR_PATH”, “REMOTE_PATH”, :via=> :scp)
   #    
   #    # cat ~/.ssh/dreamcat4_rsa.pub | ssh #{ms_user}@#{remoteHost} 'mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys'
   #    net ssh
   #    
   #    sudo "chown -R #{ms_user}:#{ms_user} ~/.ssh"
   #    run "chmod 700 ~/.ssh"
   #    run "chmod 600 ~/.ssh/authorized_keys"
   #    
   #    Net::SSH.start(host, user) do |ssh|
   #      # ssh.exec! "cp /some/file /another/location"
   #      # hostname = ssh.exec!("hostname")
   #      
   #      ssh.open_channel do |ch|
   #        ch.exec "sudo -p 'sudo password: ' ls" do |ch, success|
   #          abort "could not execute sudo ls" unless success
   #    
   #          ch.on_data do |ch, data|
   #            print data
   #            if data =~ /sudo password: /
   #              ch.send_data("password\n")
   #            end
   #          end
   #        end
   #      end
   #      ssh.loop
   #    end
   # 
   # end

   desc "set the correct premissions on the .ssh dir and the authorized_keys file"
   task :setPermissions, :hosts => hosts do
     run "pwd"
     run "ls -lsa"
      # sudo "chown -R #{ms_user}:#{ms_user} ~/.ssh"
      # run "chmod 700 ~/.ssh"
      # run "chmod 600 ~/.ssh/authorized_keys"
   end
   
   # desc "Send the id_rsa.pub file from the local machine to the remote machine's home dir, then trigger checkDirectory"
   # task :sendFile do
   #    system "scp ~/.ssh/id_rsa.pub #{ms_user}@#{remoteHost}:~/id_rsa.pub"
   # end
   
   # desc "Check for existance of .ssh directory. If true, goes to checkFile, if false goto createDirectories"
   # task :checkDirectory, :hosts => "#{ms_user}@#{remoteHost}" do
   #    begin
   #       run "ls -a ~/.ssh"
   #    rescue Exception
   #        createDirectories
   #    else
   #        checkFile
   #    end
   #    
   # end
   
   # desc "Check for existance of .ssh/authorized_keys, goto createKeys if false, goto appendKeys if true"
   # task :checkFile, :hosts => "#{ms_user}@#{remoteHost}" do
   #    begin
   #       run "ls -a ~/.ssh/authorized_keys"
   #    rescue Exception
   #        createKeys
   #    else
   #       appendKeys
   #    end
   # end
   
   # desc "Append the new key to the already existing public key file"
   # task :appendKeys, :hosts => "#{ms_user}@#{remoteHost}" do
   #    run "cat ~/id_rsa.pub >> ~/.ssh/authorized_keys"
   #    run "rm ~/id_rsa.pub"
   # end
   
   # desc "Create the .ssh directory, trigger createKeys"
   # task :createDirectories, :hosts => "#{ms_user}@#{remoteHost}" do
   #    run "mkdir ~/.ssh/"
   #    createKeys
   # end
   
   # desc "Move the new ky into the authorized_keys file because it doesn't exist, triggers setPermissions"
   # task :createKeys, :hosts => "#{ms_user}@#{remoteHost}" do
   #    run "mv ~/id_rsa.pub ~/.ssh/authorized_keys"
   # end
   
   # desc "set the correct premissions on the .ssh dir and the authorized_keys file"
   # task :setPermissions, :hosts => "#{ms_user}@#{remoteHost}" do
   #    sudo "chown -R #{ms_user}:#{ms_user} ~/.ssh"
   #    run "chmod 700 ~/.ssh"
   #    run "chmod 600 ~/.ssh/authorized_keys"
   # end
end   

