require 'spec_helper'

describe Sequent::Core::Event do

  def from_serializer(event)
    oj = Sequent::Core::OjSerializer.new
    oj.deserialize(oj.serialize(event))
  end

  class Person < Sequent::Core::ValueObject
    attrs name: String
  end

  class EventTestEvent < Sequent::Core::Event
    attrs name: String, date_time: DateTime, owner: Person
  end

  class EventWithDate < Sequent::Core::Event
    attrs date_of_birth: Date
  end

  class FooType;
  end
  class EventWithUnknownAttributeType < Sequent::Core::Event
    attrs name: FooType
  end

  class EventWithSymbol < Sequent::Core::Event
    attrs status: Symbol
  end

  it "does not include aggregate_id, sequence_number and event_type in the payload" do
    expect(
      EventTestEvent.new(
        {aggregate_id: 123, sequence_number: 7, name: "foo"}
      ).payload).to eq({ name: "foo", date_time: nil, owner: nil })
  end

  it "deserializes DateTime using iso8601" do
    now = DateTime.now
    val = now.iso8601
    event = EventTestEvent.deserialize_from_hash(
      "aggregate_id" => "bla", "sequence_number" => 1, "created_at" => val
    )
    expect(event.created_at.iso8601).to eq val
  end

  it "events are equal when deserialized from same attributes" do
    event1 = EventTestEvent.new(aggregate_id: "foo", sequence_number: 1)
    created_at = event1.created_at.iso8601
    event2 = EventTestEvent.deserialize_from_hash("aggregate_id" => "foo", "sequence_number" => 1, "created_at" => created_at, "event_type" => 'EventTestEvent')
    expect(event1).to eq event2
  end

  it "is converted from and to json and ignore validation stuff from activemodel" do
    person = Person.new({name: "foo"})
    person.valid?
    event = EventTestEvent.new(
      aggregate_id: 123, sequence_number: 7, owner: person
    )
    other = EventTestEvent.deserialize_from_hash(from_serializer(event))
    expect(other).to eq event
  end

  it "is be able to converted from and to json with a date" do
    today = Date.today
    event = EventWithDate.new(
      aggregate_id: 123, sequence_number: 7, date_of_birth: today
    )
    other = EventWithDate.deserialize_from_hash(from_serializer(event))
    expect(other).to eq event
  end

  it "fails when converting to and from Json when type is not supported" do
    event = EventWithUnknownAttributeType.new(
      aggregate_id: 123, sequence_number: 7, name: FooType.new
    )
    expect { EventWithUnknownAttributeType.deserialize_from_hash(from_serializer(event)) }.to raise_exception(NoMethodError)
  end

  it "converts symbols" do
    event = EventWithSymbol.new(aggregate_id: 123, sequence_number: 7, status: :foo)
    other = EventWithSymbol.deserialize_from_hash(from_serializer(event))
    expect(event).to eq other
  end

  it "deserializes nil symbols" do
    event = EventWithSymbol.new(aggregate_id: 123, sequence_number: 7)
    other = EventWithSymbol.deserialize_from_hash(from_serializer(event))
    expect(event).to eq other
  end

  context ".attributes" do

    it "ignores non attrs like @valid" do
      person = Person.new(name: "foo")
      person.valid?
      event = EventTestEvent.new(aggregate_id: "1", sequence_number: 2, owner: person)
      expect(event.attributes[:owner]).to_not have_key(:errors)
      expect(event.attributes[:owner]).to_not have_key(:validation_context)
    end

  end

end
