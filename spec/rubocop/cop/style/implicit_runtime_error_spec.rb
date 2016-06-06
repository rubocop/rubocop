# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ImplicitRuntimeError do
  subject(:cop) { described_class.new }

  it 'registers an offense for raise "message"' do
    inspect_source(cop, 'raise "message"')
    expect(cop.offenses.size).to eq 1
    expect(cop.messages).to eq(['Use `raise` with an explicit exception ' \
                                'class and message, rather than just a ' \
                                'message.'])
    expect(cop.highlights).to eq(['raise "message"'])
  end

  it "doesn't register an offense for raise StandardError, 'message'" do
    inspect_source(cop, 'raise StandardError, "message"')
    expect(cop.offenses).to be_empty
  end
end
