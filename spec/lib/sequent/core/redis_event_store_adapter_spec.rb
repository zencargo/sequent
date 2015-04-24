require 'spec_helper'
require './lib/sequent/core/redis_event_store_adapter'
require 'redis'

describe Sequent::Core::RedisEventStoreAdapter do
  before do
    Sequent.configure do |c|
      c.event_store_connection = Redis.new(db: 15)
      c.event_store_adapter = described_class.new(c)
      c.command_store_adapter = double(store: true)
    end
    @event_store = Sequent.configuration.event_store
    Sequent.configuration.event_store_connection.flushall
  end

  class TestEventOne < Sequent::Core::Event
    attrs foo: String, baz: Integer
  end
  class TestEventTwo < Sequent::Core::Event
    attrs ohai: Integer, sudoku: String
  end

  let(:command) { double(attributes: {}) }
  let(:event1) { TestEventOne.new(aggregate_id: '010101', foo: 'bar', baz: 1010) }
  let(:event2) { TestEventTwo.new(aggregate_id: '121212', ohai: 2345, sudoku: "10.0") }

  it 'saves and loads events' do
    @event_store.commit_events(command, [event1, event2])
    expect(@event_store.load_events('010101')).to eq [event1]
    expect(@event_store.load_events('121212')).to eq [event2]
  end
end
