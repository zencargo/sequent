require 'active_record'

module Sequent
  module Core
    class PostgresEventRecord < ActiveRecord::Base
      validates_presence_of :aggregate_id, :sequence_number, :event_type, :event_json
      validates_numericality_of :sequence_number

      def event=(event)
        self.aggregate_id = event.aggregate_id
        self.sequence_number = event.sequence_number
        self.organization_id = event.organization_id if event.respond_to?(:organization_id)
        self.event_type = event.class.name
        self.created_at = event.created_at
      end
    end
  end
end
