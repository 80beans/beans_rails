TEMPLATES_DIR = 'http://github.com/80beans/beans_rails/raw/master/templates/'

class Rails::TemplateRunner
  def app_name
    File.basename(root)
  end
  
  def template_file(template, replace = {})
    replace   = {:app_name => app_name}.merge(replace)
    contents  = open(File.join(TEMPLATES_DIR, template)).read
    replace.keys.each { |key| contents.gsub!("{{#{key.to_s}}}", replace[key]) }
    file(template, contents)
  end
end

# removing unnecessary files

['README', 'doc/*', 'log/*', 'test', 'public/index.html', 'public/images/rails.png'].each { |file| run "rm -rf #{file}" }

# create the needed directories 
['config', 'deploy', 'deploy/config', 'deploy/templates'].each { |dir| run "mkdir #{dir}"}

# install bundler

gem 'bundler'
rake "gems:install", :sudo => true

# copy the .gitignore, database.yml and Gemfile to the app

['Gemfile', '.gitignore', 'config/database.yml', 'config/preinitializer.rb'].each { |file| template_file(file) }

# bundle the gems

run 'gem bundle'

# generating rspec stuff

generate :rspec

# capistrano

if yes?('Add capistrano configuration?')
[ 
  'Capfile',
  'config/deploy.rb',
  'deploy/beans_server.rb',
  'deploy/production.rb',
  'deploy/staging.rb',
  'deploy/config/staging.yml',
  'deploy/templates/database.erb',
  'deploy/templates/public_keys.txt',
  'deploy/templates/staging_vhost.erb'
].each { |file| template_file(file) }
end

# git 

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

if yes?("Push to remote git repository? (The repository #{app_name} must be configured in Gitosis)") then
  git :remote => "add origin git@git.80beans.net:#{app_name}.git"
  git :push   => 'origin master:refs/heads/master'
end
