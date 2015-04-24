module Sequent
  module Core
    class RedisEventStoreAdapter
      attr_accessor :configuration

      def initialize(configuration)
        self.configuration = configuration
      end

      def store(aggregate_id, events)
        events.each do |(event, event_json)|
          connection.rpush(aggregate_id, event_json)
        end
      end

      def load(aggregate_id)
        connection.lrange(aggregate_id, 0, -1)
      end

      private

      def connection
        configuration.event_store_connection
      end
    end
  end
end
