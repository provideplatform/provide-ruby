require 'bunny'

module Provide
  class AMQP
    def initialize
      @queues = { }
    end
    
    def channel
      @channel ||= begin
        conn.create_channel
      end
    end
    
    def process_queue(name)
      q = queue(name)
      while q.message_count > 0
        delivery_info, metadata, payload = q.pop
        yield payload if block_given?
      end
    end
    
    def queue(name)
      @queues[name.to_sym] ||= begin
        @queues[name.to_sym] = channel.queue(name, durable: true)
      end
    end
    
    private
    
    def conn
      @conn ||= begin
        host = ENV['AMQP_HOST'] || 'localhost'
        username = ENV['AMQP_USERNAME']
        password = ENV['AMQP_PASSWORD']

        conn = username && password ? Bunny.new(host: host, user: username, password: password) : Bunny.new(host: host)
        conn.start
      end
    end
  end
end
