require 'mina/rails'
require 'mina/git'
require 'mina/bundler'
require 'mina/default'
require 'mina/deploy'
require 'mina/rvm'

set :repository, 'git@github.com:joshsoftware/providesk_api.git'
set :user, 'ubuntu'
set :forward_agent, true

set :shared_dirs, [
  'log',
  'tmp'
]

set :shared_files, [
  'config/database.yml',
  'config/master.key',
  'config/credentials.yml.enc',
  'config/secrets.yml',
  'db/seeds.rb',
  '.env'
]

server = ENV['server'] || 'staging'

case server
when 'staging'
  set :deploy_to, '/www/providesk'
  set :domain, 'providesk-stage.joshsoftware.com'
  set :branch, ENV['branch'] || 'staging'
  set :rails_env, 'staging'
when 'production'
  set :deploy_to, '/www/providesk'
  set :domain, 'providesk.joshsoftware.com'
  set :branch, ENV['branch'] || 'master'
  set :rails_env, 'production'
end

task :remote_environment do
  # For those using RVM, use this to load an RVM version@gemset.
  invoke :'rvm:use', '3.0.0'
end

# Put any custom mkdir's in here for when `mina setup` is ran.
# For Rails apps, we'll make some of the shared paths that are shared between
# all releases.
task :setup => :remote_environment do
  command %{mkdir -p "#{fetch(:deploy_to)}/shared/log"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/config/initializers"}

  command %{chmod -R g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"}
  command %{touch "#{fetch(:deploy_to)}/shared/config/credentials.yml.enc"}
  command %{chmod g+rx, u+rwx "#{fetch(:deploy_to)}/shared/config/credentials.yml.enc"}

  command %{touch "#{fetch(:deploy_to)}/shared/config/master.key"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config/master.key"}

  command %{touch "#{fetch(:deploy_to)}/shared/config/database.yml"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config/database.yml"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/tmp"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/tmp/pids"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/pids"}

  command %{mkdir -p "#{fetch(:deploy_to)}/shared/tmp/sockets"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/tmp/sockets"}

  command %{touch "#{fetch(:deploy_to)}/shared/.env"}
  command %{chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/.env"}
end

desc "Deploys the current version to the server."
task :deploy => :remote_environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :remote_environment
      invoke 'pm2 restart /www/providesk_ecosystem.config.js'
    end
  end
end
