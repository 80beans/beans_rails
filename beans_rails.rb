app_name = root.split('/').last

run "rm README"
run "rm doc/*"
run "rm log/*"
run "rm -rf test"
run "rm public/index.html"
run "rm public/images/rails.png"

gem 'haml'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'thoughtbot-paperclip', :lib => 'paperclip', :source => 'http://gems.github.com'

run "haml --rails ."
generate :rspec

file '.gitignore', <<-EOF
.DS_Store
tmp
db/schema.rb
log/*
public/uploads
public/stylesheets/*.css
EOF

file 'config/database.yml', <<-EOF
development:
  adapter: mysql
  encoding: utf8
  database: #{app_name}_dev
  username: root
  password: 
test:
  adapter: mysql
  encoding: utf8
  database: #{app_name}_test
  username: root
  password:
EOF

if yes?('Add capistrano configuration?') then
  file 'Capfile', <<-EOF
  load 'deploy' if respond_to?(:namespace) # cap2 differentiator
  Dir['vendor/plugins/*/recipes/*.rb'].each { |plugin| load(plugin) }
  load 'config/deploy'
  EOF

  server = ask('What is the server name?')
  file 'config/deploy.rb', <<-EOF
set :application, '#{app_name}'

set :scm, :git
set :repository, "git@git.80beans.net:\#{application}"
set :branch, 'master'
set :git_enable_submodules, true
set :deploy_via, :remote_cache
set :use_sudo, false

ssh_options[:forward_agent] = true
ssh_options[:username] = application

role :app, '#{server}'
role :web, '#{server}'
role :db,  '#{server}', :primary => true

set :deploy_to, "/home/\#{application}/app"

task :tail do
  run "tail -f \#{deploy_to}/shared/log/production.log"
end

namespace :deploy do
  task :start, :roles => :app do
    run "touch \#{current_path}/tmp/restart.txt"
  end

  task :restart, :roles => :app do
    run "touch \#{current_path}/tmp/restart.txt"
  end
end
EOF
end

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

if yes?("Push to remote git repository? (The repository #{app_name} must be configured in Gitosis)") then
  git :remote => "add origin git@git.80beans.net:#{app_name}.git"
  git :push => 'origin master:refs/heads/master'
end