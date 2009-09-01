require File.join(File.dirname(__FILE__), "test_helper.rb")

class MoonshadowGeneratorTest < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    rails_setup
  end

  def teardown
    bare_teardown
  end

  def test_generates_correct_files
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_directory_exists templates_path
    assert_file_exists config_path
    assert_file_exists manifest_path
    assert_file_exists gems_path
    assert_file_exists capfile_path
    assert_file_exists deploy_path
    assert_file_exists rake_path
  end

  def test_prepends_existing_deploy_rb
    deploy_rb =<<-DEPLOY
server 'myserver.com', :app
DEPLOY
    FileUtils.mkdir_p "#{APP_ROOT}/config"
    File.open("#{APP_ROOT}/#{deploy_path}", 'w') {|f| f.write(deploy_rb) }
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_match /^gem 'moonshadow', '= #{Gem.loaded_specs["moonshadow"].version.to_s}'/, File.read("#{APP_ROOT}/"+deploy_path)
    assert_match /^require 'moonshadow\/capistrano'/, File.read("#{APP_ROOT}/#{deploy_path}")
    assert_match /^server 'myserver.com', :app/, File.read("#{APP_ROOT}/#{deploy_path}")
  end

  def test_upgrades_existing_deploy_rb
    deploy_rb =<<-DEPLOY
gem 'moonshadow', '= 0.0.0'
require 'moonshadow/capistrano'
server 'myserver.com', :app
DEPLOY
    FileUtils.mkdir_p "#{APP_ROOT}/config"
    File.open("#{APP_ROOT}/#{deploy_path}", 'w') {|f| f.write(deploy_rb) }
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_match /^gem 'moonshadow', '= #{Gem.loaded_specs["moonshadow"].version.to_s}'/, File.read("#{APP_ROOT}/"+deploy_path)
    assert_no_match /^gem 'moonshadow', '= 0.0.0'/, File.read("#{APP_ROOT}/"+deploy_path)
  end

  def test_generates_valid_config_file
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_instance_of Hash, YAML.load_file("#{APP_ROOT}/"+config_path)
  end

  def test_generates_application_manifest
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_match /gem 'moonshadow', '= #{Gem.loaded_specs["moonshadow"].version.to_s}'/, File.read("#{APP_ROOT}/"+manifest_path)
    assert_match /require 'moonshadow'/, File.read("#{APP_ROOT}/"+manifest_path)
    assert_match /class ApplicationManifest < Moonshadow::Manifest::Rails/, File.read("#{APP_ROOT}/"+manifest_path)
  end

  def test_fixes_existing_manifest
    manifest =<<-MANIFEST
require "\#{File.dirname(__FILE__)}/../../vendor/plugins/moonshadow/lib/moonshadow.rb"
class ApplicationManifest < Moonshadow::Manifest::Rails
end
MANIFEST
    FileUtils.mkdir_p "#{APP_ROOT}/app/manifests"
    File.open("#{APP_ROOT}/#{manifest_path}", 'w') {|f| f.write(manifest) }
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_match /gem 'moonshadow', '= #{Gem.loaded_specs["moonshadow"].version.to_s}'/, File.read("#{APP_ROOT}/"+manifest_path)
    assert_match /require 'moonshadow'/, File.read("#{APP_ROOT}/"+manifest_path)
  end

  def test_upgrades_existing_manifest
    manifest =<<-MANIFEST
gem 'moonshadow', '= 0.0.0'
require 'moonshadow'
class ApplicationManifest < Moonshadow::Manifest::Rails
end
MANIFEST
    FileUtils.mkdir_p "#{APP_ROOT}/app/manifests"
    File.open("#{APP_ROOT}/#{manifest_path}", 'w') {|f| f.write(manifest) }
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_match /gem 'moonshadow', '= #{Gem.loaded_specs["moonshadow"].version.to_s}'/, File.read("#{APP_ROOT}/"+manifest_path)
    assert_no_match /gem 'moonshadow', '= 0.0.0'/, File.read("#{APP_ROOT}/"+manifest_path)
  end

  def test_generates_gem_dependencies
    run_generator('moonshadow', [APP_ROOT], sources)
    assert_not_nil YAML.load_file("#{APP_ROOT}/"+gems_path).first
  end

  private

    def rails_setup
      `rails --force #{APP_ROOT}`
    end

    def manifest_path
      "app/manifests/application_manifest.rb"
    end

    def gems_path
      "config/gems.yml"
    end

    def config_path
      "config/moonshadow.yml"
    end

    def templates_path
      "app/manifests/templates"
    end

    def deploy_path
      'config/deploy.rb'
    end

    def capfile_path
      'Capfile'
    end

    def rake_path
      'lib/tasks/moonshadow.rake'
    end

    def sources
      [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
    end

    def generator_path
      "app_generators"
    end
end