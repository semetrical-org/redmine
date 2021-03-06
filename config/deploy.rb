# frozen_string_literal: true

set :application, 'redmine'
set :repo_url, 'git@github.com:semetrical-org/redmine.git'

set :linked_files, %w[.env config/puma.rb]
set :linked_dirs, %w[log files tmp/pids tmp/cache tmp/sockets vendor/bundle]
set :format, :pretty
set :log_level, :info # :debug :error :info

set :deploy_to, "/var/www/#{fetch(:application)}"

set :pty, false

set :nvm_type, :system
set :nvm_node, 'v10.19.0'
set :nvm_map_bins, %w[node npm yarn webpack rake]

set :rvm_ruby_version, 'ruby-2.5.7'
set :rvm_type, :system

fetch(:rvm_map_bins, []).push 'foreman'
fetch(:bundle_bins, []).push 'foreman'

set :foreman_systemd_target_path, release_path
set :foreman_systemd_user, 'deploy'

set :maintenance_timeout, 10

before 'deploy', 'maintenance:enable'
after 'deploy', 'foreman_systemd:stop'
after 'deploy', 'foreman_systemd:setup'
after 'deploy', 'maintenance:disable'
