# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IdenticalConditionalBranches do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'on if..else with identical bodies' do
    let(:source) do
      ['if something',
       '  do_x',
       'else',
       '  do_x',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq([
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.'
                                 ])
    end
  end

  context 'on if..else with identical trailing lines' do
    let(:source) do
      ['if something',
       '  method_call_here(1, 2, 3)',
       '  do_x',
       'else',
       '  1 + 2 + 3',
       '  do_x',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq([
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.'
                                 ])
    end
  end

  context 'on if..else with identical leading lines' do
    let(:source) do
      ['if something',
       '  do_x',
       '  method_call_here(1, 2, 3)',
       'else',
       '  do_x',
       '  1 + 2 + 3',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages).to eq([
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.'
                                 ])
    end
  end

  context 'on if..elsif with no else' do
    let(:source) do
      ['if something',
       '  do_x',
       'elsif something_else',
       '  do_x',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on if..else with slightly different trailing lines' do
    let(:source) do
      ['if something',
       '  do_x(1)',
       'else',
       '  do_x(2)',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on case with identical bodies' do
    let(:source) do
      ['case something',
       'when :a',
       '  do_x',
       'when :b',
       '  do_x',
       'else',
       '  do_x',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(3)
      expect(cop.messages).to eq([
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.'
                                 ])
    end
  end

  # Regression: https://github.com/bbatsov/rubocop/issues/3868
  context 'when one of the case branches is empty' do
    let(:source) do
      ['case value',
       'when cond1',
       'else',
       '  if cond2',
       '  else',
       '  end',
       'end']
    end

    it 'does not register an offense' do
      expect(cop.offenses).to be_empty
    end
  end

  context 'on case with identical trailing lines' do
    let(:source) do
      ['case something',
       'when :a',
       '  x1',
       '  do_x',
       'when :b',
       '  x2',
       '  do_x',
       'else',
       '  x3',
       '  do_x',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(3)
      expect(cop.messages).to eq([
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.'
                                 ])
    end
  end

  context 'on case with identical leading lines' do
    let(:source) do
      ['case something',
       'when :a',
       '  do_x',
       '  x1',
       'when :b',
       '  do_x',
       '  x2',
       'else',
       '  do_x',
       '  x3',
       'end']
    end

    it 'registers an offense' do
      expect(cop.offenses.size).to eq(3)
      expect(cop.messages).to eq([
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.',
                                   'Move `do_x` out of the conditional.'
                                 ])
    end
  end

  context 'on case without else' do
    let(:source) do
      ['case something',
       'when :a',
       '  do_x',
       'when :b',
       '  do_x',
       'end']
    end

    it "doesn't register an offense" do
      expect(cop.offenses).to be_empty
    end
  end
end
