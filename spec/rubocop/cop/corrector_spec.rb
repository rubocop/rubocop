# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Corrector do
  describe '#rewrite' do
    it 'allows removal of a range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.remove(node.loc.operator)
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true  false'
    end

    it 'allows insertion before a source range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.insert_before(node.loc.operator, ';nil ')
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true ;nil and false'
    end

    it 'allows insertion after a source range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.insert_after(node.loc.operator, ' nil;')
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true and nil; false'
    end

    it 'allows replacement of a range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.replace(node.loc.operator, 'or')
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true or false'
    end
  end
end
