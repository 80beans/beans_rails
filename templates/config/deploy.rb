set :default_stage, 'staging'

require 'erb'
require 'capistrano/ext/multistage' # needs the capistrano-ext gem
require 'recipes/beans_server'

set :application, '{{app_name}}'

set :scm, :git
set :repository, "git@git.80beans.net:#{application}"
set :git_enable_submodules, true
set :deploy_via, :remote_cache
set :use_sudo, false
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
ssh_options[:username] = application


set :deploy_to, "/home/#{application}/app"

task :tail do
  run "tail -f #{deploy_to}/shared/log/production.log"
end

namespace :deploy do
  
  task :finalize_update, :roles => :app do
    run "ln -s #{shared_path}/log #{release_path}/log"
    run "ln -s #{shared_path}/tmp #{release_path}/tmp" 
    run "ln -s #{shared_path}/uploads #{release_path}/public/uploads" 
  end
  
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
end

task :create_symlinked_folders do
  run "mkdir -p #{shared_path}/tmp"
  run "mkdir -p #{shared_path}/uploads"
end

after "deploy:setup", :create_symlinked_folders