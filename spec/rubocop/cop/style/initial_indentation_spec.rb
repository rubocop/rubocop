# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::InitialIndentation do
  subject(:cop) { described_class.new }

  it 'registers an offense for indented method definition ' do
    inspect_source(cop, ['  def f',
                         '  end'])
    expect(cop.messages).to eq(['Indentation of first line in file detected.'])
  end

  it 'accepts unindented method definition' do
    inspect_source(cop, ['def f',
                         'end'])
    expect(cop.offenses).to be_empty
  end

  context 'for a file with byte order mark' do
    let(:bom) { "\xef\xbb\xbf" }

    it 'accepts unindented method call' do
      inspect_source(cop, bom + 'puts 1')
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for indented method call' do
      inspect_source(cop, bom + '  puts 1')
      expect(cop.offenses.size).to eq(1)
    end

    it 'registers an offense for indented method call after comment' do
      inspect_source(cop, [bom + '# comment',
                           '  puts 1'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  it 'accepts empty file' do
    inspect_source(cop, '')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for indented assignment disregarding comment' do
    inspect_source(cop, [' # comment',
                         ' x = 1'])
    expect(cop.highlights).to eq(['x'])
  end

  it 'accepts unindented comment + assignment' do
    inspect_source(cop, ['# comment',
                         'x = 1'])
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects indented method definition' do
    corrected = autocorrect_source(cop, ['  def f',
                                         '  end'])
    expect(corrected).to eq ['def f',
                             '  end'].join("\n")
  end

  it 'auto-corrects indented assignment but not comment' do
    corrected = autocorrect_source(cop, ['  # comment',
                                         '  x = 1'])
    expect(corrected).to eq ['  # comment',
                             'x = 1'].join("\n")
  end
end
