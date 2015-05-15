module Sequent
  module Core
    class PostgresEventStoreAdapter
      attr_accessor :configuration

      def initialize(configuration)
        self.configuration = configuration
      end

      def store(aggregate_id, events)
        events.each do |(event, event_json)|
          connection.create!(event: event, event_json: event_json)
        end
      end

      def load(aggregate_id)
        connection.connection.select_all("select event_type, event_json from #{connection.table_name} where aggregate_id = '#{aggregate_id}' order by sequence_number asc")
      end

      private

      def connection
        configuration.event_store_connection
      end
    end
  end
end
