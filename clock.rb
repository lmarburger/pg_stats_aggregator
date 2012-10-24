require 'clockwork'
require 'librato/metrics'
require 'sequel'
require_relative 'pgstats'

user  = ENV['LIBRATO_METRICS_USER']
token = ENV['LIBRATO_METRICS_TOKEN']
raise 'missing LIBRATO_METRICS_USER'  unless user
raise 'missing LIBRATO_METRICS_TOKEN' unless token

Librato::Metrics.authenticate user, token

include Clockwork
counters = {}
every 15.seconds, 'postgres_performance' do
  Sequel.connect(ENV["DATABASE_URL"]) do |db|
    PGStats.new(db, counters).submit
  end
end
