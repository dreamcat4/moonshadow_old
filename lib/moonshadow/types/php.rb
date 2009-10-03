
module Moonshadow::Type::Php

  def self.detect destination_root

    index_file = "index"
    sufs = ["php","php5"]

    sufs.each do |suf|
      return true if File.exists? File.expand_path(File.join(destination_root, "#{index_file}.#{suf}"))
    end
    return false
    
  end

end

