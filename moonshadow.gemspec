# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moonshadow}
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jesse Newland", "Rob Lingle"]
  s.date = %q{2009-09-01}
  s.description = %q{Rails deployment and configuration management done right. ShadowPuppet + Capistrano == crazy delicious}
  s.email = %q{jesse@railsmachine.com}
  s.executables = ["moonshadow", "moonshadow_plugin"]
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = [
    "app_generators/moonshadow/moonshadow_generator.rb",
    "app_generators/moonshadow/templates/Capfile",
    "app_generators/moonshadow/templates/rails/deploy.rb",
    "app_generators/moonshadow/templates/rails/gems.yml",
    "app_generators/moonshadow/templates/rails/manifest.rb",
    "app_generators/moonshadow/templates/rails/moonshadow.rake",
    "app_generators/moonshadow/templates/rails/moonshadow.yml",
    "app_generators/moonshadow/templates/readme.templates",
    "app_generators/moonshadow_plugin/USAGE",
    "app_generators/moonshadow_plugin/moonshine_plugin_generator.rb",
    "app_generators/moonshadow_plugin/templates/README.rdoc",
    "app_generators/moonshadow_plugin/templates/init.rb",
    "app_generators/moonshadow_plugin/templates/plugin.rb",
    "app_generators/moonshadow_plugin/templates/spec.rb",
    "app_generators/moonshadow_plugin/templates/spec_helper.rb",
    "bin/moonshadow",
    "bin/moonshadow_plugin",
    "lib/moonshadow.rb",
    "lib/moonshadow/bootstrap/bootstrap.mri.sh",
    "lib/moonshadow/bootstrap/bootstrap.ree.sh",
    "lib/moonshadow/capistrano.rb",
    "lib/moonshadow/manifest.rb",
    "lib/moonshadow/manifest/rails.rb",
    "lib/moonshadow/manifest/rails/apache.rb",
    "lib/moonshadow/manifest/rails/apt_gems.yml",
    "lib/moonshadow/manifest/rails/mysql.rb",
    "lib/moonshadow/manifest/rails/os.rb",
    "lib/moonshadow/manifest/rails/passenger.rb",
    "lib/moonshadow/manifest/rails/postgresql.rb",
    "lib/moonshadow/manifest/rails/rails.rb",
    "lib/moonshadow/manifest/rails/sqlite3.rb",
    "lib/moonshadow/manifest/rails/templates/innodb.cnf.erb",
    "lib/moonshadow/manifest/rails/templates/logrotate.conf.erb",
    "lib/moonshadow/manifest/rails/templates/moonshadow.cnf.erb",
    "lib/moonshadow/manifest/rails/templates/passenger.conf.erb",
    "lib/moonshadow/manifest/rails/templates/passenger.vhost.erb",
    "lib/moonshadow/manifest/rails/templates/pg_hba.conf.erb",
    "lib/moonshadow/manifest/rails/templates/postgresql.conf.erb",
    "lib/moonshadow/manifest/rails/templates/unattended_upgrades.erb",
    "lib/moonshadow_setup_manifest.rb"
  ]
  s.homepage = %q{http://railsmachine.github.com/moonshine/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{Rails deployment and configuration management done right. ShadowPuppet + Capistrano == crazy delicious}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<shadow_puppet>, [">= 0.3.1"])
      s.add_runtime_dependency(%q<rake>, [">= 0.8.7"])
      s.add_runtime_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_runtime_dependency(%q<visionmedia-commander>, [">= 3.2.9"])
    else
      s.add_dependency(%q<shadow_puppet>, [">= 0.3.1"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
      s.add_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_dependency(%q<visionmedia-commander>, [">= 3.2.9"])
    end
  else
    s.add_dependency(%q<shadow_puppet>, [">= 0.3.1"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
    s.add_dependency(%q<rubigen>, [">= 1.5.2"])
    s.add_dependency(%q<visionmedia-commander>, [">= 3.2.9"])
  end
end
