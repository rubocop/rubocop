# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::OneLineConditional do
  subject(:cop) { described_class.new }

  it 'registers an offense for one line if/then/else/end' do
    inspect_source(cop, 'if cond then run else dont end')
    expect(cop.messages).to eq(['Favor the ternary operator (`?:`)' \
                                ' over `if/then/else/end` constructs.'])
  end

  it 'does not register an offense for if/then/end' do
    inspect_source(cop, 'if cond then run end')
    expect(cop.messages).to be_empty
  end

  it 'does register an offense for one line unless/then/else/end' do
    inspect_source(cop, 'unless cond then run else dont end')
    expect(cop.messages).to eq(['Favor the ternary operator (`?:`)' \
                                ' over `unless/then/else/end` constructs.'])
  end

  it 'does not register an offense for one line unless/then/end' do
    inspect_source(cop, 'unless cond then run end')
    expect(cop.messages).to be_empty
  end
end
