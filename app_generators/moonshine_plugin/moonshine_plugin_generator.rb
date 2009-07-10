class MoonshinePluginGenerator < RubiGen::Base
  attr_reader :name, :plugin_name, :module_name

  def initialize(runtime_args, runtime_options = {})
    super
    usage if args.empty?
    plugin = args.shift
    if plugin
      @name = plugin.downcase.underscore
      @module_name = @name.camelize
      @plugin_name = 'moonshine_' + name
    else
      puts "Please specify the name of your plugin"
      puts "moonshine_plugin <name>"
      puts
      exit
    end
  end

  def manifest
    record do |m|
      m.directory "vendor/plugins/#{plugin_name}"
      m.template  "README.rdoc", "vendor/plugins/#{plugin_name}/README.rdoc"
      m.directory "vendor/plugins/#{plugin_name}/moonshine"
      m.template  'init.rb', "vendor/plugins/#{plugin_name}/moonshine/init.rb"
      m.directory "vendor/plugins/#{plugin_name}/lib"
      m.template  'plugin.rb', "vendor/plugins/#{plugin_name}/lib/#{name}.rb"
      m.directory "vendor/plugins/#{plugin_name}/spec"
      m.template  'spec.rb', "vendor/plugins/#{plugin_name}/spec/#{name}_spec.rb"
      m.template  'spec_helper.rb', "vendor/plugins/#{plugin_name}/spec/spec_helper.rb"
    end
  end

  # Override with your own usage banner.
  def banner
    "Usage: #{$0} <plugin name> [options]"
  end

end