# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::InlineComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for a trailing inline comment' do
    inspect_source(cop, 'two = 1 + 1 # A trailing inline comment')

    expect(cop.offenses.size).to eq(1)
    expect(cop.messages).to eq(['Avoid trailing inline comments.'])
    expect(cop.highlights).to eq(['# A trailing inline comment'])
  end

  it 'does not register an offense for a standalone comment' do
    inspect_source(cop, '# A standalone comment')

    expect(cop.offenses).to be_empty
  end
end
