module Moonshine::Manifest::Rails::Passenger
  # Install the passenger gem
  def nginx_server
    # configure(:nginx => {})
    # package "nginx", :ensure => :installed
    
    # # Patch the init file for our custom nginx build
    # exec "patch_nginx_init",
    #   :command => "patch ... #{nginx_path} --auto-download",
    #   :creates => "#{nginx_path}/sbin/nginx"
    #   :logoutput => true
    
    service "nginx", :require => [package("nginx"), exec("build_nginx"), file("nginx_conf")], 
                     :restart => '/etc/init.d/nginx restart', :ensure => :running

    if configuration[:nginx][:ssl]
      # a2enmod('headers')
      # a2enmod('ssl')
    end

    file '/etc/apache2/mods-available/status.conf',
      :ensure => :present,
      :mode => '644',
      :require => exec('a2enmod status'),
      :content => status,
    file '/etc/logrotate.d/varlogapachelog.conf', :ensure => :absent

    service "nginx", ensure => running, enable => true
  end
  
  def nginx_server
    nginx_restart, :require => [package("nginx"), exec("build_nginx"), file("nginx_conf")]
  end
  
  # Build, install, and enable the passenger apache module. Please see the
  # <tt>passenger.conf.erb</tt> template for passenger configuration options.
  def passenger_apache_module
    # Install Apache2 developer library
    package "apache2-threaded-dev", :ensure => :installed

    file "/usr/local/src", :ensure => :directory

    exec "symlink_passenger",
      :command => 'ln -nfs `passenger-config --root` /usr/local/src/passenger',
      :unless => 'ls -al /usr/local/src/passenger | grep `passenger-config --root`',
      :require => [
        package("passenger"),
        file("/usr/local/src")
      ]

    # Build Passenger from source
    exec "build_passenger",
      :cwd => configuration[:passenger][:path],
      :command => '/usr/bin/ruby -S rake clean apache2',
      :unless => "ls `passenger-config --root`/ext/apache2/mod_passenger.so",
      :require => [
        package("passenger"),
        package("apache2-mpm-worker"),
        package("apache2-threaded-dev"),
        exec('symlink_passenger')
      ]

    load_template = "LoadModule passenger_module #{configuration[:passenger][:path]}/ext/apache2/mod_passenger.so"

    file '/etc/apache2/mods-available/passenger.load',
      :ensure => :present,
      :content => load_template,
      :require => [exec("build_passenger")],
      :notify => service("apache2"),
      :alias => "passenger_load"

    file '/etc/apache2/mods-available/passenger.conf',
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'passenger.conf.erb')),
      :require => [exec("build_passenger")],
      :notify => service("apache2"),
      :alias => "passenger_conf"

    a2enmod 'passenger', :require => [exec("build_passenger"), file("passenger_conf"), file("passenger_load")]
  end

  # Creates and enables a vhost configuration named after your application.
  # Also ensures that the <tt>000-default</tt> vhost is disabled.
  def passenger_site
    file "/etc/apache2/sites-available/#{configuration[:application]}",
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'passenger.vhost.erb')),
      :notify => service("apache2"),
      :alias => "passenger_vhost",
      :require => exec("a2enmod passenger")

    a2dissite '000-default', :require => file("passenger_vhost")
    a2ensite configuration[:application], :require => file("passenger_vhost")
  end

  def passenger_configure_gem_path
    configure(:passenger => {})
    return configuration[:passenger][:path] if configuration[:passenger][:path]
    version = begin
      configuration[:passenger][:version] || Gem::SourceIndex.from_installed_gems.find_name("passenger").last.version.to_s
    rescue
      `gem install passenger --no-ri --no-rdoc`
      `passenger-config --version`.chomp
    end
    configure(:passenger => { :path => "#{Gem.dir}/gems/passenger-#{version}" })
  end

  private

    # Symlinks a site from <tt>/etc/apache2/sites-enabled/site</tt> to
    #<tt>/etc/apache2/sites-available/site</tt>. Creates
    #<tt>exec("a2ensite #{site}")</tt>.
    def a2ensite(site, options = {})
      exec("a2ensite #{site}", {
          :command => "/usr/sbin/a2ensite #{site}",
          :unless => "ls /etc/apache2/sites-enabled/#{site}",
          :require => package("apache2-mpm-worker"),
          :notify => service("apache2")
        }.merge(options)
      )
    end

    # Removes a symlink from <tt>/etc/apache2/sites-enabled/site</tt> to
    #<tt>/etc/apache2/sites-available/site</tt>. Creates
    #<tt>exec("a2dissite #{site}")</tt>.
    def a2dissite(site, options = {})
      exec("a2dissite #{site}", {
          :command => "/usr/sbin/a2dissite #{site}",
          :onlyif => "ls /etc/apache2/sites-enabled/#{site}",
          :require => package("apache2-mpm-worker"),
          :notify => service("apache2")
        }.merge(options)
      )
    end

    # Symlinks a module from <tt>/etc/apache2/mods-enabled/mod</tt> to
    #<tt>/etc/apache2/mods-available/mod</tt>. Creates
    #<tt>exec("a2enmod #{mod}")</tt>.
    def a2enmod(mod, options = {})
      exec("a2enmod #{mod}", {
          :command => "/usr/sbin/a2enmod #{mod}",
          :unless => "ls /etc/apache2/mods-enabled/#{mod}.load",
          :require => package("apache2-mpm-worker"),
          :notify => service("apache2")
        }.merge(options)
      )
    end

    # Removes a symlink from <tt>/etc/apache2/mods-enabled/mod</tt> to
    #<tt>/etc/apache2/mods-available/mod</tt>. Creates
    #<tt>exec("a2dismod #{mod}")</tt>.
    def a2dismod(mod, options = {})
      exec("a2dismod #{mod}", {
          :command => "/usr/sbin/a2enmod #{mod}",
          :onlyif => "ls /etc/apache2/mods-enabled/#{mod}.load",
          :require => package("apache2-mpm-worker"),
          :notify => service("apache2")
        }.merge(options)
      )
    end



end