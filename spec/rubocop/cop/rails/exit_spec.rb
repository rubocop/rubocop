# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::Exit, :config do
  subject(:cop) { described_class.new }

  it 'registers an offense for an exit call with no receiver' do
    inspect_source(cop,
                   'exit')
    expect(cop.messages).to eq([RuboCop::Cop::Rails::Exit::MSG])
  end

  it 'registers an offense for an exit! call with no receiver' do
    inspect_source(cop,
                   'exit!')
    expect(cop.messages).to eq([RuboCop::Cop::Rails::Exit::MSG])
  end

  context 'exit calls on objects' do
    it 'does not register an offense for an explicit exit call on an object' do
      inspect_source(cop,
                     'Object.new.exit')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for an explicit exit call '\
      'with an argument on an object' do
      inspect_source(cop,
                     'Object.new.exit(0)')
      expect(cop.offenses).to be_empty
    end

    it 'does not register an offense for an explicit exit! call on an object' do
      inspect_source(cop,
                     'Object.new.exit!(0)')
      expect(cop.offenses).to be_empty
    end
  end

  context 'with arguments' do
    it 'registers an offense for an exit(0) call with no receiver' do
      inspect_source(cop,
                     'exit(0)')
      expect(cop.offenses.size).to eq(1)
    end

    it 'ignores exit calls with unexpected number of parameters' do
      inspect_source(cop,
                     'exit(1, 2)')
      expect(cop.offenses).to be_empty
    end
  end

  context 'explicit calls' do
    it 'does register an offense for explicit Kernel.exit calls' do
      inspect_source(cop,
                     'Kernel.exit')
      expect(cop.messages).to eq([RuboCop::Cop::Rails::Exit::MSG])
    end

    it 'does register an offense for explicit Process.exit calls' do
      inspect_source(cop,
                     'Process.exit')
      expect(cop.messages).to eq([RuboCop::Cop::Rails::Exit::MSG])
    end
  end
end
