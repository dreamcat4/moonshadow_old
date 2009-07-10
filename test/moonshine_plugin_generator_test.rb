require File.join(File.dirname(__FILE__), "test_helper.rb")

class MoonshinePluginGeneratorTest < Test::Unit::TestCase
  include RubiGen::GeneratorTestHelper

  def setup
    bare_setup
    run_generator('moonshine_plugin', ['iptables'], sources)
  end

  def teardown
    bare_teardown
  end

  def test_generates_correct_files
    assert_file_exists init_path
    assert_file_exists module_path
  end

  def test_generates_plugin_module
    assert_match /module Iptables/, File.read("#{APP_ROOT}/"+module_path)
  end
  
  def test_includes_plugin_module
    assert_match /require ".*iptables\.rb"/,File.read("#{APP_ROOT}/"+init_path)
    assert_match /include Iptables/, File.read("#{APP_ROOT}/"+init_path)
  end

  private

    def module_path
      'vendor/plugins/moonshine_iptables/lib/iptables.rb'
    end

    def init_path
      'vendor/plugins/moonshine_iptables/moonshine/init.rb'
    end

    def sources
      [RubiGen::PathSource.new(:test, File.join(File.dirname(__FILE__),"..", generator_path))]
    end

    def generator_path
      "app_generators"
    end

end
