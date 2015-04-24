require 'active_record'

module Sequent
  module Core
    # For storing Sequent::Core::Command in the database using active_record
    class PostgresCommandRecord < ActiveRecord::Base
      self.table_name = "command_records"

      validates_presence_of :command_type, :command_json

      def command=(command)
        self.created_at = command.created_at
        self.aggregate_id = command.aggregate_id if command.respond_to? :aggregate_id
        self.organization_id = command.organization_id if command.respond_to? :organization_id
        self.user_id = command.user_id if command.respond_to? :user_id
        self.command_type = command.class.name
      end
    end
  end
end
