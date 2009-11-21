
class Moonshadow::Manifest::Recipies < Moonshadow::Manifest

  configure(:apt_gems => YAML.load_file(File.join(File.dirname(__FILE__), 'recipies', 'apt_gems.yml')))

  Dir.glob(File.join(File.dirname(__FILE__), 'recipies', '*.rb')).each do |recipies_file|
    require recipies_file
    eval "include Moonshadow::Manifest::#{File.basename(recipies_file,'.rb')}"
  end

  # A super recipe for installing Apache, Passenger, a database, 
  # Rails, NTP, Cron, Postfix. To customize your stack, call the
  # individual recipes you want to include rather than default_stack.
  #
  # The database installed is based on the adapter in database.yml.
  def apache_stack
    self.class.recipe :apache_server
    self.class.recipe :passenger_gem, :passenger_configure_gem_path, :passenger_apache_module, :passenger_site
    case database_environment[:adapter]
    when 'mysql'
      self.class.recipe :mysql_server, :mysql_gem, :mysql_database, :mysql_user, :mysql_fixup_debian_start
    when 'postgresql'
      self.class.recipe :postgresql_server, :postgresql_gem, :postgresql_user, :postgresql_database
    when 'sqlite' || 'sqlite3'
      self.class.recipe :sqlite3
    end
    self.class.recipe :rails_rake_environment, :rails_gems, :rails_directories, :db_bootstrap, :rails_migrations, :rails_logrotate
    self.class.recipe :ntp, :time_zone, :postfix, :cron_packages, :motd, :security_updates
  end

  def nginx_stack
    # self.class.recipe :apache_server
    self.class.recipe :passenger_gem, :passenger_configure_gem_path
    # self.class.recipe :passenger_apache_module, :passenger_site
    self.class.recipe :passenger_nginx
    self.class.recipe :nginx_config

    case database_environment[:adapter]
    when 'mysql'
      self.class.recipe :mysql_server, :mysql_gem, :mysql_database, :mysql_user, :mysql_fixup_debian_start
    when 'postgresql'
      self.class.recipe :postgresql_server, :postgresql_gem, :postgresql_user, :postgresql_database
    when 'sqlite' || 'sqlite3'
      self.class.recipe :sqlite3
    end
    self.class.recipe :rails_rake_environment, :rails_gems, :rails_directories, :db_bootstrap, :rails_migrations, :rails_logrotate
    self.class.recipe :ntp, :time_zone, :postfix, :cron_packages, :motd, :security_updates
  end

end
