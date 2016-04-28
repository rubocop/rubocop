# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IfWithSemicolon do
  subject(:cop) { described_class.new }

  it 'registers an offense for one line if/;/end' do
    inspect_source(cop, 'if cond; run else dont end')
    expect(cop.messages).to eq(
      ['Do not use if x; Use the ternary operator instead.']
    )
  end

  it 'accepts one line if/then/end' do
    inspect_source(cop, 'if cond then run else dont end')
    expect(cop.messages).to be_empty
  end

  it 'can handle modifier conditionals' do
    inspect_source(cop, ['class Hash',
                         'end if RUBY_VERSION < "1.8.7"'])
    expect(cop.messages).to be_empty
  end
end
