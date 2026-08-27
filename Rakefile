# encoding: utf-8
require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts 'Run `bundle install` to install missing gems'
  exit e.status_code
end
require 'bundler/gem_tasks'
require 'rake'

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

desc 'Code coverage detail'
task :simplecov do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: :spec

require 'rdoc/task'
RDoc::Task.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ''

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "message_train #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

# load 'rails/tasks/statistics.rake'

namespace :message_train do
  desc 'Clean out development ActiveStorage files'
  task files: :environment do
    FileUtils.rm_rf(Dir["#{Rails.root}/storage/*"])
  end
  desc 'Recreate database from seeds and clean out all system files'
  task clean: :environment do
    import 'spec/dummy/Rakefile'
    Rake::Task['message_train:files'].invoke
    dummy_app_path = MessageTrain::Engine.root.join('spec', 'dummy')
    system "bundle exec rake -f #{dummy_app_path.join('Rakefile')} db:drop "\
      'db:create db:migrate db:seed db:test:prepare'
  end
end
