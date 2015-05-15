require 'active_record'

module Sequent
  module Core
    class PostgresEventRecord < ActiveRecord::Base
      self.table_name = 'event_records'

      validates_presence_of :aggregate_id, :sequence_number, :event_type, :event_json
      validates_numericality_of :sequence_number

      def event=(event)
        self.aggregate_id = event.aggregate_id
        self.sequence_number = event.sequence_number
        self.event_type = event.class.name
        self.created_at = event.created_at
      end
    end
  end
end
