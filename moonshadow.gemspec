# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moonshadow}
  s.version = "0.0.6"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jesse Newland", "Rob Lingle"]
  s.date = %q{2009-09-30}
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
    "app_generators/moonshadow/templates/standalone/deploy.rb",
    "app_generators/moonshadow/templates/standalone/manifest.rb",
    "app_generators/moonshadow/templates/standalone/moonshadow.rake",
    "app_generators/moonshadow/templates/standalone/moonshadow.yml",
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
    "lib/moonshadow/bootstrap/ssh.rake",
    "lib/moonshadow/capistrano.rb",
    "lib/moonshadow/manifest.rb",
    "lib/moonshadow/manifest/recipies.rb",
    "lib/moonshadow/manifest/recipies/apache.rb",
    "lib/moonshadow/manifest/recipies/apt_gems.yml",
    "lib/moonshadow/manifest/recipies/mysql.rb",
    "lib/moonshadow/manifest/recipies/nginx.rb",
    "lib/moonshadow/manifest/recipies/os.rb",
    "lib/moonshadow/manifest/recipies/passenger.rb",
    "lib/moonshadow/manifest/recipies/php.rb",
    "lib/moonshadow/manifest/recipies/postgresql.rb",
    "lib/moonshadow/manifest/recipies/rails.rb",
    "lib/moonshadow/manifest/recipies/sqlite3.rb",
    "lib/moonshadow/manifest/recipies/templates/innodb.cnf.erb",
    "lib/moonshadow/manifest/recipies/templates/logrotate.conf.erb",
    "lib/moonshadow/manifest/recipies/templates/moonshadow.cnf.erb",
    "lib/moonshadow/manifest/recipies/templates/nginx.conf.erb",
    "lib/moonshadow/manifest/recipies/templates/nginx.site.erb",
    "lib/moonshadow/manifest/recipies/templates/passenger.conf.erb",
    "lib/moonshadow/manifest/recipies/templates/passenger.vhost.erb",
    "lib/moonshadow/manifest/recipies/templates/pg_hba.conf.erb",
    "lib/moonshadow/manifest/recipies/templates/postgresql.conf.erb",
    "lib/moonshadow/manifest/recipies/templates/unattended_upgrades.erb",
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
