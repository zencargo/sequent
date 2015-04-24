require 'spec_helper'

describe Sequent::Core::BaseCommand do

  it "includes TypeConversion" do
    expect(Sequent::Core::BaseCommand.included_modules).to include(Sequent::Core::Helpers::TypeConversionSupport)
  end

  context Sequent::Core::UpdateCommand do

    it "fails when no sequence number is given" do
      expect(Sequent::Core::UpdateCommand.new(aggregate_id: "foo").valid?).to be_falsey
    end

    it "is valid when sequence number is given" do
      expect(Sequent::Core::UpdateCommand.new(aggregate_id: "foo", sequence_number: 1).valid?).to be_truthy
    end
  end

end
