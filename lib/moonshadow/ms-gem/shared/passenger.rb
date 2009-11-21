module Moonshadow::Manifest::Passenger
  # Install the passenger gem
  def passenger_gem
    configure(:passenger => {})
    package "passenger", :ensure => (configuration[:passenger][:version] || :latest), :provider => :gem
  end

  def passenger_nginx
    package "nginx", :ensure => :installed
      
    nginx_conf = {
      "prefix" => "/usr/local/nginx",
      "sbin-path" => "/usr/sbin/nginx",
      
      "conf-path" => "/etc/nginx/nginx.conf",
      "error-log-path" => "/var/log/nginx/error.log",
      "pid-path" => "/var/run/nginx.pid",
      "lock-path" => "/var/lock/nginx.lock",
      "http-log-path" => "/var/log/nginx/access.log",
      "user" => "www-data",
      "group" => "www-data",
      "http-client-body-temp-path" => "/var/lib/nginx/body",
      "http-proxy-temp-path" => "/var/lib/nginx/proxy",
      "http-fastcgi-temp-path" => "/var/lib/nginx/fastcgi",
      
      "with-http_stub_status_module" => true,
      "with-http_flv_module" => true,
      "with-http_ssl_module" => true,
      "with-http_dav_module" => true,
      "with-http_realip_module" => true,
      
      "without-mail_pop3_module" => true,
      "without-mail_imap_module" => true,
      "without-mail_smtp_module" => true,
    }
    
    nginx_flags = String.new
    nginx_conf.each do |k,v| 
      nginx_flags << " --"
      nginx_flags << "#{k}" if v == true
      nginx_flags << "#{k}=#{v}" if v.class == String
    end

    nginx_build_cmd = <<-CMD
    printf "\\n\\n" | passenger-install-nginx-module --prefix #{nginx_conf["prefix"]} \
    --auto-download --extra-configure-flags="#{nginx_flags.lstrip}"
    CMD
    # puts nginx_build_cmd
    
    exec "build_nginx", :command => nginx_build_cmd, :creates => nginx_conf["sbin-path"]

    # Call system()
    host_cpus = %x[cat "/proc/cpuinfo" | grep "processor" | wc -l]
    host_speed = %x[cat "/proc/cpuinfo" | grep -i "cpu MHz" | sed -e "s/.*\: //g"]
    passenger_root = %x[cat "#{nginx_conf['conf-path']}" | grep "passenger_root"]
    passenger_ruby = %x[cat "#{nginx_conf['conf-path']}" | grep "passenger_ruby"]
    keepalive_timeout = 5
    
    file nginx_conf['conf-path'],
      :ensure => :present,
      :content => template(File.join(File.dirname(__FILE__), 'templates', 'nginx.conf.erb')),
      :require => [exec("build_nginx")],
      :notify => service("nginx"),
    
    file nginx_flags["prefix"], :ensure => :absent, :recurse => true
    
    service "nginx", ensure => running, enable => true
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

  def passenger_config_boolean(key)
    if key.nil?
      nil
    elsif key == 'Off' || (!!key) == false
      'Off'
    else
      'On'
    end
  end

end