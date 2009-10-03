require 'dreamcat4-settingslogic'

class Settings < Settingslogic

  ms_user_cfg_file = ".moonshadow"
  # source "#{Rails.root}/config/application.yml"
  source File.expand_path("~/#{ms_user_cfg_file}")  
  # namespace Rails.env

end

puts ""
puts "Settings"
config = Settings.new
# Settings.new(:config1 => 1, :config2 => 2)
config[:config1] = 1
config[:config2] = 2

puts ""

module Moonshadow  #:nodoc:
end

module Moonshadow::Type

  # types wishlist:
  # merb, sintatra, ldap, python, gitosis
  
  def self.types
    return @types || init_types
  end
  
  def self.init_types
    default_types
    user_types
    # local_types
    return @types
  end

  def self.user_types
    
  end
  
  def self.default_types
    @types = []
    Dir.glob(File.join(File.dirname(__FILE__), 'types', '*.rb')).each do |type_file|
      add_type type_file
    end
  end

  def self.add_type type_file
    # puts "#{type_file}"
    require type_file
    type = File.basename(type_file,'.rb')
    @types << type    
  end
  
  def self.detect destination_root
    types_found = []
    @types.each do |type|
      types_found << type if eval "Moonshadow::Type::#{type.camelize}.detect destination_root"
    end
    select_type types_found
  end
  
  def self.select_type types_found
    return types_found.first
  end

end






