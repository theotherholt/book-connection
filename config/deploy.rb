require 'mongrel_cluster/recipes'

set :application, 'books'
set :repository, 'svn://10.254.254.1/bookdev/trunk'

##
# This should be your username for Gawaine.
set :user, 'rah6'

##
# These options make sure that Capistrano doesn't try and do anything more than it ought to.
set :use_sudo, false
set :runner, nil

##
# This option allows us to connect to SVN with a username other than our own.
set :scm_username, 'rah6'
set :scm_password, Proc.new { Capistrano::CLI::password_prompt('SVN Password: ') }

##
# If you aren't deploying to /u/apps/#{application} on the target servers (which is the default),
# you can specify the actual location via the :deploy_to variable:
set :deploy_to, '/var/www/localhost/htdocs/books'

##
# This reference includes everything Capistrano needs to know about our Mongrel setup.
set :mongrel_conf, "#{current_path}/mongrel_cluster.yml"

role :app, '153.106.130.23'
role :web, '153.106.130.23'
role :db,  '153.106.130.23', :primary => true

namespace :deploy do
  task :restart do
    run "cd #{current_path} && mongrel_rails cluster::restart"
    run "cd #{current_path} && ruby script/ferret_server -e production stop"
    run "cd #{current_path} && ruby script/ferret_server -e production start"
  end
end
