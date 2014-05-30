# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::InlineComment do
  it 'registers an offense for a inline comment' do
    code = 'two = 1 + 1 # An inline comment'

    expect(subject).to find_offenses_in(code)
      .with_message('Avoid inline comments.')
      .with_highlight('# An inline comment')
  end
end
