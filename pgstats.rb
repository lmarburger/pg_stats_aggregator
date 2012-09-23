require 'pg'
require 'uri'

class PGStats
  def self.collect
    stats = Conn.execute <<-SQL
      SELECT sum(seq_scan)  AS sequence_scans,
             sum(idx_scan)  AS index_scans,
             sum(n_tup_ins) AS inserts,
             sum(n_tup_upd) AS updates,
             sum(n_tup_del) AS deletes
      FROM pg_stat_user_tables;
    SQL
    Conn.disconnect

    stats.each do |name, value|
      yield name, value.to_i
    end

    nil
  end

  def self.log(message)
    Conn.log message
  end

  # Lovingly borrowed from queue_classic.
  module Conn
    extend self

    def execute(statement)
      log 'execute', statement.inspect
      begin
        result = []
        connection.exec(statement).each {|t| result << t}
        result.length > 1 ? result : result.pop
      rescue PGError => e
        log 'error', e.inspect
        raise
      end
    end

    def connection
      @connection ||= connect
    end

    def disconnect
      connection.finish
      @connection = nil
    end

    def connect
      conn = PGconn.connect db_url.host,
                            db_url.port || 5432,
                            nil, '', #opts, tty
                            db_url.path.gsub("/",""), # database name
                            db_url.user,
                            db_url.password
      if conn.status != PGconn::CONNECTION_OK
        log 'conn.error', conn.error
      end
      conn
    end

    def db_url
      return @db_url if @db_url
      url = ENV["DATABASE_URL"] || raise(ArgumentError, "missing DATABASE_URL")
      @db_url = URI.parse url
    end

    def log(title, message)
      puts [ title, message ].join(': ')
    end
  end
end
