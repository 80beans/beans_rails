set :username, "#{application}_production"
set :branch, 'master'

set :rails_env, 'production'

ssh_options[:username] = username