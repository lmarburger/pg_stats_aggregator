require 'metriks'
require 'metriks/reporter/librato_metrics'
user  = ENV['LIBRATO_METRICS_USER']
token = ENV['LIBRATO_METRICS_TOKEN']
raise 'missing LIBRATO_METRICS_USER'  unless user
raise 'missing LIBRATO_METRICS_TOKEN' unless token
on_error = ->(e) do STDOUT.puts("LibratoMetrics: #{ e.message }") end
Metriks::Reporter::LibratoMetrics.new(user, token, on_error: on_error).start

require 'clockwork'
require './pgstats'
include Clockwork
every 15.seconds, 'postgres_performance' do
  PGStats.collect do |name, value|
    Metriks.meter("postgres.#{ name }").update(value)
  end
end

class Metriks::Meter
  # Shouldn't need a mutex here since this runs in a single process which should
  # be the only process updating the meters.
  def update(total)
    if count == 0
      @count.value = total
    else
      mark total - count
    end
  end
end
