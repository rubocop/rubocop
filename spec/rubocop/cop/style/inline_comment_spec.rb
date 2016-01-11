# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::InlineComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for a inline comment' do
    inspect_source(cop, 'two = 1 + 1 # An inline comment')

    expect(cop.messages).to eq(['Avoid inline comments.'])
    expect(cop.highlights).to eq(['# An inline comment'])
  end
end
