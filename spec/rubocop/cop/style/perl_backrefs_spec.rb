# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::PerlBackrefs do
  subject(:cop) { described_class.new }

  it 'registers an offense for $1' do
    inspect_source(cop, 'puts $1')
    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects $1 to Regexp.last_match[1]' do
    new_source = autocorrect_source(cop, '$1')
    expect(new_source).to eq('Regexp.last_match(1)')
  end

  it 'auto-corrects #$1 to #{Regexp.last_match[1]}' do
    new_source = autocorrect_source(cop, '"#$1"')
    expect(new_source).to eq('"#{Regexp.last_match(1)}"')
  end
end
