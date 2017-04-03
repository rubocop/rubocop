# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::EmptyLinesAroundMethodDefinition do
  subject(:cop) { described_class.new }

  it 'requires blank line before method definition' do
    inspect_source(cop,
                   ['class Test',
                    '  def test',
                    '    do_something',
                    '  end',
                    '',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use empty line before method definition.'])
  end

  it 'requires blank line after method definition' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  def test',
                    '    do_something',
                    '  end',
                    'end'])
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use empty line after method definition.'])
  end

  it 'does not register offences for valid code' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  def test',
                    '    do_something',
                    '  end',
                    '',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'ignores comment before method definition' do
    inspect_source(cop,
                   ['class Test',
                    '',
                    '  # This comment is fine',
                    '  def test',
                    '    do_something',
                    '  end',
                    '',
                    'end'])
    expect(cop.offenses).to be_empty
  end

  it 'requires blank line before and after method definition' do
    inspect_source(cop,
                   ['def test',
                    '  do_something',
                    'end'])
    expect(cop.offenses.size).to eq(2)
    expect(cop.messages)
      .to eq(['Use empty line before method definition.',
              'Use empty line after method definition.'])
  end

  context 'single line methods' do
    it 'requires blank line before first one liner' do
      inspect_source(cop,
                     ['class Test',
                      '  def test; end',
                      '  def test; end',
                      '',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use empty line before method definition.'])
    end

    it 'requires blank after last one liner' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  def test; end',
                      '  def test; end',
                      'end'])
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(['Use empty line after method definition.'])
    end

    it 'does not register offences for valid code' do
      inspect_source(cop,
                     ['class Test',
                      '',
                      '  def test; end',
                      '  def test; end',
                      '',
                      '  def test',
                      '    do_something',
                      '  end',
                      '',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end
end
