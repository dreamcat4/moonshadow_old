
module Moonshadow::Type::Static

  def self.detect destination_root

    index_file = "index"
    sufs = ["html","htm"]

    sufs.each do |suf|
      return true if File.exists? File.expand_path(File.join(destination_root, "#{index_file}.#{suf}"))
    end
    return false

  end

end

