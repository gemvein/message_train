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
require 'rake'

require 'juwelier'
Juwelier::Tasks.new do |gem|
  # gem is a Gem::Specification...
  # see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = 'message_train'
  gem.homepage = 'http://www.gemvein.com/museum/cases/message_train'
  gem.license = 'MIT'
  gem.summary = 'Rails 4 & 5 Engine providing messaging for any object'
  gem.description = 'Rails 4 & 5 Engine providing private and public messaging'\
                    ' for any object, such as Users or Groups'
  gem.email = 'karen.e.lundgren@gmail.com'
  gem.authors = ['Karen Lundgren']
end
Juwelier::RubygemsDotOrgTasks.new

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
Rake::RDocTask.new do |rdoc|
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
  desc 'Clean out development system files'
  task files: :environment do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/development/*/*"])
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
