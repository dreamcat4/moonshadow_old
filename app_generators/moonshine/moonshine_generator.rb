require 'tempfile'
class MoonshineGenerator < RubiGen::Base
  attr_reader :file_name, :klass_name, :rails, :moonshine_version

  def initialize(runtime_args, runtime_options = {})
    super
    @destination_root = args.shift
    @file_name = "application_manifest"
    @klass_name = @file_name.classify
    detect_rails
    gem 'moonshine'
    @moonshine_version = Gem.loaded_specs["moonshine"].version.to_s
  end

  def detect_rails
    begin
      require File.expand_path(File.join(destination_root, 'config/environment.rb'))
    rescue LoadError
      @rails = false
    else
      @rails = true
    end
  end

  def rails?
    @rails
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

  def manifest
    recorded_session = record do |m|
      m.directory 'app/manifests'
      m.directory 'app/manifests/templates'

      #generate or upgrade app/manifests/#{file_name}.rb
      if File.exists?(destination_path("app/manifests/#{file_name}.rb"))
        if File.read(destination_path("app/manifests/#{file_name}.rb")) =~ /vendor\/plugins\/moonshine/
          gsub_file "app/manifests/#{file_name}.rb", /^.*vendor\/plugins\/moonshine.*$/mi do |match|
            "#{moonshine_gem_string}\nrequire 'moonshine'\n"
          end
        else
          gsub_file "app/manifests/#{file_name}.rb", /^gem 'moonshine'.*$/mi do |match|
            moonshine_gem_string
          end
        end
      else
        m.template  'moonshine.rb', "app/manifests/#{file_name}.rb", :assigns => { :moonshine_gem_string => moonshine_gem_string }
      end

      m.directory 'app/manifests/templates'
      m.template  'readme.templates', 'app/manifests/templates/README'
      m.directory 'config'
      m.template  'moonshine.yml', "config/moonshine.yml"
      m.template  'gems.yml', 'config/gems.yml', :assigns => { :gems => gems } if rails?
      m.directory 'lib/tasks'
      m.template  'moonshine.rake', 'lib/tasks/moonshine.rake' if rails?
      m.template  'Capfile', 'Capfile'

      #generate or upgrade config/deploy.rb
      if File.exists?(destination_path('config/deploy.rb'))
        if File.read(destination_path('config/deploy.rb')) =~ /moonshine\/capistrano/
          gsub_file 'config/deploy.rb', /^gem 'moonshine'.*$/mi do |match|
            moonshine_gem_string
          end
        else
          File.prepend(destination_path('config/deploy.rb'), "#{moonshine_gem_string}\nrequire 'moonshine/capistrano'\n")
        end
      else
        m.template  'deploy.rb', 'config/deploy.rb', :assigns => { :moonshine_gem_string => moonshine_gem_string }
      end
    end
    
    intro = <<-INTRO
    
After the Moonshine generator finishes don't forget to:

- Edit config/moonshine.yml
Use this file to manage configuration related to deploying and running the app: 
domain name, git repos, package dependencies for gems, and more.

- Edit app/manifests/#{file_name}.rb
Use this to manage the configuration of everything else on the server:
define the server 'stack', cron jobs, mail aliases, configuration files 

    INTRO
    puts intro if File.basename($0) == 'generate'
    
    recorded_session
  end

  def moonshine_gem_string
    "gem 'moonshine', '= #{moonshine_version}'"
  end

  def gsub_file(relative_destination, regexp, *args, &block)
    path = destination_path(relative_destination)
    content = File.read(path).gsub(regexp, *args, &block)
    File.open(path, 'wb') { |file| file.write(content) }
  end

  # Override with your own usage banner.
  def banner
    "Usage: #{$0} <path> [options]"
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