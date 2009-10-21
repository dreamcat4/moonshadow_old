Capistrano::Configuration.instance(:must_exist).load do

  set :branch, 'master'
  set :scm, :git
  set :git_enable_submodules, 1
  ssh_options[:paranoid] = false
  ssh_options[:forward_agent] = true
  default_run_options[:pty] = true
  set :keep_releases, 2

  after 'deploy:restart', 'deploy:cleanup'

  #load the moonshadow configuration into
  require 'yaml'

  puts Dir.pwd
  # hash = YAML.load_file(File.join((ENV['RAILS_ROOT'] || Dir.pwd), 'config', 'moonshadow.yml'))
  # hash = YAML.load_file(File.join(Dir.pwd, 'config', 'moonshadow.yml'))
  # ac = YAML.load_file(File.join(Dir.pwd, '.msconfig'))
  # uc = YAML.load_file(File.expand_path('~/.msconfig'))
  ac = uc = {}
  # merge with userland ~/.msconfig
  c = uc.merge ac
  c.each do |key, value|
    set(key.to_sym, value)
  end

  # set :scm, :svn if !! repository =~ /^svn/

  namespace :moonshadow do

    desc <<-DESC
    Bootstrap a barebones Ubuntu system with Git, Ruby, RubyGems, and Moonshadow
    dependencies. Called by deploy:setup.
    DESC
    task :bootstrap do
      ruby.install
      ensure_installed
      setup_directories
    end

    task :setup_directories do
      begin
        config = YAML.load_file(File.join(Dir.pwd, 'config', 'moonshadow.yml'))
        put(YAML.dump(config),"/tmp/moonshadow.yml")
      rescue Exception => e
        puts e
        puts "Please make sure the settings in moonshadow.yml are valid and that the target hostname is correct."
        exit(0)
      end
      put(File.read(File.join(File.dirname(__FILE__), '..', 'moonshadow_setup_manifest.rb')),"/tmp/moonshadow_setup_manifest.rb")
      sudo "shadow_puppet /tmp/moonshadow_setup_manifest.rb"
      sudo 'rm /tmp/moonshadow_setup_manifest.rb'
      sudo 'rm /tmp/moonshadow.yml'
    end

    task :ensure_installed do
      begin
        run "ruby -e 'require \"rubygems\"; gem \"moonshadow\", \"= #{Gem.loaded_specs["moonshadow"].version}\"' 2> /dev/null"
      rescue
        sudo "gem install moonshadow -v #{Gem.loaded_specs["moonshadow"].version}"
      end
    end

    desc 'Apply the Moonshadow manifest for this application'
    task :apply do
      on_rollback do
        run "cd #{latest_release} && RAILS_ENV=#{fetch(:rails_env, 'production')} rake --trace environment"
      end
      ensure_installed
      sudo "RAILS_ROOT=#{latest_release} DEPLOY_STAGE=#{ENV['DEPLOY_STAGE']||fetch(:stage,'undefined')} "+
      "RAILS_ENV=#{fetch(:rails_env, 'production')} "+
      "shadow_puppet #{latest_release}/app/manifests/#{fetch(:moonshadow_manifest, 'application_manifest')}.rb"
      sudo "touch /var/log/moonshadow_rake.log && cat /var/log/moonshadow_rake.log"
    end

    desc "Update code and then run a console. Useful for debugging deployment."
    task :update_and_console do
      set :moonshadow_apply, false
      deploy.update_code
      app.console
    end

    desc "Update code and then run 'rake environment'. Useful for debugging deployment."
    task :update_and_rake do
      set :moonshadow_apply, false
      deploy.update_code
      run "cd #{latest_release} && RAILS_ENV=#{fetch(:rails_env, 'production')} rake --trace environment"
    end

    after 'deploy:finalize_update' do
      local_config.upload
      local_config.symlink
      app.symlinks.update
    end

    before 'deploy:symlink' do
      apply if fetch(:moonshadow_apply, true) == true
    end

  end

  namespace :app do

    namespace :symlinks do

      desc <<-DESC
      Link public directories to shared location.
      DESC
      task :update, :roles => [:app, :web] do
        fetch(:app_symlinks, []).each { |link| run "ln -nfs #{shared_path}/public/#{link} #{latest_release}/public/#{link}" }
      end

    end

    desc "remotely console"
    task :console, :roles => :app, :except => {:no_symlink => true} do
      input = ''
      run "cd #{current_path} && ./script/console #{fetch(:rails_env, "production")}" do |channel, stream, data|
        next if data.chomp == input.chomp || data.chomp == ''
        print data
        channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
      end
    end

    desc "Show requests per second"
    task :rps, :roles => :app, :except => {:no_symlink => true} do
      count = 0
      last = Time.now
      run "tail -f #{shared_path}/log/#{fetch(:rails_env, "production")}.log" do |ch, stream, out|
        break if stream == :err
        count += 1 if out =~ /^Completed in/
        if Time.now - last >= 1
          puts "#{ch[:host]}: %2d Requests / Second" % count
          count = 0
          last = Time.now
        end
      end
    end

    # desc "tail application log file"
    # task :log, :roles => :app, :except => {:no_symlink => true} do
    #   run "tail -f #{shared_path}/log/#{fetch(:rails_env, "production")}.log" do |channel, stream, data|
    #     puts "#{data}"
    #     break if stream == :err
    #   end
    # end

    desc "tail vmstat"
    task :vmstat, :roles => [:web, :db] do
      run "vmstat 5" do |channel, stream, data|
        puts "[#{channel[:host]}]"
        puts data.gsub(/\s+/, "\t")
        break if stream == :err
      end
    end

  end

  namespace :local_config do

    desc <<-DESC
    Uploads local configuration files to the application's shared directory for
    later symlinking (if necessary). Called if local_config is set.
    DESC
    task :upload do
      fetch(:local_config,[]).each do |file|
        filename = File.split(file).last
        if File.exist?( file )
          put(File.read( file ),"#{shared_path}/config/#{filename}")
        end
      end
    end
  
    desc <<-DESC
    Symlinks uploaded local configurations into the release directory.
    DESC
    task :symlink do
      fetch(:local_config,[]).each do |file|
        filename = File.split(file).last
        run "ls #{latest_release}/#{file} 2> /dev/null || ln -nfs #{shared_path}/config/#{filename} #{latest_release}/#{file}"
      end
    end
  
  end

  namespace :deploy do
    desc "Restart the Passenger processes on the app server by touching tmp/restart.txt."
    task :restart, :roles => :app, :except => { :no_release => true } do
      run "touch #{current_path}/tmp/restart.txt"
    end

    [:start, :stop].each do |t|
      desc "#{t} task is a no-op with Passenger"
      task t, :roles => :app do ; end
    end

    desc <<-DESC
      Prepares one or more servers for deployment. Before you can use any \
      of the Capistrano deployment tasks with your project, you will need to \
      make sure all of your servers have been prepared with `cap deploy:setup'. When \
      you add a new server to your cluster, you can easily run the setup task \
      on just that server by specifying the HOSTS environment variable:
 
        $ cap HOSTS=new.server.com deploy:setup
 
      It is safe to run this task on servers that have already been set up; it \
      will not destroy any deployed revisions or data.
    DESC
    task :setup, :except => { :no_release => true } do
      moonshadow.bootstrap
      vcs.install
    end
  end

  namespace :ruby do
    desc "Forces a reinstall of Ruby and restarts Apache/Passenger"
    task :upgrade do
      set :force_ruby, 'true'
      install
      apache.restart
    end

    desc "Install Ruby + Rubygems"
    task :install do
      put(File.read(File.join(File.dirname(__FILE__), 'bootstrap', "bootstrap.#{fetch(:ruby, 'ree')}.sh")),"/tmp/bootstrap.sh")
      sudo 'chmod a+x /tmp/bootstrap.sh'
      sudo "FORCE_RUBY=#{fetch(:force_ruby,'false')} /tmp/bootstrap.sh"
      sudo 'rm /tmp/bootstrap.sh'
    end
  end

  namespace :apache do
    desc "Restarts the Apache web server"
    task :restart do
      sudo 'service apache2 restart'
    end
  end


  # CONFIGURATION
  # -------------
  #   set :scm, :git
  #
  # Set <tt>:repository</tt> to the path of your Git repo:
  #
  #   set :repository, "someuser@somehost:/home/myproject"
  #
  # The above two options are required to be set, the ones below are
  # optional.
  #
  # You may set <tt>:branch</tt>, which is the reference to the branch, tag, 
  # or any SHA1 you are deploying, for example:
  # 
  #   set :branch, "origin/master"
  #
  # Otherwise, HEAD is assumed.  I strongly suggest you set this.  HEAD is
  # not always the best assumption.
  #
  # The <tt>:scm_command</tt> configuration variable, if specified, will
  # be used as the full path to the git executable on the *remote* machine:
  #
  #   set :scm_command, "/opt/local/bin/git"
  #
  # For compatibility with deploy scripts that may have used the 1.x
  # version of this plugin before upgrading, <tt>:git</tt> is still
  # recognized as an alias for :scm_command.
  #
  # Set <tt>:scm_password</tt> to the password needed to clone your repo
  # if you don't have password-less (public key) entry:
  #
  #   set :scm_password, "my_secret'
  #
  # Otherwise, you will be prompted for a password.
  #
  # <tt>:scm_passphrase</tt> is also supported.

  # # My config/deploy.rb file:
  # set :application, "myapp"
  # set :repository,  "ssh://myserver/git/app.git"
  # set :deploy_to, "/home/mihai/apps/#{application}"
  # set :scm, "git"
  # ssh_options[:paranoid] = false
  # set :domain, "myserver.net"
  # role :app, domain
  # role :web, domain
  # role :db, domain, :primary => true
  # default_run_options[:pty] = true
  # set :user, "mihai"
  # set :runner, "mihai"
  # set :use_sudo, false
  # set :deploy_via, :remote_cache
  # set :mongrel_port, "3001"
  
  
  # fn determine vcs system. git or bzr
  # install the relevant vcs
  
  # # set the branch to publish or error out
  # if fetch(:scm).to_s == "git"
  #   set(:repository, system("git config --get remote.origin.url")) unless fetch(:repository)
  # elsif fetch(:scm).to_s == "bzr"
  #   set(:checkout, (fetch(:branch)||"trunk"))
  # end

  namespace :vcs do
    desc "Installs the scm"
    task :install do
      package = case fetch(:scm).to_s
        # when 'svn' then 'subversion'
        when 'git' then 'git-core'
        when 'bzr' then 'bzr'
        else scm.to_s
      end
      sudo "apt-get -qq -y install #{package}"
    end
  end

end