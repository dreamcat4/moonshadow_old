# <%= moonshadow_gem_string %>
gem 'moonshadow'
require 'moonshadow/capistrano'

# retrieve server setting from ~/.msconfig
server "moonshadow-managed-server.com", :app, :web, :db, :primary => true
