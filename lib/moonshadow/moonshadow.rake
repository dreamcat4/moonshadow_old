
# The old rails Rake Tasks, which were originally installed as:
# lib/tasks/moonshadow.rake

# These should be converted into proper ms commands

namespace :moonshadow do

  namespace :db do
    desc "Bootstrap the database with fixtures from db/boostrap."
    task :bootstrap => :environment do
      require 'active_record/fixtures'
      ActiveRecord::Base.establish_connection(Rails.env)
      fixtures_dir = File.join(Rails.root, 'db/bootstrap/')
      Dir.glob(File.join(fixtures_dir, '*.{yml,csv}')).each do |fixture_file|
        Fixtures.create_fixtures(File.dirname(fixture_file), File.basename(fixture_file, '.*'))
      end
    end

    desc "Create fixtures in db/bootstrap. Specify tables with FIXTURES=x,y otherwise all will be created."
    task :dump => :environment do
      sql = "SELECT * FROM %s"
      skip_tables = [ "schema_info", "sessions", "schema_migrations" ]
      ActiveRecord::Base.establish_connection
      tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables

      tables.each do |table_name|
        i = "0000"
        File.open("#{RAILS_ROOT}/db/bootstrap/#{table_name}.yml", 'w') do |file|
          data = ActiveRecord::Base.connection.select_all(sql % table_name)
          file.write data.inject({}) { |hsh, record|
            hsh["#{table_name}_#{i.succ!}"] = record
            hsh
          }.to_yaml
        end
      end
    end
  end

  namespace :app do
    desc "Overwrite this task in your app if you have any bootstrap tasks that need to be run"
    task :bootstrap do
      #
    end
  end

  desc <<-DOC
  Attempt to bootstrap this application. In order, we run:

    rake db:schema:load (if db/schema.rb exists)
    rake db:migrate (if db/migrate exists)
    rake moonshadow:db:bootstrap (if db/bootstrap/ exists)
    rake moonshadow:app:bootstrap

  All of this assumes one things. That your application can run 'rake
  environment' with an empty database. Please ensure your application can do
  so!
  DOC
  task :bootstrap do
    Rake::Task["db:schema:load"].invoke if File.exist?("db/schema.rb")
    Rake::Task["environment"].invoke
    Rake::Task["db:migrate"].invoke if File.exist?("db/migrate")
    Rake::Task["moonshadow:db:bootstrap"].invoke if File.exist?("db/bootstrap")
    Rake::Task["moonshadow:app:bootstrap"].invoke
  end

  desc "Update config/moonshadow.yml with a list of the required gems"
  task :gems => 'gems:base' do
    gem_array = Rails.configuration.gems.reject(&:frozen?).map do |gem|
      hash = { :name => gem.name }
      hash.merge!(:source => gem.source) if gem.source
      hash.merge!(:version => gem.requirement.to_s) if gem.requirement
      hash
    end
    if (RAILS_GEM_VERSION rescue false)
      gem_array << {:name => 'rails', :version => RAILS_GEM_VERSION }
    else
      gem_array << {:name => 'rails'}
    end
    config_path = File.join(Dir.pwd, 'config', 'gems.yml')
    File.open( config_path, 'w' ) do |out|
      YAML.dump(gem_array, out )
    end
    puts "config/gems.yml has been updated with your application's gem"
    puts "dependencies. Please commit these changes to your SCM or upload"
    puts "them to your server with the cap local_config:upload command."
  end

end
