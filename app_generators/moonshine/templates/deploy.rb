<%= moonshine_gem_string %>
require 'moonshine/capistrano'
server "moonshine-managed-server.com", :app, :web, :db, :primary => true