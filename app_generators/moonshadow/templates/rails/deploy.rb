<%= moonshadow_gem_string %>
require 'moonshadow/capistrano'
server "moonshadow-managed-server.com", :app, :web, :db, :primary => true