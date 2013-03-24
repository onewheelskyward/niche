set :application, "niche"
set :repository,  "git@github.com:onewheelskyward/niche"
set :scm, :git
set :user, 'akreps'
set :ssh_options, { :forward_agent => true }
set :deploy_via, :remote_cache
# Rids us of a number of annoying errors.
set :normalize_asset_timestamps, false
#set :deploy_to, "/u/apps/devops"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "pucksteak"                          # Your HTTP server, Apache/etc
role :app, "pucksteak"                          # This may be the same as your `Web` server
#role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
#after "deploy:restart", "deploy:cleanup"

namespace :niche do
	task :create_symlink do
		run "ln -s /u/apps/niche/shared/previous_results.sqlite /u/apps/niche/current/previous_results.sqlite"
	end
end

after "deploy:create_symlink", "niche:create_symlink"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
