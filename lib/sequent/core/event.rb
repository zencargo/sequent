require 'active_model'
require_relative 'helpers/string_support'
require_relative 'helpers/equal_support'
require_relative 'helpers/attribute_support'
require_relative 'helpers/copyable'

module Sequent
  module Core
    class Event
      include Sequent::Core::Helpers::StringSupport,
              Sequent::Core::Helpers::EqualSupport,
              Sequent::Core::Helpers::AttributeSupport,
              Sequent::Core::Helpers::Copyable
      attrs aggregate_id: String,
        sequence_number: Integer,
        created_at: DateTime,
        event_type: String

      def initialize(args = {})
        update_all_attributes args
        raise "Missing aggregate_id" unless @aggregate_id
        @created_at ||= DateTime.now
        self.event_type = self.class.name
      end

      def payload
        result = {}
        instance_variables
          .reject { |k| not_payload_variables.include?(k) }
          .select { |k| self.class.types.keys.include?(to_attribute_name(k))}
          .each do |k|
          result[k.to_s[1 .. -1].to_sym] = instance_variable_get(k)
        end
        result
      end

      protected

      def not_payload_variables
        %i{@aggregate_id @sequence_number @created_at @event_type}
      end

      private

      def to_attribute_name(instance_variable_name)
        instance_variable_name[1 .. -1].to_sym
      end
    end
  end
end


