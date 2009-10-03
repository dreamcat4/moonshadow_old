require 'tempfile'
require 'rubygems'
# require File.join(File.dirname(__FILE__), '../../lib/moonshadow/types.rb')
class MoonshadowGenerator < RubiGen::Base
  attr_reader :file_name

  def initialize(runtime_args = [], runtime_options = {})
    super
    puts "options"
    puts options
    puts "options_end"
    @options.merge runtime_options
    @destination_root = nil || "."
    @file_name = "application_manifest"
    @options[:klass_name] = @file_name.camelize
    @options[:type] = detect_type unless options[:type]
    gem 'moonshadow'
    @options[:moonshadow_version] = Gem.loaded_specs["moonshadow"].version.to_s
  end

  # Override with your own usage banner.
  def banner
    "Usage: #{$0} <path> [options]"
  end

  def manifest
    recorded_session = record do |m|
      directories(m)
      m.template  'readme.templates', 'app/manifests/templates/README'
      m.template  'Capfile', 'Capfile'
      m.template  "#{options[:type]}/moonshadow.yml", "config/moonshadow.yml"
      if options[:type] == 'rails'
        m.template  "#{options[:type]}/moonshadow.rake", 'lib/tasks/moonshadow.rake'
        m.template  'rails/gems.yml', 'config/gems.yml', :assigns => { :gems => gems } if options[:type] == 'rails'
      end
      generate_or_upgrade_manifest(m)
      generate_or_upgrade_deploy(m)
    end
    intro
    recorded_session
  end

protected

  def intro
    intro = <<-INTRO

After the Moonshadow generator finishes don't forget to:

- Edit config/moonshadow.yml
Use this file to manage configuration related to deploying and running the app: 
domain name, git repos, package dependencies for gems, and more.

- Edit app/manifests/#{file_name}.rb
Use this to manage the configuration of everything else on the server:
define the server 'stack', cron jobs, mail aliases, configuration files 

    INTRO
    puts intro if File.basename($0) == 'generate'
  end

  def detect_rails
    # return false
    begin
      require File.expand_path(File.join(destination_root, 'config/environment.rb'))
    rescue LoadError
      false
    else
      true
    end
  end

  def detect_type
    Moonshadow::Type::detect destination_root
  end

  def gems
    gem_array = returning Array.new do |hash|
      Rails.configuration.gems.map do |gem|
        hash = { :name => gem.name }
        hash.merge!(:source => gem.source) if gem.source
        hash.merge!(:version => gem.requirement.to_s) if gem.requirement
        hash
      end if Rails.respond_to?( 'configuration' )
    end
    if (RAILS_GEM_VERSION rescue false)
      gem_array << {:name => 'rails', :version => RAILS_GEM_VERSION }
    else
      gem_array << {:name => 'rails'}
    end
    gem_array
  end

  def directories(m)
    m.directory 'app'
    m.directory 'app/manifests'
    m.directory 'app/manifests/templates'
    m.directory 'config'
    m.directory 'lib'
    m.directory 'lib/tasks'
  end

  #generate or upgrade app/manifests/#{file_name}.rb
  def generate_or_upgrade_manifest(m)
    if File.exists?(destination_path("app/manifests/#{file_name}.rb"))
      if File.read(destination_path("app/manifests/#{file_name}.rb")) =~ /vendor\/plugins\/moonshadow/
        gsub_file "app/manifests/#{file_name}.rb", /^.*vendor\/plugins\/moonshadow.*$/mi do |match|
          "#{moonshadow_gem_string}\nrequire 'moonshadow'\n"
        end
      else
        gsub_file "app/manifests/#{file_name}.rb", /^gem 'moonshadow'.*$/mi do |match|
          moonshadow_gem_string
        end
      end
    else
      m.template  "#{options[:type]}/manifest.rb", "app/manifests/#{file_name}.rb", :assigns => { :moonshadow_gem_string => moonshadow_gem_string }
    end
  end

  #generate or upgrade config/deploy.rb
  def generate_or_upgrade_deploy(m)
    if File.exists?(destination_path('config/deploy.rb'))
      if File.read(destination_path('config/deploy.rb')) =~ /moonshadow\/capistrano/
        gsub_file 'config/deploy.rb', /^gem 'moonshadow'.*$/mi do |match|
          moonshadow_gem_string
        end
      else
        File.prepend(destination_path('config/deploy.rb'), "#{moonshadow_gem_string}\nrequire 'moonshadow/capistrano'\n")
      end
    else
      m.template  "#{options[:type]}/deploy.rb", 'config/deploy.rb', :assigns => { :moonshadow_gem_string => moonshadow_gem_string }
    end
  end

  def moonshadow_gem_string
    "gem 'moonshadow', '= #{options[:moonshadow_version]}'"
  end

  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end

end

class File
  def self.prepend(path, string)
    Tempfile.open File.basename(path) do |tempfile|
      # prepend data to tempfile
      tempfile << string

      File.open(path, 'r+') do |file|
        # append original data to tempfile
        tempfile << file.read
        # reset file positions
        file.pos = tempfile.pos = 0
        # copy all data back to original file
        file << tempfile.read
      end
    end
  end
end