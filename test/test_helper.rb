# Must set before requiring generator libs.
TMP_ROOT = File.dirname(__FILE__) + "/tmp" unless defined?(TMP_ROOT)
PROJECT_NAME = "moonshadow" unless defined?(PROJECT_NAME)
app_root = File.join(TMP_ROOT, PROJECT_NAME)
if defined?(APP_ROOT)
  APP_ROOT.replace(app_root)
else
  APP_ROOT = app_root
end

#load path, rubygems
$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '/../lib')
$LOAD_PATH.unshift File.dirname(__FILE__)
require 'rubygems'

#testing dependencies
require 'test/unit'
require 'fileutils'
require 'rubigen'
require 'rubigen/helpers/generator_test_helper'
require 'mocha'

#generate and require the fake rails app
`rails --force #{APP_ROOT}`
ENV['RAILS_ENV'] = 'test'
ENV['RAILS_ROOT'] ||= APP_ROOT
require File.expand_path(File.join(APP_ROOT, 'config/environment.rb'))

#require what we're actually testing
require 'moonshadow'
require 'shadow_puppet/test'