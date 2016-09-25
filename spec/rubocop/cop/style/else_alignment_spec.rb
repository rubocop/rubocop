# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::ElseAlignment do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Lint/EndAlignment' => end_alignment_config)
  end
  let(:end_alignment_config) do
    { 'Enabled' => true, 'AlignWith' => 'variable' }
  end

  it 'accepts a ternary if' do
    inspect_source(cop, 'cond ? func1 : func2')
    expect(cop.offenses).to be_empty
  end

  context 'with if statement' do
    it 'registers an offense for misaligned else' do
      inspect_source(cop,
                     ['if cond',
                      '  func1',
                      ' else',
                      ' func2',
                      'end'])
      expect(cop.messages).to eq(['Align `else` with `if`.'])
      expect(cop.highlights).to eq(['else'])
    end

    it 'registers an offense for misaligned elsif' do
      inspect_source(cop,
                     ['  if a1',
                      '    b1',
                      'elsif a2',
                      '    b2',
                      '  end'])
      expect(cop.messages).to eq(['Align `elsif` with `if`.'])
      expect(cop.highlights).to eq(['elsif'])
    end

    it 'accepts indentation after else when if is on new line after ' \
       'assignment' do
      inspect_source(cop,
                     ['Rails.application.config.ideal_postcodes_key =',
                      '  if Rails.env.production? || Rails.env.staging?',
                      '    "AAAA-AAAA-AAAA-AAAA"',
                      '  else',
                      '    "BBBB-BBBB-BBBB-BBBB"',
                      '  end'])
      expect(cop.offenses).to be_empty
    end

    describe '#autocorrect' do
      it 'corrects bad alignment' do
        corrected = autocorrect_source(cop,
                                       ['  if a1',
                                        '    b1',
                                        '    elsif a2',
                                        '    b2',
                                        'else',
                                        '    c',
                                        '  end'])
        expect(cop.messages).to eq(['Align `elsif` with `if`.',
                                    'Align `else` with `if`.'])
        expect(corrected)
          .to eq ['  if a1',
                  '    b1',
                  '  elsif a2',
                  '    b2',
                  '  else',
                  '    c',
                  '  end'].join("\n")
      end
    end

    it 'accepts a one line if statement' do
      inspect_source(cop, 'if cond then func1 else func2 end')
      expect(cop.offenses).to be_empty
    end

    it 'accepts a correctly aligned if/elsif/else/end' do
      inspect_source(cop,
                     ['if a1',
                      '  b1',
                      'elsif a2',
                      '  b2',
                      'else',
                      '  c',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    context 'for a file with byte order mark' do
      let(:bom) { "\xef\xbb\xbf" }

      it 'accepts a correctly aligned if/elsif/else/end' do
        inspect_source(cop,
                       ["#{bom}if a1",
                        '  b1',
                        'elsif a2',
                        '  b2',
                        'else',
                        '  c',
                        'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with assignment' do
      context 'when alignment style is variable' do
        context 'and end is aligned with variable' do
          it 'accepts an if-else with end aligned with setter' do
            inspect_source(cop,
                           ['foo.bar = if baz',
                            '  derp1',
                            'else',
                            '  derp2',
                            'end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if-elsif-else with end aligned with setter' do
            inspect_source(cop,
                           ['foo.bar = if baz',
                            '  derp1',
                            'elsif meh',
                            '  derp2',
                            'else',
                            '  derp3',
                            'end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if with end aligned with element assignment' do
            inspect_source(cop,
                           ['foo[bar] = if baz',
                            '  derp',
                            'end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if/else' do
            inspect_source(cop,
                           ['var = if a',
                            '  0',
                            'else',
                            '  1',
                            'end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if/else with chaining after the end' do
            inspect_source(cop,
                           ['var = if a',
                            '  0',
                            'else',
                            '  1',
                            'end.abc.join("")'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if/else with chaining with a block after the end' do
            inspect_source(cop,
                           ['var = if a',
                            '  0',
                            'else',
                            '  1',
                            'end.abc.tap {}'])
            expect(cop.offenses).to be_empty
          end
        end

        context 'and end is aligned with keyword' do
          it 'registers offenses for an if with setter' do
            inspect_source(cop,
                           ['foo.bar = if baz',
                            '            derp1',
                            '          elsif meh',
                            '            derp2',
                            '          else',
                            '            derp3',
                            '          end'])
            expect(cop.messages).to eq(['Align `elsif` with `foo.bar`.',
                                        'Align `else` with `foo.bar`.'])
          end

          it 'registers an offense for an if with element assignment' do
            inspect_source(cop,
                           ['foo[bar] = if baz',
                            '             derp1',
                            '           else',
                            '             derp2',
                            '           end'])
            expect(cop.messages).to eq(['Align `else` with `foo[bar]`.'])
          end

          it 'registers an offense for an if' do
            inspect_source(cop,
                           ['var = if a',
                            '        0',
                            '      else',
                            '        1',
                            '      end'])
            expect(cop.messages).to eq(['Align `else` with `var`.'])
          end
        end
      end

      shared_examples 'assignment and if with keyword alignment' do
        context 'and end is aligned with variable' do
          it 'registers an offense for an if' do
            inspect_source(cop,
                           ['var = if a',
                            '  0',
                            'elsif b',
                            '  1',
                            'end'])
            expect(cop.messages).to eq(['Align `elsif` with `if`.'])
          end

          it 'autocorrects bad alignment' do
            corrected = autocorrect_source(cop,
                                           ['var = if a',
                                            '  b1',
                                            'else',
                                            '  b2',
                                            'end'])
            expect(corrected).to eq ['var = if a',
                                     '  b1',
                                     '      else',
                                     '  b2',
                                     'end'].join("\n")
          end
        end

        context 'and end is aligned with keyword' do
          it 'accepts an if in assignment' do
            inspect_source(cop,
                           ['var = if a',
                            '        0',
                            '      end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if/else in assignment' do
            inspect_source(cop,
                           ['var = if a',
                            '        0',
                            '      else',
                            '        1',
                            '      end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an if/else in assignment on next line' do
            inspect_source(cop,
                           ['var =',
                            '  if a',
                            '    0',
                            '  else',
                            '    1',
                            '  end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts a while in assignment' do
            inspect_source(cop,
                           ['var = while a',
                            '        b',
                            '      end'])
            expect(cop.offenses).to be_empty
          end

          it 'accepts an until in assignment' do
            inspect_source(cop,
                           ['var = until a',
                            '        b',
                            '      end'])
            expect(cop.offenses).to be_empty
          end
        end
      end

      context 'when alignment style is keyword by choice' do
        let(:end_alignment_config) do
          { 'Enabled' => true, 'AlignWith' => 'keyword' }
        end

        include_examples 'assignment and if with keyword alignment'
      end
    end

    it 'accepts an if/else branches with rescue clauses' do
      # Because of how the rescue clauses come out of Parser, these are
      # special and need to be tested.
      inspect_source(cop,
                     ['if a',
                      '  a rescue nil',
                      'else',
                      '  a rescue nil',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'with unless' do
    it 'registers an offense for misaligned else' do
      inspect_source(cop,
                     ['unless cond',
                      '   func1',
                      ' else',
                      '   func2',
                      'end'])
      expect(cop.messages).to eq(['Align `else` with `unless`.'])
    end

    it 'accepts a correctly aligned else in an otherwise empty unless' do
      inspect_source(cop,
                     ['unless a',
                      'else',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty unless' do
      inspect_source(cop,
                     ['unless a',
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'with case' do
    it 'registers an offense for misaligned else' do
      inspect_source(cop,
                     ['case a',
                      'when b',
                      '  c',
                      'when d',
                      '  e',
                      ' else',
                      '  f',
                      'end'])
      expect(cop.messages).to eq(['Align `else` with `when`.'])
    end

    it 'accepts correctly aligned case/when/else' do
      inspect_source(cop,
                     ['case a',
                      'when b',
                      '  c',
                      '  c',
                      'when d',
                      'else',
                      '  f',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts case without else' do
      inspect_source(cop,
                     ['case superclass',
                      'when /\A(#{NAMESPACEMATCH})(?:\s|\Z)/',
                      '  $1',
                      'when "self"',
                      '  namespace.path',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts else aligned with when but not with case' do
      # "Indent when as deep as case" is the job of another cop, and this is
      # one of the possible styles supported by configuration.
      inspect_source(cop,
                     ['case code_type',
                      "  when 'ruby', 'sql', 'plain'",
                      '    code_type',
                      "  when 'erb'",
                      "    'ruby; html-script: true'",
                      '  when "html"',
                      "    'xml'",
                      '  else',
                      "    'plain'",
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'with def/defs' do
    it 'accepts an empty def body' do
      inspect_source(cop,
                     ['def test',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts an empty defs body' do
      inspect_source(cop,
                     ['def self.test',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    if RUBY_VERSION >= '2.1'
      context 'when modifier and def are on the same line' do
        it 'accepts a correctly aligned body' do
          inspect_source(cop,
                         ['private def test',
                          '  something',
                          'rescue',
                          '  handling',
                          'else',
                          '  something_else',
                          'end'])
          expect(cop.offenses).to be_empty
        end

        it 'registers an offense for else not aligned with private' do
          inspect_source(cop,
                         ['private def test',
                          '          something',
                          '        rescue',
                          '          handling',
                          '        else',
                          '          something_else',
                          '        end'])
          expect(cop.messages).to eq(['Align `else` with `private`.'])
        end
      end
    end
  end

  context 'with begin/rescue/else/ensure/end' do
    it 'registers an offense for misaligned else' do
      inspect_source(cop,
                     ['def my_func',
                      "  puts 'do something outside block'",
                      '  begin',
                      "    puts 'do something error prone'",
                      '  rescue SomeException, SomeOther => e',
                      "    puts 'wrongly intended error handling'",
                      '  rescue',
                      "    puts 'wrongly intended error handling'",
                      'else',
                      "    puts 'wrongly intended normal case handling'",
                      '  ensure',
                      "    puts 'wrongly intended common handling'",
                      '  end',
                      'end'])
      expect(cop.messages).to eq(['Align `else` with `begin`.'])
    end

    it 'accepts a correctly aligned else' do
      inspect_source(cop,
                     ['begin',
                      "  raise StandardError.new('Fail') if rand(2).odd?",
                      'rescue StandardError => error',
                      '  $stderr.puts error.message',
                      'else',
                      "  $stdout.puts 'Lucky you!'",
                      'end'])
      expect(cop.offenses).to be_empty
    end
  end

  context 'with def/rescue/else/ensure/end' do
    it 'accepts a correctly aligned else' do
      inspect_source(cop,
                     ['def my_func(string)',
                      '  puts string',
                      'rescue => e',
                      '  puts e',
                      'else',
                      '  puts e',
                      'ensure',
                      "  puts 'I love methods that print'",
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for misaligned else' do
      inspect_source(cop,
                     ['def my_func(string)',
                      '  puts string',
                      'rescue => e',
                      '  puts e',
                      '  else',
                      '  puts e',
                      'ensure',
                      "  puts 'I love methods that print'",
                      'end'])
      expect(cop.messages).to eq(['Align `else` with `def`.'])
    end
  end

  context 'with def/rescue/else/end' do
    it 'accepts a correctly aligned else' do
      inspect_source(cop,
                     ['def my_func',
                      "  puts 'do something error prone'",
                      'rescue SomeException',
                      "  puts 'error handling'",
                      'rescue',
                      "  puts 'error handling'",
                      'else',
                      "  puts 'normal handling'",
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for misaligned else' do
      inspect_source(cop,
                     ['def my_func',
                      "  puts 'do something error prone'",
                      'rescue SomeException',
                      "  puts 'error handling'",
                      'rescue',
                      "  puts 'error handling'",
                      '  else',
                      "  puts 'normal handling'",
                      'end'])
      expect(cop.messages).to eq(['Align `else` with `def`.'])
    end
  end
end
