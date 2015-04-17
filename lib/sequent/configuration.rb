require_relative 'core/event_store'
require_relative 'core/command_service'
require_relative 'core/transactions/no_transactions'
require_relative 'core/aggregate_repository'
require_relative 'core/postgres_event_store_adapter'

module Sequent
  class Configuration
    attr_accessor :event_store,
      :command_service,
      :aggregate_repository,
      :event_store_adapter,
      :transaction_provider

    attr_accessor :command_handlers,
      :command_filters

    attr_accessor :event_handlers,

    def self.instance
      @instance ||= new
    end

    def self.reset
      @instance = new
    end

    def initialize
      self.event_store = Sequent::Core::EventStore.new(self)
      self.command_service = Sequent::Core::CommandService.new(self)
      self.event_store_adapter = Sequent::Core::PostgresEventStoreAdapter.new
      self.transaction_provider = Sequent::Core::Transactions::NoTransactions.new

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
