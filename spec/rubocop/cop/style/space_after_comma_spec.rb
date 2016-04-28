# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::SpaceAfterComma do
  subject(:cop) { described_class.new }

  shared_examples 'ends with an item' do |items, correct_items|
    it 'registers an offense' do
      inspect_source(cop, source.call(items))
      expect(cop.messages).to eq(
        ['Space missing after comma.']
      )
    end

    it 'does auto-correction' do
      new_source = autocorrect_source(cop, source.call(items))
      expect(new_source).to eq source.call(correct_items)
    end
  end

  shared_examples 'trailing comma' do |items|
    it 'accepts the last comma' do
      inspect_source(cop, source.call(items))
      expect(cop.messages).to be_empty
    end
  end

  context 'block argument commas without space' do
    let(:source) { ->(args) { "each { |#{args}| }" } }

    it_behaves_like 'ends with an item', 's,t', 's, t'
    it_behaves_like 'trailing comma', 's, t,'
  end

  context 'array index commas without space' do
    let(:source) { ->(items) { "formats[#{items}]" } }

    it_behaves_like 'ends with an item', '0,1', '0, 1'
    it_behaves_like 'trailing comma', '0,'
  end

  context 'method call arg commas without space' do
    let(:source) { ->(args) { "a(#{args})" } }

    it_behaves_like 'ends with an item', '1,2', '1, 2'
  end
end
