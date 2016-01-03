# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Force do
  subject(:force) { described_class.new(cops) }
  let(:cops) { [double('cop1'), double('cop2')] }

  describe '.force_name' do
    it 'returns the class name without namespace' do
      expect(RuboCop::Cop::VariableForce.force_name).to eq('VariableForce')
    end
  end

  describe '#run_hook' do
    it 'invokes a hook in all cops' do
      cops.each do |cop|
        expect(cop).to receive(:some_hook).with(:foo, :bar)
      end

      force.run_hook(:some_hook, :foo, :bar)
    end

    it 'does not invoke a hook if the cop does not respond to the hook' do
      expect(cops.last).to receive(:some_hook).with(:foo, :bar)
      force.run_hook(:some_hook, :foo, :bar)
    end
  end
end
