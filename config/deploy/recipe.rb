set :deploy_to, "/home/gemma/rails/#{application}_recipe"

set :rvm_ruby_string, 'ruby-1.9.3-p547'
require "rvm/capistrano"

set :user, "gemma"
set :runner, "gemma"
set :use_sudo, false
set :rails_env, "recipe"

set :branch, "recipe"

role :app, "vps75292.ovh.net", :primary => true
role :web, "vps75292.ovh.net"
role :db,  "vps75292.ovh.net", :primary => true
