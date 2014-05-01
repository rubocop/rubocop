# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::Style::InlineComment do
  it 'registers an offense for a inline comment' do
    code = 'two = 1 + 1 # An inline comment'

    expect(subject).to find_offenses_in(code)
  end
end
