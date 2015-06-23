require 'bunny'

module Provide
  class AMQP
    HOST = 'mfrm1.provide.services'
    SUBSCRIBE_QUEUE = 'MFMRM'
    PUBLISH_QUEUE = 'provide'
    USERNAME = 'provide'
    PASSWORD = 'provide'
    
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
        conn = Bunny.new(host: HOST, user: USERNAME, password: PASSWORD)
        conn.start
      end
    end
  end
end
