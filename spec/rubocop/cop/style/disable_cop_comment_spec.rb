# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::DisableCopComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for a rubocop:disable comment' do
    inspect_source(cop, ['# rubocop:disable Metrics/MethodLength',
                         'def m',
                         'end'])
    expect(cop.messages)
      .to eq(['Cop Metrics/MethodLength disabled on lines 1..3.'])
    expect(cop.highlights).to eq(['Metrics/MethodLength'])
  end

  it 'registers one offense per cop for a comment about two cops' do
    inspect_source(cop, ['# rubocop:disable MethodLength, ClassLength',
                         'def m',
                         'end'])
    expect(cop.messages)
      .to eq(['Cop Metrics/MethodLength disabled on lines 1..3.',
              'Cop Metrics/ClassLength disabled on lines 1..3.'])
    expect(cop.highlights).to eq(%w(MethodLength ClassLength))
  end

  it 'highlights cop names in EOL comments' do
    inspect_source(cop, ['class C # rubocop:disable ClassLength',
                         '  def m',
                         '  end',
                         'end'])
    expect(cop.messages)
      .to eq(['Cop Metrics/ClassLength disabled on lines 1..1.'])
    expect(cop.highlights).to eq(%w(ClassLength))
  end

  it 'registers one offense per comment line' do
    inspect_source(cop, ['class C # rubocop:disable ClassLength',
                         '  def m # rubocop:disable LineLength',
                         '  end # rubocop:disable LineLength',
                         'end'])
    expect(cop.messages)
      .to eq(['Cop Metrics/ClassLength disabled on lines 1..1.',
              'Cop Metrics/LineLength disabled on lines 2..2.',
              'Cop Metrics/LineLength disabled on lines 3..3.'])
    expect(cop.highlights).to eq(%w(ClassLength LineLength LineLength))
  end

  it 'accepts a rubocop:enable comment' do
    inspect_source(cop,
                   ['# rubocop:enable Metrics/MethodLength'])
    expect(cop.offenses).to be_empty
  end
end
