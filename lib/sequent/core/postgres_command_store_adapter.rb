module Sequent
  module Core
    class PostgresCommandStoreAdapter
      attr_accessor :configuration

      def initialize(configuration)
        self.configuration = configuration
      end

      def store(command, command_json)
        configuration.command_store_connection.create!(command: command, command_json: command_json)
      end

      def load(aggregate_id)
        fail 'implement me'
      end

      private

      def connection
        configuration.event_store_connection
      end
    end
  end
end
