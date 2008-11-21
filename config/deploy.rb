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
# Where to deploy the code to on Gawaine.
set :deploy_to, '/home/books/book-connection'

role :app, 'csx.calvin.edu'
role :web, 'csx.calvin.edu'
role :db,  'csx.calvin.edu', :primary => true

namespace :deploy do
  desc "Tell Passenger and the Ferret server to restart."
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
    run "cd #{current_path} && ruby script/ferret_server -e production stop"
    run "cd #{current_path} && ruby script/ferret_server -e production start"
  end
  
  desc "Symlink shared configs and folders on each release."
  task :symlink_shared do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'