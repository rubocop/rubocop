# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::IndentArray do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config
      .new('Style/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }

  it 'accepts multi-assignments' do
    inspect_source(cop, 'a, b = b, a')
    expect(cop.offenses).to be_empty
  end

  it 'accepts correctly indented only element' do
    inspect_source(cop,
                   ['a << [',
                    '  1',
                    ']'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for incorrectly indented only element' do
    inspect_source(cop,
                   ['a << [',
                    ' 1',
                    ']'])
    expect(cop.highlights).to eq(['1'])
  end

  it 'registers an offense for incorrectly indented closing bracket in an ' \
     'empty array' do
    inspect_source(cop,
                   ['a << [',
                    ' ]'])
    expect(cop.messages)
      .to eq(['Indent the right bracket the same as the start of the line ' \
              'where the left bracket is.'])
    expect(cop.highlights).to eq([']'])
  end

  context 'when the first element is not on its own line' do
    it 'registers an offense for an incorrectly indented closing bracket' do
      inspect_source(cop,
                     ['a = [1,',
                      '     2,',
                      ']'])
      expect(cop.highlights).to eq([']'])
      expect(cop.messages)
        .to eq(['Indent the right bracket the same as the left bracket.'])
    end

    it 'accepts closing bracket indented the same as opening bracket' do
      inspect_source(cop,
                     ['a = [1,',
                      '     2,',
                      '    ]'])
      expect(cop.highlights).to eq([])
      expect(cop.offenses).to be_empty
    end
  end

  it 'auto-corrects incorrectly indented only element' do
    corrected = autocorrect_source(cop, ['a << [',
                                         ' 1',
                                         ']'])
    expect(corrected).to eq ['a << [',
                             '  1',
                             ']'].join("\n")
  end

  it 'accepts correctly indented first element' do
    inspect_source(cop,
                   ['[',
                    '  x,',
                    '  y',
                    ']'])
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for incorrectly indented first element' do
    inspect_source(cop,
                   ['[',
                    'x,',
                    '  y',
                    ']'])
    expect(cop.highlights).to eq(['x'])
  end

  it 'accepts several elements per line' do
    inspect_source(cop,
                   ['a = [',
                    '  1, 2',
                    ']'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts a first element on the same line as the left bracket' do
    inspect_source(cop,
                   ['a = ["a",',
                    '     "b"]'])
    expect(cop.offenses).to be_empty
  end

  it 'accepts single line array' do
    inspect_source(cop, 'a = [1, 2]')
    expect(cop.offenses).to be_empty
  end

  it 'accepts an empty array' do
    inspect_source(cop, 'a = []')
    expect(cop.offenses).to be_empty
  end

  context 'when array is method argument' do
    context 'and arguments are surrounded by parentheses' do
      it 'accepts normal indentation for first argument' do
        inspect_source(cop,
                       ['func([',
                        '  1',
                        '])'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for incorrect indentation' do
        inspect_source(cop,
                       ['func([',
                        '      1',
                        '     ])'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in an array, relative to ' \
                  'the start of the line where the left bracket is.',

                  'Indent the right bracket the same as the start of the ' \
                  'line where the left bracket is.'])
      end

      it 'accepts normal indentation for second argument' do
        inspect_source(cop,
                       ['body.should have_tag("input", [',
                        '  :name])'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'and arguments are not surrounded by parentheses' do
      it 'accepts single line array' do
        inspect_source(cop, 'func x, [1, 2]')
        expect(cop.offenses).to be_empty
      end

      it 'accepts a correctly indented multi-line array' do
        inspect_source(cop,
                       ['func x, [',
                        '  1, 2]'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for incorrectly indented multi-line array' do
        inspect_source(cop,
                       ['func x, [',
                        '       1, 2]'])
        expect(cop.messages)
          .to eq(['Use 2 spaces for indentation in an array, relative to ' \
                  'the start of the line where the left bracket is.'])
        expect(cop.highlights).to eq(['1'])
      end
    end
  end
end
