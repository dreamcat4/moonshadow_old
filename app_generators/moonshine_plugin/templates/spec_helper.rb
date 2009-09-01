require 'rubygems'
ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= File.dirname(__FILE__) + '/../../../..'

require File.join(File.dirname(__FILE__), '..', '..', 'moonshadow', 'lib', 'moonshadow.rb')
require File.join(File.dirname(__FILE__), '..', 'lib', '<%= name %>.rb')

require 'shadow_puppet/test'