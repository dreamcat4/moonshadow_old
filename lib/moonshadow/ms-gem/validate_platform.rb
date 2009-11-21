#The Rails Manifest includes recipes for Apache, Mysql, Sqlite3 and Rails
#running on Ubuntu 8.04 or greater.
class ValidatePlatform < Moonshadow::Manifest
  def validate_platform
    unless Facter.lsbdistid == 'Ubuntu' && Facter.lsbdistrelease.to_f >= 8.04
      error = <<-ERROR


      Moonshadow::Manifest::Rails is currently only supported on Ubuntu 8.04
      or greater. If you'd like to see your favorite distro supported, fork
      Moonshadow on GitHub!
      ERROR
      raise NotImplementedError, error
    end
  end
  recipe :validate_platform

end
