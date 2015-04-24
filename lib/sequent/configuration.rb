require_relative 'core/core'

module Sequent
  class Configuration
    attr_accessor :aggregate_repository,
      :transaction_provider,
      :serializer

    attr_accessor :command_handlers,
      :command_filters,
      :command_store_adapter,
      :command_store_connection,
      :command_service

    attr_accessor :event_store,
      :event_handlers,
      :event_store_adapter,
      :event_store_connection,

    def self.instance
      @instance ||= new
    end

    def self.reset
      @instance = new
    end

    def initialize
      self.event_store = Sequent::Core::EventStore.new(self)
      self.event_store_adapter = Sequent::Core::PostgresEventStoreAdapter.new(self)
      self.event_store_connection = Sequent::Core::PostgresEventRecord

      self.command_service = Sequent::Core::CommandService.new(self)
      self.command_store_adapter = Sequent::Core::PostgresCommandStoreAdapter.new(self)
      self.command_store_connection = Sequent::Core::PostgresCommandRecord

      self.transaction_provider = Sequent::Core::Transactions::NoTransactions.new
      self.serializer = Sequent::Core::OjSerializer.new

      self.command_handlers = []
      self.command_filters = []

      self.event_handlers = []
    end

    def event_store=(event_store)
      @event_store = event_store
      self.aggregate_repository = Sequent::Core::AggregateRepository.new(event_store)
    end
  end
end
