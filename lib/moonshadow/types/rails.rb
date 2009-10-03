
module Moonshadow::Type::Rails

  def self.detect destination_root
    # return false
    begin
      require File.expand_path(File.join(destination_root, 'config/environment.rb'))
    rescue LoadError
      false
    else
      true
    end
  end

end

