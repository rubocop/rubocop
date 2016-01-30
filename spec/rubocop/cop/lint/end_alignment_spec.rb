# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Lint::EndAlignment, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'AlignWith' => 'keyword', 'AutoCorrect' => true }
  end
  BOM = "\xef\xbb\xbf".freeze

  include_examples 'misaligned', '', 'class',  'Test',      '  end'
  include_examples 'misaligned', '', 'module', 'Test',      '  end'
  include_examples 'misaligned', '', 'if',     'test',      '  end'
  include_examples 'misaligned', '', 'unless', 'test',      '  end'
  include_examples 'misaligned', '', 'while',  'test',      '  end'
  include_examples 'misaligned', '', 'until',  'test',      '  end'
  include_examples 'misaligned', '', 'case',   'a when b',  '  end'

  include_examples 'aligned', "#{BOM}class", 'Test', 'end'

  include_examples 'aligned', 'class',  'Test',      'end'
  include_examples 'aligned', 'module', 'Test',      'end'
  include_examples 'aligned', 'if',     'test',      'end'
  include_examples 'aligned', 'unless', 'test',      'end'
  include_examples 'aligned', 'while',  'test',      'end'
  include_examples 'aligned', 'until',  'test',      'end'
  include_examples 'aligned', 'case',   'a when b',  'end'

  include_examples 'misaligned', 'puts 1; ', 'class',  'Test',      'end'
  include_examples 'misaligned', 'puts 1; ', 'module', 'Test',      'end'
  include_examples 'misaligned', 'puts 1; ', 'if',     'test',      'end'
  include_examples 'misaligned', 'puts 1; ', 'unless', 'test',      'end'
  include_examples 'misaligned', 'puts 1; ', 'while',  'test',      'end'
  include_examples 'misaligned', 'puts 1; ', 'until',  'test',      'end'
  include_examples 'misaligned', 'puts 1; ', 'case',   'a when b',  'end'

  include_examples 'aligned', 'puts 1; class',  'Test',     '        end'
  include_examples 'aligned', 'puts 1; module', 'Test',     '        end'
  include_examples 'aligned', 'puts 1; if',     'Test',     '        end'
  include_examples 'aligned', 'puts 1; unless', 'Test',     '        end'
  include_examples 'aligned', 'puts 1; while',  'Test',     '        end'
  include_examples 'aligned', 'puts 1; until',  'Test',     '        end'
  include_examples 'aligned', 'puts 1; case',   'a when b', '        end'

  it 'can handle ternary if' do
    inspect_source(cop, 'a = cond ? x : y')
    expect(cop.offenses).to be_empty
  end

  it 'can handle modifier if' do
    inspect_source(cop, 'a = x if cond')
    expect(cop.offenses).to be_empty
  end

  context 'when AlignWith is start_of_line' do
    let(:cop_config) do
      { 'AlignWith' => 'start_of_line', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', '', 'class Test',    '', '  end'
    include_examples 'misaligned', '', 'module Test',   '', '  end'
    include_examples 'misaligned', '', 'if test',       '', '  end'
    include_examples 'misaligned', '', 'unless test',   '', '  end'
    include_examples 'misaligned', '', 'while test',    '', '  end'
    include_examples 'misaligned', '', 'until test',    '', '  end'
    include_examples 'misaligned', '', 'case a when b', '', '  end'

    include_examples 'aligned', 'puts 1; class',  'Test',     'end'
    include_examples 'aligned', 'puts 1; module', 'Test',     'end'
    include_examples 'aligned', 'puts 1; if',     'test',     'end'
    include_examples 'aligned', 'puts 1; unless', 'test',     'end'
    include_examples 'aligned', 'puts 1; while',  'test',     'end'
    include_examples 'aligned', 'puts 1; until',  'test',     'end'
    include_examples 'aligned', 'puts 1; case',   'a when b', 'end'

    include_examples 'misaligned', '', 'puts 1; class Test',    '', '  end'
    include_examples 'misaligned', '', 'puts 1; module Test',   '', '  end'
    include_examples 'misaligned', '', 'puts 1; if test',       '', '  end'
    include_examples 'misaligned', '', 'puts 1; unless test',   '', '  end'
    include_examples 'misaligned', '', 'puts 1; while test',    '', '  end'
    include_examples 'misaligned', '', 'puts 1; until test',    '', '  end'
    include_examples 'misaligned', '', 'puts 1; case a when b', '', '  end'
  end

  context 'when AlignWith is variable' do
    # same as 'AlignWith' => 'keyword', as long as assignments or `case`
    # are not involved
    let(:cop_config) do
      { 'AlignWith' => 'variable', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', '', 'class',  'Test',      '  end'
    include_examples 'misaligned', '', 'module', 'Test',      '  end'
    include_examples 'misaligned', '', 'if',     'test',      '  end'
    include_examples 'misaligned', '', 'unless', 'test',      '  end'
    include_examples 'misaligned', '', 'while',  'test',      '  end'
    include_examples 'misaligned', '', 'until',  'test',      '  end'
    include_examples 'misaligned', '', 'case',   'a when b',  '  end'

    include_examples 'aligned', 'class',  'Test',      'end'
    include_examples 'aligned', 'module', 'Test',      'end'
    include_examples 'aligned', 'if',     'test',      'end'
    include_examples 'aligned', 'unless', 'test',      'end'
    include_examples 'aligned', 'while',  'test',      'end'
    include_examples 'aligned', 'until',  'test',      'end'
    include_examples 'aligned', 'case',   'a when b',  'end'

    include_examples 'misaligned', 'puts 1; ', 'class',  'Test',      'end'
    include_examples 'misaligned', 'puts 1; ', 'module', 'Test',      'end'
    include_examples 'misaligned', 'puts 1; ', 'if',     'test',      'end'
    include_examples 'misaligned', 'puts 1; ', 'unless', 'test',      'end'
    include_examples 'misaligned', 'puts 1; ', 'while',  'test',      'end'
    include_examples 'misaligned', 'puts 1; ', 'until',  'test',      'end'
    include_examples 'misaligned', 'puts 1; ', 'case',   'a when b',  'end'

    include_examples 'aligned', 'puts 1; class',  'Test',     '        end'
    include_examples 'aligned', 'puts 1; module', 'Test',     '        end'
    include_examples 'aligned', 'puts 1; if',     'Test',     '        end'
    include_examples 'aligned', 'puts 1; unless', 'Test',     '        end'
    include_examples 'aligned', 'puts 1; while',  'Test',     '        end'
    include_examples 'aligned', 'puts 1; until',  'Test',     '        end'
    include_examples 'aligned', 'puts 1; case',   'a when b', '        end'
  end

  context 'correct + opposite' do
    let(:source) do
      ['x = if a',
       '      a1',
       '    end',
       'y = if b',
       '  b1',
       'end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first)
        .to eq('`end` at 6, 0 is not aligned with `if` at 4, 4.')
      expect(cop.highlights.first).to eq('end')
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq(['x = if a',
                               '      a1',
                               '    end',
                               'y = if b',
                               '  b1',
                               '    end'].join("\n"))
    end
  end

  context 'when end is preceded by something else than whitespace' do
    let(:source) do
      ['module A',
       'puts a end']
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages.first)
        .to eq('`end` at 2, 7 is not aligned with `module` at 1, 0.')
      expect(cop.highlights.first).to eq('end')
    end

    it "doesn't auto-correct" do
      expect(autocorrect_source(cop, source))
        .to eq(source.join("\n"))
      expect(cop.offenses.map(&:corrected?)).to eq [false]
    end
  end

  context 'case as argument' do
    context 'when AlignWith is keyword' do
      let(:cop_config) do
        { 'AlignWith' => 'keyword', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'test case', 'a when b', '     end'
      include_examples 'misaligned', 'test ', 'case', 'a when b', 'end'
    end

    context 'when AlignWith is variable' do
      let(:cop_config) do
        { 'AlignWith' => 'variable', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'test case', 'a when b', 'end'
      include_examples 'misaligned', '', 'test case', 'a when b', '     end'
    end

    context 'when AlignWith is start_of_line' do
      let(:cop_config) do
        { 'AlignWith' => 'start_of_line', 'AutoCorrect' => true }
      end

      include_examples 'aligned',        'test case a when b', '', 'end'
      include_examples 'misaligned', '', 'test case a when b', '', '     end'
    end
  end

  context 'regarding assignment' do
    context 'when AlignWith is keyword' do
      include_examples 'misaligned', 'var = ', 'if',     'test',     'end'
      include_examples 'misaligned', 'var = ', 'unless', 'test',     'end'
      include_examples 'misaligned', 'var = ', 'while',  'test',     'end'
      include_examples 'misaligned', 'var = ', 'until',  'test',     'end'
      include_examples 'misaligned', 'var = ', 'case',   'a when b', 'end'

      include_examples 'aligned', 'var = if',     'test',     '      end'
      include_examples 'aligned', 'var = unless', 'test',     '      end'
      include_examples 'aligned', 'var = while',  'test',     '      end'
      include_examples 'aligned', 'var = until',  'test',     '      end'
      include_examples 'aligned', 'var = case',   'a when b', '      end'
    end

    context 'when AlignWith is variable' do
      let(:cop_config) do
        { 'AlignWith' => 'variable', 'AutoCorrect' => true }
      end

      include_examples 'aligned', 'var = if',     'test',     'end'
      include_examples 'aligned', 'var = unless', 'test',     'end'
      include_examples 'aligned', 'var = while',  'test',     'end'
      include_examples 'aligned', 'var = until',  'test',     'end'
      include_examples 'aligned', 'var = until',  'test',     'end.ab.join("")'
      include_examples 'aligned', 'var = until',  'test',     'end.ab.tap {}'
      include_examples 'aligned', 'var = case',   'a when b', 'end'

      include_examples 'aligned', "var =\n  if",  'test', '  end'

      include_examples 'misaligned', '', 'var = if',     'test',     '      end'
      include_examples 'misaligned', '', 'var = unless', 'test',     '      end'
      include_examples 'misaligned', '', 'var = while',  'test',     '      end'
      include_examples 'misaligned', '', 'var = until',  'test',     '      end'
      include_examples 'misaligned', '', 'var = until',  'test',     '    end.j'
      include_examples 'misaligned', '', 'var = case',   'a when b', '      end'

      include_examples 'aligned', '@var = if',  'test', 'end'
      include_examples 'aligned', '@@var = if', 'test', 'end'
      include_examples 'aligned', '$var = if',  'test', 'end'
      include_examples 'aligned', 'CNST = if',  'test', 'end'
      include_examples 'aligned', 'a, b = if',  'test', 'end'
      include_examples 'aligned', 'var ||= if', 'test', 'end'
      include_examples 'aligned', 'var &&= if', 'test', 'end'
      include_examples 'aligned', 'var += if',  'test', 'end'
      include_examples 'aligned', 'h[k] = if',  'test', 'end'
      include_examples 'aligned', 'h.k = if',   'test', 'end'

      include_examples 'misaligned', '', '@var = if',  'test',    '      end'
      include_examples 'misaligned', '', '@@var = if', 'test',    '      end'
      include_examples 'misaligned', '', '$var = if',  'test',    '      end'
      include_examples 'misaligned', '', 'CNST = if',  'test',    '      end'
      include_examples 'misaligned', '', 'a, b = if',  'test',    '      end'
      include_examples 'misaligned', '', 'var ||= if', 'test',    '      end'
      include_examples 'misaligned', '', 'var &&= if', 'test',    '      end'
      include_examples 'misaligned', '', 'var += if',  'test',    '      end'
      include_examples 'misaligned', '', 'h[k] = if',  'test',    '      end'
      include_examples 'misaligned', '', 'h.k = if',   'test',    '      end'
    end
  end

  context 'when AlignWith is start_of_line' do
    let(:cop_config) do
      { 'AlignWith' => 'start_of_line', 'AutoCorrect' => true }
    end

    include_examples 'misaligned', '', 'var = if test',       '', '      end'
    include_examples 'misaligned', '', 'var = unless test',   '', '      end'
    include_examples 'misaligned', '', 'var = while test',    '', '      end'
    include_examples 'misaligned', '', 'var = until test',    '', '      end'
    include_examples 'misaligned', '', 'var = case a when b', '', '      end'

    include_examples 'aligned', 'var = if',     'test',     'end'
    include_examples 'aligned', 'var = unless', 'test',     'end'
    include_examples 'aligned', 'var = while',  'test',     'end'
    include_examples 'aligned', 'var = until',  'test',     'end'
    include_examples 'aligned', 'var = case',   'a when b', 'end'
  end
end
