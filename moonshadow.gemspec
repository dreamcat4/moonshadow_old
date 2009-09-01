# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{moonshadow}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jesse Newland", "Rob Lingle"]
  s.date = %q{2009-09-01}
  s.description = %q{Rails deployment and configuration management done right. ShadowPuppet + Capistrano == crazy delicious}
  s.email = %q{jesse@railsmachine.com}
  s.executables = ["moonshine", "moonshine_plugin"]
  s.extra_rdoc_files = [
    "LICENSE"
  ]
  s.files = [
    "app_generators/moonshine/moonshine_generator.rb",
    "app_generators/moonshine/templates/Capfile",
    "app_generators/moonshine/templates/rails/deploy.rb",
    "app_generators/moonshine/templates/rails/gems.yml",
    "app_generators/moonshine/templates/rails/manifest.rb",
    "app_generators/moonshine/templates/rails/moonshine.rake",
    "app_generators/moonshine/templates/rails/moonshine.yml",
    "app_generators/moonshine/templates/readme.templates",
    "app_generators/moonshine_plugin/USAGE",
    "app_generators/moonshine_plugin/moonshine_plugin_generator.rb",
    "app_generators/moonshine_plugin/templates/README.rdoc",
    "app_generators/moonshine_plugin/templates/init.rb",
    "app_generators/moonshine_plugin/templates/plugin.rb",
    "app_generators/moonshine_plugin/templates/spec.rb",
    "app_generators/moonshine_plugin/templates/spec_helper.rb",
    "bin/moonshine",
    "bin/moonshine_plugin",
    "lib/moonshine.rb",
    "lib/moonshine/bootstrap/bootstrap.mri.sh",
    "lib/moonshine/bootstrap/bootstrap.ree.sh",
    "lib/moonshine/capistrano.rb",
    "lib/moonshine/manifest.rb",
    "lib/moonshine/manifest/rails.rb",
    "lib/moonshine/manifest/rails/apache.rb",
    "lib/moonshine/manifest/rails/apt_gems.yml",
    "lib/moonshine/manifest/rails/mysql.rb",
    "lib/moonshine/manifest/rails/os.rb",
    "lib/moonshine/manifest/rails/passenger.rb",
    "lib/moonshine/manifest/rails/postgresql.rb",
    "lib/moonshine/manifest/rails/rails.rb",
    "lib/moonshine/manifest/rails/sqlite3.rb",
    "lib/moonshine/manifest/rails/templates/innodb.cnf.erb",
    "lib/moonshine/manifest/rails/templates/logrotate.conf.erb",
    "lib/moonshine/manifest/rails/templates/moonshine.cnf.erb",
    "lib/moonshine/manifest/rails/templates/passenger.conf.erb",
    "lib/moonshine/manifest/rails/templates/passenger.vhost.erb",
    "lib/moonshine/manifest/rails/templates/pg_hba.conf.erb",
    "lib/moonshine/manifest/rails/templates/postgresql.conf.erb",
    "lib/moonshine/manifest/rails/templates/unattended_upgrades.erb",
    "lib/moonshine_setup_manifest.rb"
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
      s.add_runtime_dependency(%q<commander>, [">= 3.2.9"])
    else
      s.add_dependency(%q<shadow_puppet>, [">= 0.3.1"])
      s.add_dependency(%q<rake>, [">= 0.8.7"])
      s.add_dependency(%q<rubigen>, [">= 1.5.2"])
      s.add_dependency(%q<commander>, [">= 3.2.9"])
    end
  else
    s.add_dependency(%q<shadow_puppet>, [">= 0.3.1"])
    s.add_dependency(%q<rake>, [">= 0.8.7"])
    s.add_dependency(%q<rubigen>, [">= 1.5.2"])
    s.add_dependency(%q<commander>, [">= 3.2.9"])
  end
end
