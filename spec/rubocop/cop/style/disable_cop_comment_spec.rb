# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::DisableCopComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for a rubocop:disable comment' do
    inspect_source(cop, ['# rubocop:disable Metrics/MethodLength',
                         'def m',
                         'end'])
    expect(cop.messages).to eq(['Do not disable cops with inline comments.'])
    expect(cop.highlights).to eq(['# rubocop:disable Metrics/MethodLength'])
  end

  it 'registers one offense for a comment about two cops' do
    inspect_source(cop, ['# rubocop:disable MethodLength, ClassLength',
                         'def m',
                         'end'])
    expect(cop.highlights)
      .to eq(['# rubocop:disable MethodLength, ClassLength'])
  end

  it 'accepts a rubocop:enable comment' do
    inspect_source(cop,
                   ['# rubocop:enable Metrics/MethodLength'])
    expect(cop.offenses).to be_empty
  end
end
