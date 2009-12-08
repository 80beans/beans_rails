set :username, 'digital_intercedent_staging'
set :branch, 'master'
set :deploy_to, "/home/digital_intercedent_staging/app"

set :rails_env, 'staging'

role :app, 'staging.80beans.net'
role :web, 'staging.80beans.net'
role :db,  'staging.80beans.net', :primary => true

ssh_options[:username] = username