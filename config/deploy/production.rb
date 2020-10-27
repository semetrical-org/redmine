# frozen_string_literal: true

server '95.216.161.154', user: 'deploy', roles: %w[web app db], foreman_systemd_concurrency: 'web=1,worker=1'

set :branch, :master
set :rails_env, 'production'
