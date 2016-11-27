require "redis"
class DB < Redis

  def self.db
    @db ||= new(:url => ENV['REDIS_URL'])
  end
end
