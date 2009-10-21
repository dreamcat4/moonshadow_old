# require 'tempfile'
require 'rubygems'
# require File.join(File.dirname(__FILE__), '../../lib/moonshadow/types.rb')
class MoonshadowGenerator < RubiGen::Base
  attr_reader :file_name

  def initialize(runtime_args = [], runtime_options = {})
    super

    # These unspecified deploy setting should be detected "late" in capistrano.rb
    require "yamldoc"
    # @msconfig = AutoYamlDoc.new().merge options
    # puts "msconfig=#{msconfig.inspect}"

    # puts "options"
    # puts options.inspect
    # @options.merge runtime_options

    @destination_root ||= Dir.pwd
    @file_name = "application_manifest"
    @options[:klass_name] = @file_name.camelize

    # @msconfig = AutoYamlDoc.new("#{@msconfig[:type]}/msconfig.yml")
    @msconfig = YamlDoc.new(File.join(File.dirname(__FILE__), "templates/static/msconfig.yml"))
    
    # @msconfig = AutoYamlDoc.new(:filename => "templates/static/msconfig.yml")
    puts "@msconfig=#{@msconfig.inspect}"
    puts "runtime_options = #{runtime_options.inspect}"
    # puts "options = #{options.inspect}"

    # @msconfig.save(File.join(Dir.pwd, ".msconfig")) do |c|
    #   [:type,:name,:deploy_to,:server,:repository].each do |opt|
    #     c.merge!( opt => runtime_options[opt] ) if runtime_options[opt]
    #   end
    #   # puts c.inspect
    # end
    gem 'moonshadow'
    @msconfig.moonshadow_version = Gem.loaded_specs["moonshadow"].version.to_s
    @msconfig.moonshadow_gem_string = "gem 'moonshadow', '= #{@msconfig.moonshadow_version}'"
    @msconfig.klass_name = @file_name.camelize
    @msconfig.save(File.join(Dir.pwd, ".msconfig"))

    #   @msconfig.save do |c|
    #   c.merge!({
    #     # :type               => options[:type] || detect_type,
    #     # :type               => options[:type] if options[:type],
    #     :moonshadow_version => Gem.loaded_specs["moonshadow"].version.to_s,
    #     # :application        => options[:deploy_to] if options[:deploy_to],
    #     # :deploy_to          => options[:name] if options[:name],
    #     :klass_name          => options[:klass_name],
    #   })
    # end

    
  end

  # # Override with your own usage banner.
  # def banner
  #   "Usage: #{$0} <path> [options]"
  # end

  def manifest
    recorded_session = record do |m|
      # directories(m)
      # m.template  'readme.templates', 'app/manifests/templates/README'
      # m.template  "#{options[:type]}/moonshadow.yml", "config/moonshadow.yml"
      # m.template  "#{options[:type]}/moonshadow.yml", ".msconfig"
      
      # using autoyamldoc now.
      # m.template  "#{options[:type]}/msconfig.yml", ".msconfig"

      # if options[:type] == 'rails'
        # m.template  "#{options[:type]}/moonshadow.rake", 'lib/tasks/moonshadow.rake'
        # m.template  'rails/gems.yml', 'config/gems.yml', :assigns => { :gems => gems } if options[:type] == 'rails'
      # end
      puts "one"
      # generate_or_upgrade_manifest(m)
      # puts "two"
      
      
      app_msdir = File.join(Dir.pwd,".ms")
      Dir.mkdir(app_msdir) if !FileTest.directory?(app_msdir)

      outfile = File.join(app_msdir,"#{@file_name}.rb")
      if !File.exist?(outfile)
        template = File.read(File.join(File.dirname(__FILE__), 'templates/static/manifest.rb'))
        File.open(outfile,"w") do |f|
          f << ERB.new(template).result(@msconfig.instance_eval{binding})
        end
      end

      Dir.glob(File.join(app_msdir,'**')).each do |file|
        if file =~ /.*\.rb/ && File.read(file) =~ /Manifest/mi
        # if file =~ /.*\.rb$/
          gsub_file file, /^gem 'moonshadow'.*$/, @msconfig.moonshadow_gem_string
        end        
      end
      
    end
    # puts "three"
    intro
    # puts "four"
    recorded_session
  end

  def gsub_file(file, regexp, *args, &block)
    content = File.read(file).gsub(regexp, *args, &block)
    File.open(file, 'wb') { |f| f.write(content) }
  end

  def directories(m)
    m.directory 'app'
    m.directory 'app/manifests'
    m.directory 'app/manifests/templates'
  end

  def moonshadow_gem_string
    "gem 'moonshadow', '= #{@msconfig[:moonshadow_version]}'"
  end
  
  def generate_or_upgrade_manifest(m)
    puts "file_name=#{file_name}"
    puts "@file_name=#{@file_name}"
    # puts destination_path("app/manifests/#{file_name}.rb")
    puts destination_path("app/manifests/a.rb")
    puts "zz"
    if File.exists?(destination_path("app/manifests/#{file_name}.rb"))
      puts "a"
      if File.read(destination_path("app/manifests/#{file_name}.rb")) =~ /vendor\/plugins\/moonshadow/
        gsub_file "app/manifests/#{file_name}.rb", /^.*vendor\/plugins\/moonshadow.*$/mi do |match|
          puts "two"
          "#{moonshadow_gem_string}\nrequire 'moonshadow'\n"
        end
      else
        puts "three"
        gsub_file "app/manifests/#{file_name}.rb", /^gem 'moonshadow'.*$/mi do |match|
          moonshadow_gem_string
        end
      end
    else
      puts "b"
      m.template  "#{@msconfig[:type]}/manifest.rb", "app/manifests/#{file_name}.rb", :assigns => { :moonshadow_gem_string => moonshadow_gem_string }
    end
  end



protected
  # def detect_type
  #   # Moonshadow::Type::detect destination_root
  #   Moonshadow::Type::detect Dir.pwd
  # end

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

  # def gems
  #   gem_array = returning Array.new do |hash|
  #     Rails.configuration.gems.map do |gem|
  #       hash = { :name => gem.name }
  #       hash.merge!(:source => gem.source) if gem.source
  #       hash.merge!(:version => gem.requirement.to_s) if gem.requirement
  #       hash
  #     end if Rails.respond_to?( 'configuration' )
  #   end
  #   if (RAILS_GEM_VERSION rescue false)
  #     gem_array << {:name => 'rails', :version => RAILS_GEM_VERSION }
  #   else
  #     gem_array << {:name => 'rails'}
  #   end
  #   gem_array
  # end


end

# class File
#   def self.prepend(path, string)
#     Tempfile.open File.basename(path) do |tempfile|
#       # prepend data to tempfile
#       tempfile << string
# 
#       File.open(path, 'r+') do |file|
#         # append original data to tempfile
#         tempfile << file.read
#         # reset file positions
#         file.pos = tempfile.pos = 0
#         # copy all data back to original file
#         file << tempfile.read
#       end
#     end
#   end
# end

