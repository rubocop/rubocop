# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Force do
  subject(:force) { described_class.new(cops) }

  let(:cops) { [instance_double(RuboCop::Cop::Cop), instance_double(RuboCop::Cop::Cop)] }

  describe '.force_name' do
    it 'returns the class name without namespace' do
      expect(RuboCop::Cop::VariableForce.force_name).to eq('VariableForce')
    end
  end

  describe '#run_hook' do
    it 'invokes a hook in all cops' do
      expect(cops).to all receive(:message).with(:foo)

      force.run_hook(:message, :foo)
    end
  end
end
