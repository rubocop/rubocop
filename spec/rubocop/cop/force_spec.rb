# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Force do
  subject(:force) { described_class.new(cops) }

  let(:cops) do
    [
      instance_spy(RuboCop::Cop::Cop),
      instance_spy(RuboCop::Cop::Cop)
    ]
  end

  describe '.force_name' do
    it 'returns the class name without namespace' do
      expect(RuboCop::Cop::VariableForce.force_name).to eq('VariableForce')
    end
  end

  describe '#run_hook' do
    it 'invokes a hook in all cops' do
      force.run_hook(:message, :foo)

      expect(cops).to all(have_received(:message).with(:foo))
    end
  end
end
