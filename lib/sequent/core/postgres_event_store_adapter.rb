module Sequent
  module Core
    class PostgresEventStoreAdapter
      def store(events)
        events.each do |event|
          Sequent::Core::EventRecord.create!(:command_record => command_record, :event => event)
        end
      end

      def load(aggregate_id)
        Sequent::Core::EventRecord.connection.select_all("select event_type, event_json from #{Sequent::Core::EventRecord.table_name} where aggregate_id = '#{aggregate_id}' order by sequence_number asc")
      end
    end
  end
end
