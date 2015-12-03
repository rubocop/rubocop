# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::NextWithoutAccumulator do
  subject(:cop) { described_class.new }

  def code_without_accumulator(method_name)
    <<-SOURCE
      (1..4).#{method_name}(0) do |acc, i|
        next if i.odd?
        acc + i
      end
    SOURCE
  end

  def code_with_accumulator(method_name)
    <<-SOURCE
      (1..4).#{method_name}(0) do |acc, i|
        next acc if i.odd?
        acc + i
      end
    SOURCE
  end

  shared_examples 'reduce/inject' do |reduce_alias|
    context "given a #{reduce_alias} block" do
      it 'registers an offense for a bare next' do
        inspect_source(cop, code_without_accumulator(reduce_alias))
        expect(cop.offenses.size).to eq(1)
        expect(cop.highlights).to eq(['next'])
      end

      it 'accepts next with a value' do
        inspect_source(cop, code_with_accumulator(reduce_alias))
        expect(cop.offenses).to be_empty
      end
    end
  end

  include_examples 'reduce/inject', :reduce
  include_examples 'reduce/inject', :inject

  context 'given an unrelated block' do
    it 'accepts a bare next' do
      inspect_source(cop, code_without_accumulator(:foo))
      expect(cop.offenses).to be_empty
    end

    it 'accepts next with a value' do
      inspect_source(cop, code_with_accumulator(:foo))
      expect(cop.offenses).to be_empty
    end
  end
end
