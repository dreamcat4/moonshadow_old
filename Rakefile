require 'rake'
require 'rake/testtask'
begin
  require 'rubygems'
  require 'hanna/rdoctask'
rescue LoadError
  require 'rake/rdoctask'
end

task :rcov do
  system "rcov --exclude /Library/Ruby/ --exclude ~/ -Itest `find test/ | grep _test`"
end

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the moonshine plugin.'
Rake::TestTask.new(:test) do |t|
  t.test_files = FileList.new('test/**/*_test.rb') do |fl|
    fl.exclude(/tmp\/moonshine/)
  end
  t.verbose = true
end

desc 'Generate documentation for the moonshine plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'Moonshine'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.main = "README.rdoc"
  rdoc.options << '--webcvs=http://github.com/railsmachine/moonshine/tree/master/'
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "moonshadow"
    gemspec.description = gemspec.summary = "Rails deployment and configuration management done right. ShadowPuppet + Capistrano == crazy delicious"
    gemspec.email = "jesse@railsmachine.com"
    gemspec.homepage = "http://railsmachine.github.com/moonshine/"
    gemspec.authors = ["Jesse Newland", "Rob Lingle"]
    gemspec.files = FileList.new('lib/**/*', 'bin/**/*', 'app_generators/**/*')
    gemspec.test_files = []
    gemspec.add_dependency('shadow_puppet', '>= 0.3.1')
    gemspec.add_dependency('rake', '>= 0.8.7')
    gemspec.add_dependency('rubigen', '>= 1.5.2')
    gemspec.add_dependency('commander', '>= 3.2.9')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
end

task :pull do
  system "git pull origin master"
  system "git pull github master"
end

task :_push do
  system "git push origin master"
  system "git push github master"
end

task :push => [:redoc, :pull, :test, :_push]

task :redoc do
  #clean
  system "git checkout gh-pages && git pull origin gh-pages && git pull github gh-pages"
  system "rm -rf doc"
  system "git checkout master"
  system "rm -rf doc"

  #doc
  Rake::Task['rdoc'].invoke

  #switch branch
  system "git checkout gh-pages"

  #move it all to the root
  system "cp -r doc/* . && rm -rf doc"

  #add, commit and push
  system "git add ."
  system "git commit -am 'regenerate rdocs' && git push origin gh-pages && git push github gh-pages"
  system "git checkout master"
end
