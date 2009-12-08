set :username, "#{application}_staging"
set :branch, 'master'
set :deploy_to, "/home/#{application}_staging/app"

set :rails_env, 'staging'

role :app, 'staging.80beans.net'
role :web, 'staging.80beans.net'
role :db,  'staging.80beans.net', :primary => true

ssh_options[:username] = username