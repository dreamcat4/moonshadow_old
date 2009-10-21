# require 'tempfile'
require 'rubygems'
# require File.join(File.dirname(__FILE__), '../../lib/moonshadow/types.rb')

class String
  def camelize
    self.split('_').map {|w| w.capitalize}.join
  end
end

class MoonshadowGenerator
  attr_reader :file_name

  def initialize(runtime_args = [], runtime_options = {})
    # super

    # These unspecified deploy setting should be detected "late" in capistrano.rb
    require "yamldoc"
    # @msconfig = AutoYamlDoc.new().merge options
    # puts "msconfig=#{msconfig.inspect}"

    # puts "options"
    # puts options.inspect
    # @options.merge runtime_options

    @destination_root ||= Dir.pwd
    @file_name = "application_manifest"
    # @options[:klass_name] = @file_name.camelize

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

    manifest
  end


  def manifest

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

  def gsub_file(file, regexp, *args, &block)
    content = File.read(file).gsub(regexp, *args, &block)
    File.open(file, 'wb') { |f| f.write(content) }
  end

end

