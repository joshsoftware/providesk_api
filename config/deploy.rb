require 'mina/rails'
require 'mina/git'
require 'mina/version_managers/rvm'

set :application_name, 'providesk'
set :domain, '13.127.12.184'
set :deploy_to, '/www/providesk'
set :repository, 'git@github.com:joshsoftware/providesk_api.git'
set :branch, 'master'
set :user, 'ubuntu'
set :rvm_use_path, '/usr/local/rvm//bin'

set :shared_paths, ['config/database.yml', 'config/master.key','config/credentials.yml.enc','log', 'tmp', 'config/secrets.yml', "db/seeds.rb", '.env']

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
task :deploy => :environment do
  deploy do
    # Put things that will set up an empty directory into a fully set-up
    # instance of your project.
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'

    on :launch do
      invoke 'application:restart'
    end
  end
end

namespace :application do
  desc 'Start the application'
  task :start => :environment do
    #we need to stop & start the sidekiq server again
    invoke :'sidekiq:quiet'
    invoke :'sidekiq:stop'
    invoke :'sidekiq:start'
  end

  desc 'Stop the application'
  task :stop => :environment do
    invoke :'sidekiq:quiet'
    invoke :'sidekiq:stop'
  end

  desc 'Restart the application'
  task :restart => :environment do

    invoke 'application:stop'
    invoke 'application:start'
    invoke :'puma:stop'
    invoke :'puma:start'
  end
end

namespace :puma do
  desc "Start the application"
  task :start do
    command 'echo "-----> Start Puma"'
    command "cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{rails_env} && bin/puma.sh start"
  end

  desc "Stop the application"
  task :stop do
    command 'echo "-----> Stop Puma"'
    command "cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{rails_env} && bin/puma.sh stop"
  end

  desc "Restart the application"
  task :restart do
    command 'echo "-----> Restart Puma"'
    command "cd #{fetch(:deploy_to)}/current && RAILS_ENV=#{rails_env} && bin/puma.sh restart"
  end
end
