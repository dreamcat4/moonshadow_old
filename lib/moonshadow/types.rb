

module Moonshadow  #:nodoc:
end

module Moonshadow::Type

  # types wishlist:
  # merb, sintatra, ldap, python, gitosis, 
  # smtp email server, sms server, iphone app server
  
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
    # return types_found.first || msconfig.default_type
  end

end

