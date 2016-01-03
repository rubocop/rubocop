# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::LstripRstrip do
  subject(:cop) { described_class.new }

  it 'autocorrects str.lstrip.rstrip' do
    new_source = autocorrect_source(cop, 'str.lstrip.rstrip')
    expect(new_source).to eq 'str.strip'
  end

  it 'autocorrects str.rstrip.lstrip' do
    new_source = autocorrect_source(cop, 'str.rstrip.lstrip')
    expect(new_source).to eq 'str.strip'
  end

  it 'formats the error message correctly for str.lstrip.rstrip' do
    inspect_source(cop, 'str.lstrip.rstrip')
    expect(cop.messages).to eq(['Use `strip` instead of `lstrip.rstrip`.'])
  end
end
