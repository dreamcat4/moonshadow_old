
module Moonshadow::Type::Rails

  def self.detect dir
    # return false
    begin
      require File.expand_path(File.join(dir, 'config/environment.rb'))
    rescue LoadError
      false
    else
      true
    end
  end

end

