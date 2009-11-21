
module Moonshadow::Type::Php

  def self.detect dir

    index_file = "index"
    sufs = ["php","php5"]

    sufs.each do |suf|
      return true if File.exists? File.expand_path(File.join(dir, "#{index_file}.#{suf}"))
    end
    return false
    
  end

end

