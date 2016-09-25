# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::ReverseEach do
  subject(:cop) { described_class.new }

  it 'registers an offense when each is called on reverse' do
    inspect_source(cop, '[1, 2, 3].reverse.each { |e| puts e }')

    expect(cop.messages)
      .to eq(['Use `reverse_each` instead of `reverse.each`.'])
  end

  it 'does not register an offense when reverse is used without each' do
    inspect_source(cop, '[1, 2, 3].reverse')

    expect(cop.messages).to be_empty
  end

  it 'does not register an offense when each is used without reverse' do
    inspect_source(cop, '[1, 2, 3].each { |e| puts e }')

    expect(cop.messages).to be_empty
  end

  context 'autocorrect' do
    it 'corrects reverse.each to reverse_each' do
      new_source = autocorrect_source(cop, '[1, 2].reverse.each { |e| puts e }')

      expect(new_source).to eq('[1, 2].reverse_each { |e| puts e }')
    end
  end
end
