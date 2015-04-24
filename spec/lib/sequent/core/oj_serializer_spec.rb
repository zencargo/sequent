require 'spec_helper'

describe Sequent::Core::OjSerializer do
  subject(:serializer) { described_class.new }

  class RecordValueObject < Sequent::Core::ValueObject
    attrs value: String

    def initialize
      @dont_serialize_me = true
    end
  end

  class RecordCommand < Sequent::Core::Command
    attrs value: RecordValueObject
  end

  let(:value_object) { RecordValueObject.new }
  let(:command) { RecordCommand.new(aggregate_id: "1", user_id: "ben en kim", value: value_object) }

  describe "#serialize" do
    subject { serializer.deserialize(serializer.serialize(command)) }
    it 'only serializes declared attrs' do
      is_expected.to have_key('aggregate_id')
      is_expected.to have_key('value')
      expect(subject['value']).to_not have_key('dont_serialize_me')
    end
  end
end
