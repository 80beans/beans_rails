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

['README', 'doc/*', 'test', 'public/index.html', 'public/images/rails.png'].each { |file| run "rm -rf #{file}" }

# add the required gems to the environment file and install

gem 'bundler'
rake "gems:install", :sudo => true

# copy the .gitignore, database.yml and files needed for bundler to the app

['.gitignore', 'Gemfile', 'config/database.yml', 'config/preinitializer.rb'].each { |file| template_file(file) }

# copy the .gitignore and database.yml to the app

['.gitignore', 'config/database.yml'].each { |file| template_file(file) }

# generating rspec stuff

generate :rspec

# capistrano

if yes?('Add capistrano configuration?')

  # create the needed directories 
  ['config/deploy', 'config/deploy/config', 'config/deploy/templates', 'recipes'].each { |dir| run "mkdir #{dir}"}
  
  # move the templates to the app
  [ 
    'Capfile',
    'config/deploy.rb',
    'config/deploy/production.rb',
    'config/deploy/staging.rb',
    'config/deploy/config/staging.yml',
    'config/deploy/templates/database.erb',
    'config/deploy/templates/public_keys.txt',
    'config/deploy/templates/staging_vhost.erb',
    'recipes/beans_server.rb'
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
