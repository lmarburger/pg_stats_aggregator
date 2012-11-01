require 'librato/metrics'

class PGStats
  def initialize(db, counters = Hash.new, interval = 60, client = Librato::Metrics.client)
    @db       = db
    @counters = counters
    @interval = interval
    @client   = client
  end

  def stats
    @db[<<-SQL].first
      SELECT sum(seq_scan)  AS sequence_scans,
             sum(idx_scan)  AS index_scans,
             sum(n_tup_ins) AS inserts,
             sum(n_tup_upd) AS updates,
             sum(n_tup_del) AS deletes,
             (SELECT (sum(idx_blks_hit) - sum(idx_blks_read)) / sum(idx_blks_hit)
              FROM pg_statio_user_indexes) AS cache_hit_ratio
      FROM pg_stat_user_tables;
    SQL
  end

  def submit
    queue        = @client.new_queue
    measure_time = now_floored

    stats.each do |name, current_counter|
      current_counter = current_counter.to_i
      last_counter    = @counters[name]
      if last_counter && current_counter >= last_counter
        value = current_counter - last_counter
        queue.add("postgres.#{name}" => { :value        => value,
                                          :measure_time => measure_time })
      end

      @counters[name] = current_counter
    end

    queue.submit unless queue.empty?
  end

  def now_floored
    time = Time.now.to_i
    time - (time % @interval)
  end
end
