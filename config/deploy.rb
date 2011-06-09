set :application, "drugstore-map"
#set :repository,  "git@github.com:paintail/shoptweet.git"
#set :repository, "git://github.com/paintail/shoptweet.git"
set :repository, "git://github.com/paintail/drugstore-map-server.git"
#set :repository, "https://paintail@github.com/paintail/shoptweet.git"

#set :scm, :subversion
set :scm, :git
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
set :deploy_to, "/home/paintail/drugstore-map/"
set :user, "paintail"
set :password, "s8evf9"
set :use_sudo, false
ssh_options[:keys] = %w(/User/pain_tail/.ssh/id_dsa_182.48.42.80) 
ssh_options[:port] = 22 
ssh_options[:forward_agent] = true

default_run_options[:shell] = false

role :web, "182.48.42.80"                          # Your HTTP server, Apache/etc
role :app, "182.48.42.80"                          # This may be the same as your `Web` server
role :db,  "182.48.42.80", :primary => true # This is where Rails migrations will run
#role :db,  "your slave db-server here"

# If you are using Passenger mod_rails uncomment this:
# if you're still using the script/reapear helper you will need
# these http://github.com/rails/irs_process_scripts

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
