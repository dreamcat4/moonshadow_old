require 'shadow_puppet'
require 'erb'
require 'active_support/inflector'
module Moonshadow  #:nodoc:
end
require File.join(File.dirname(__FILE__), 'moonshadow', 'manifest.rb')
require File.join(File.dirname(__FILE__), 'moonshadow', 'manifest', 'rails.rb')