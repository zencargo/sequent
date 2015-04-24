module Sequent
  module Core
    class EventStore
      attr_accessor :configuration

      def initialize(configuration = Sequent.configuration)
        self.configuration = configuration
        @event_types = {}
      end

      ##
      # Stores the events in the EventStore and publishes the events
      # to the registered event_handlers.
      #
      def commit_events(command, events)
        store_command(command)
        store_events(events)
        publish_events(events, event_handlers)
      end

      ##
      # Returns all events for the aggregate ordered by sequence_number
      #
      def load_events(aggregate_id)
        event_store_adapter.load(aggregate_id).map do |serialized_event|
          event_from_serialized(serialized_event)
        end
      end

      ##
      # Replays all events in the event store to the registered event_handlers.
      #
      # @param block that returns the event stream.
      def replay_events
        event_stream = yield
        event_stream.each do |serialized_event|
          event = event_from_serialized(serialized_event)
          event_handlers.each do |handler|
            handler.handle_message event
          end
        end
      end

      protected

      def event_handlers
        configuration.event_handlers
      end

      private

      def publish_events(events, event_handlers)
        events.each do |event|
          event_handlers.each do |handler|
            handler.handle_message event
          end
        end
      end

      def to_events(event_records)
        event_records.map(&:event)
      end

      def event_from_serialized(serialized_event)
        event_hash = serializer.deserialize(serialized_event)
        event_type = event_hash['event_type']
        event_class(event_type).deserialize_from_hash(event_hash)
      end

      def store_command(command)
        command_store_adapter.store(command, serializer.serialize(command))
      end

      def store_events(events = [])
        events.each do |event|
          event_store_adapter.store(event.aggregate_id, [[event, serializer.serialize(event)]])
        end
      end

      private

      def event_store_adapter
        configuration.event_store_adapter
      end

      def command_store_adapter
        configuration.command_store_adapter
      end

      def serializer
        configuration.serializer
      end

      def event_class(event_type)
        unless @event_types.has_key?(event_type)
          @event_types[event_type] = Class.const_get(event_type.to_sym)
        end
        @event_types[event_type]
      end
    end
  end
end
