require 'mongrel_cluster/recipes'

##
# The name of the application.
set :application, 'books'

##
# The repository where the application is stored.
set :repository, 'git://github.com/SeiferSays/book-connection.git'

##
# Sets our source control manager to Git.
set :scm, :git

##
# Tells Capistrano to pull from the master (read: trunk) branch.
set :branch, 'master'

##
# Forces a GitHub password prompt.
default_run_options[:pty] = true

##
# Remote caching will keep a local git repo on the server you’re deploying to and simply run a
# fetch from that rather than an entire clone. This is probably the best option and will only fetch
# the differences each deploy
set :deploy_via, :remote_cache

##
# The username on Gawaine.
set :user, 'books'

##
# Keeps Capistrano within its bounds.
set :use_sudo, false

##
# Prompts for the GitHub password.
#set :scm_password, Proc.new { Capistrano::CLI::password_prompt('GitHub Password: ') }

##
# Where to deploy the code to on Gawaine.
set :deploy_to, '/home/books/book-connection'

##
# Where to find the Mongrel files. Soon to be removed when we move to Passenger.
set :mongrel_conf, "#{current_path}/mongrel_cluster.yml"

role :app, 'csx.calvin.edu'
role :web, 'csx.calvin.edu'
role :db,  'csx.calvin.edu', :primary => true

namespace :deploy do
  task :restart do
    run "cd #{current_path} && mongrel_rails cluster::restart"
    run "cd #{current_path} && ruby script/ferret_server -e production stop"
    run "cd #{current_path} && ruby script/ferret_server -e production start"
  end
end
