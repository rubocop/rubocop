# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IdenticalConditionalBranches do
  subject(:cop) { described_class.new }

  before(:each) do
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
                                   'Move `do_x` out of the conditional.'])
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
                                   'Move `do_x` out of the conditional.'])
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

  context 'on case with identical trailing lines' do
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
                                   'Move `do_x` out of the conditional.'])
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
