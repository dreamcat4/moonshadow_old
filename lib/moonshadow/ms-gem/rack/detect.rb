
module Moonshadow::Type::Rack

  def self.detect dir
    # return false
    begin
      require File.expand_path(File.join(dir, 'config.ru'))
    rescue LoadError
      false
    else
      true
    end
  end

end

