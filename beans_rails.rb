TEMPLATES_DIR = 'http://github.com/80beans/beans_rails/raw/cleanup/templates/'

class Rails::TemplateRunner
  def app_name
    File.basename(root)
  end
  
  def template_file(template, replace = {})
    replace = {:app_name => app_name}.merge(replace)
    contents = open(File.join(TEMPLATES_DIR, template)).read
        
    replace.keys.each do |key|
      contents.gsub!("{{#{key.to_s}}}", replace[key])
    end
    
    file template, contents
  end
end

# removing unnecessary files

run "rm README"
run "rm doc/*"
run "rm log/*"
run "rm -rf test"
run "rm public/index.html"
run "rm public/images/rails.png"

# gems

gem 'haml'
gem 'mislav-will_paginate', :lib => 'will_paginate',  :source => 'http://gems.github.com'
gem 'thoughtbot-paperclip', :lib => 'paperclip',      :source => 'http://gems.github.com'

# generating haml & rspec stuff

run "haml --rails ."
generate :rspec

# updating the database file

template_file('config/database.yml')

# capistrano

if yes?('Add capistrano configuration?')
  template_file('Capfile')
  template_file('config/deploy', {:server => ask('What is the server name?')})
end

# git 

template_file('.gitignore')

git :init
git :add => "."
git :commit => "-a -m 'Initial commit'"

if yes?("Push to remote git repository? (The repository #{app_name} must be configured in Gitosis)") then
  git :remote => "add origin git@git.80beans.net:#{app_name}.git"
  git :push => 'origin master:refs/heads/master'
end