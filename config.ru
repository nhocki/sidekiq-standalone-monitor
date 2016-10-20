# frozen_string_literal: true

begin
  require 'bundler'
rescue LoadError => e
  require 'rubygems'
  require 'bundler'
end

Bundler.require(:default)
Dotenv.load if defined?(Dotenv)

require 'sidekiq/web'

Sidekiq.configure_client do |config|
  config.redis = {
    size: 1,
    url: ENV['REDIS_URL']
  }
end

module Sidekiq
  class Web
    set :github_options, {
      scopes: 'user',
      client_id: ENV['GITHUB_KEY'],
      secret: ENV['GITHUB_SECRET'],
    }

    register Sinatra::Auth::Github

    before do
      authenticate!
      github_organization_authenticate!(ENV['GITHUB_ORG'])
    end

    get '/logout' do
      logout!
      redirect ENV['LOGOUT_REDIRECT_URL']
    end
  end
end

run Sidekiq::Web
