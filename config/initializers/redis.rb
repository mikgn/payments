# frozen_string_literal: true

module RedisConn
  def self.current
    @redis ||= Redis.new(url: ENV.fetch("REDIS_URL") { "redis://localhost:6379" })
  end
end
