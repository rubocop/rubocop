# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Lint::UselessElseWithoutRescue do
  subject(:cop) { described_class.new }

  before do
    inspect_source(cop, source)
  end

  context 'with `else` without `rescue`' do
    let(:source) do
      [
        'begin',
        '  do_something',
        'else',
        '  handle_unknown_errors',
        'end'
      ]
    end

    it 'registers an offence' do
      expect(cop.offences.size).to eq(1)
      expect(cop.offences.first.message)
        .to eq('Else without rescue is useless')
      expect(cop.highlights).to eq(['else'])
    end
  end

  context 'with `else` with `rescue`' do
    let(:source) do
      [
        'begin',
        '  do_something',
        'rescue ArgumentError',
        '  handle_argument_error',
        'else',
        '  handle_unknown_errors',
        'end'
      ]
    end

    it 'accepts' do
      expect(cop.offences).to be_empty
    end
  end
end
