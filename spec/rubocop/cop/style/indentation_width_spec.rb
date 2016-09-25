# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::IndentationWidth do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new('Style/IndentationWidth' => cop_config,
                        'Style/IndentationConsistency' => consistency_config,
                        'Lint/EndAlignment' => end_alignment_config,
                        'Lint/DefEndAlignment' => def_end_alignment_config)
  end
  let(:consistency_config) { { 'EnforcedStyle' => 'normal' } }
  let(:end_alignment_config) do
    { 'Enabled' => true, 'AlignWith' => 'variable' }
  end
  let(:def_end_alignment_config) do
    { 'Enabled' => true, 'AlignWith' => 'start_of_line' }
  end

  context 'with Width set to 4' do
    let(:cop_config) { { 'Width' => 4 } }

    context 'for a file with byte order mark' do
      let(:bom) { "\xef\xbb\xbf" }

      it 'accepts correctly indented method definition' do
        inspect_source(cop, ["#{bom}class Test",
                             '    def method',
                             '    end',
                             'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with if statement' do
      it 'registers an offense for bad indentation of an if body' do
        inspect_source(cop,
                       ['if cond',
                        ' func',
                        'end'])
        expect(cop.messages).to eq(['Use 4 (not 1) spaces for indentation.'])
        expect(cop.highlights).to eq([' '])
      end
    end

    describe '#autocorrect' do
      it 'corrects bad indentation' do
        corrected = autocorrect_source(cop,
                                       ['if a1',
                                        '   b1',
                                        '   b1',
                                        'elsif a2',
                                        ' b2',
                                        'else',
                                        '    c',
                                        'end'])
        expect(corrected)
          .to eq ['if a1',
                  '    b1',
                  '   b1', # Will be corrected by IndentationConsistency.
                  'elsif a2',
                  '    b2',
                  'else',
                  '    c',
                  'end'].join("\n")
      end
    end
  end

  context 'with Width set to 2' do
    let(:cop_config) { { 'Width' => 2 } }

    context 'with if statement' do
      it 'registers an offense for bad indentation of an if body' do
        inspect_source(cop,
                       ['if cond',
                        ' func',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'registers an offense for bad indentation of an else body' do
        inspect_source(cop,
                       ['if cond',
                        '  func1',
                        'else',
                        ' func2',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'registers an offense for bad indentation of an elsif body' do
        inspect_source(cop,
                       ['if a1',
                        '  b1',
                        'elsif a2',
                        ' b2',
                        'else',
                        '  c',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers offense for bad indentation of ternary inside else' do
        inspect_source(cop,
                       ['if a',
                        '  b',
                        'else',
                        '     x ? y : z',
                        'end'])
        expect(cop.messages)
          .to eq(['Use 2 (not 5) spaces for indentation.'])
        expect(cop.highlights).to eq(['     '])
      end

      it 'registers offense for bad indentation of modifier if in else' do
        inspect_source(cop,
                       ['if a',
                        '  b',
                        'else',
                        '   x if y',
                        'end'])
        expect(cop.messages)
          .to eq(['Use 2 (not 3) spaces for indentation.'])
      end

      it 'accepts indentation after if on new line after assignment' do
        inspect_source(cop,
                       ['Rails.application.config.ideal_postcodes_key =',
                        '  if Rails.env.production? || Rails.env.staging?',
                        '    "AAAA-AAAA-AAAA-AAAA"',
                        '  end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts `rescue` after an empty body' do
        inspect_source(cop, ['begin',
                             'rescue',
                             '  handle_error',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts `ensure` after an empty body' do
        inspect_source(cop, ['begin',
                             'ensure',
                             '  something',
                             'end'])
        expect(cop.offenses).to be_empty
      end

      describe '#autocorrect' do
        it 'corrects bad indentation' do
          corrected = autocorrect_source(cop,
                                         ['if a1',
                                          '   b1',
                                          '   b1',
                                          'elsif a2',
                                          ' b2',
                                          'else',
                                          '    c',
                                          'end'])
          expect(corrected)
            .to eq ['if a1',
                    '  b1',
                    '   b1', # Will be corrected by IndentationConsistency.
                    'elsif a2',
                    '  b2',
                    'else',
                    '  c',
                    'end'].join("\n")
        end

        it 'does not correct in scopes that contain block comments' do
          corrected = autocorrect_source(cop,
                                         ['module Foo',
                                          'class Bar',
                                          '=begin',
                                          'This is a nice long',
                                          'comment',
                                          'which spans a few lines',
                                          '=end',
                                          'def baz',
                                          'do_something',
                                          'end',
                                          'end',
                                          'end'])
          expect(corrected).to eq ['module Foo',
                                   # The class has a block comment within, so
                                   # it's not corrected.
                                   'class Bar',
                                   '=begin',
                                   'This is a nice long',
                                   'comment',
                                   'which spans a few lines',
                                   '=end',
                                   # The method has no block comment inside,
                                   # but it's within a class that has a block
                                   # comment, so it's not corrected either.
                                   'def baz',
                                   'do_something',
                                   'end',
                                   'end',
                                   'end'].join("\n")
        end

        it 'does not indent heredoc strings' do
          corrected = autocorrect_source(cop,
                                         ['module Foo',
                                          'module Bar',
                                          '  SOMETHING = <<GOO',
                                          'text',
                                          'more text',
                                          'foo',
                                          'GOO',
                                          '  def baz',
                                          '    do_something("#{x}")',
                                          '  end',
                                          'end',
                                          'end'])
          expect(corrected).to eq ['module Foo',
                                   '  module Bar',
                                   '    SOMETHING = <<GOO',
                                   'text',
                                   'more text',
                                   'foo',
                                   'GOO',
                                   '    def baz',
                                   '      do_something("#{x}")',
                                   '    end',
                                   '  end',
                                   'end'].join("\n")
        end

        it 'indents parenthesized expressions' do
          src = ['var1 = nil',
                 'array_list = []',
                 'if var1.attr1 != 0 || array_list.select{ |w|',
                 '                        (w.attr2 == var1.attr2)',
                 '                 }.blank?',
                 '  array_list << var1',
                 'end']
          corrected = autocorrect_source(cop, src)
          expect(corrected)
            .to eq ['var1 = nil',
                    'array_list = []',
                    'if var1.attr1 != 0 || array_list.select{ |w|',
                    '                   (w.attr2 == var1.attr2)',
                    '                 }.blank?',
                    '  array_list << var1',
                    'end'].join("\n")
        end

        it 'leaves rescue ; end unchanged' do
          src = ['if variable',
                 '  begin',
                 '    do_something',
                 '  rescue ; end # consume any exception',
                 'end']
          corrected = autocorrect_source(cop, src)
          expect(corrected).to eq src.join("\n")
        end

        it 'leaves block unchanged if block end is not on its own line' do
          src = ['a_function {',
                 '  # a comment',
                 '  result = AObject.find_by_attr(attr) if attr',
                 '  result || AObject.make(',
                 '      :attr => attr,',
                 '      :attr2 => Other.get_value(),',
                 '      :attr3 => Another.get_value()) }']
          corrected = autocorrect_source(cop, src)
          expect(corrected).to eq src.join("\n")
        end

        it 'handles lines with only whitespace' do
          corrected = autocorrect_source(cop, ['def x',
                                               '    y',
                                               ' ',
                                               'rescue',
                                               'end'])

          expect(corrected).to eq ['def x',
                                   '  y',
                                   ' ',
                                   'rescue',
                                   'end'].join("\n")
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

      it 'accepts a correctly aligned if/elsif/else/end as a method argument' do
        inspect_source(cop,
                       ['foo(',
                        '  if a1',
                        '    b1',
                        '  elsif a2',
                        '    b2',
                        '  else',
                        '    c',
                        '  end',
                        ')'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts if/elsif/else/end laid out as a table' do
        inspect_source(cop,
                       ['if    @io == $stdout then str << "$stdout"',
                        'elsif @io == $stdin  then str << "$stdin"',
                        'elsif @io == $stderr then str << "$stderr"',
                        'else                      str << @io.class.to_s',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts if/then/else/end laid out as another table' do
        inspect_source(cop,
                       ["if File.exist?('config.save')",
                        'then ConfigTable.load',
                        'else ConfigTable.new',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts an empty if' do
        inspect_source(cop,
                       ['if a',
                        'else',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      context 'with assignment' do
        context 'when alignment style is variable' do
          context 'and end is aligned with variable' do
            it 'accepts an if with end aligned with setter' do
              inspect_source(cop,
                             ['foo.bar = if baz',
                              '  derp',
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

            it 'accepts an if with end aligned with variable' do
              inspect_source(cop,
                             ['var = if a',
                              '  0',
                              'end',
                              '@var = if a',
                              '  0',
                              'end',
                              '$var = if a',
                              '  0',
                              'end',
                              'var ||= if a',
                              '  0',
                              'end',
                              'var &&= if a',
                              '  0',
                              'end',
                              'var -= if a',
                              '  0',
                              'end',
                              'VAR = if a',
                              '  0',
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
            it 'registers an offense for an if with setter' do
              inspect_source(cop,
                             ['foo.bar = if baz',
                              '            derp',
                              '          end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 12) spaces for indentation.'])
            end

            it 'registers an offense for an if with element assignment' do
              inspect_source(cop,
                             ['foo[bar] = if baz',
                              '             derp',
                              '           end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 13) spaces for indentation.'])
            end

            it 'registers an offense for an if' do
              inspect_source(cop,
                             ['var = if a',
                              '        0',
                              '      end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 8) spaces for indentation.'])
            end

            it 'registers an offense for a while' do
              inspect_source(cop,
                             ['var = while a',
                              '        b',
                              '      end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 8) spaces for indentation.'])
            end

            it 'registers an offense for an until' do
              inspect_source(cop,
                             ['var = until a',
                              '        b',
                              '      end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 8) spaces for indentation.'])
            end
          end

          context 'and end is aligned randomly' do
            it 'registers an offense for an if' do
              inspect_source(cop,
                             ['var = if a',
                              '          0',
                              '      end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 10) spaces for indentation.'])
            end

            it 'registers an offense for a while' do
              inspect_source(cop,
                             ['var = while a',
                              '          b',
                              '      end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 10) spaces for indentation.'])
            end

            it 'registers an offense for an until' do
              inspect_source(cop,
                             ['var = until a',
                              '          b',
                              '      end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 10) spaces for indentation.'])
            end
          end
        end

        shared_examples 'assignment and if with keyword alignment' do
          context 'and end is aligned with variable' do
            it 'registers an offense for an if' do
              inspect_source(cop,
                             ['var = if a',
                              '  0',
                              'end'])
              expect(cop.messages)
                .to eq(['Use 2 (not -4) spaces for indentation.'])
            end

            it 'registers an offense for a while' do
              inspect_source(cop,
                             ['var = while a',
                              '  b',
                              'end'])
              expect(cop.messages)
                .to eq(['Use 2 (not -4) spaces for indentation.'])
            end

            it 'autocorrects bad indentation' do
              corrected = autocorrect_source(cop,
                                             ['var = if a',
                                              '  b',
                                              'end',
                                              '',
                                              'var = while a',
                                              '  b',
                                              'end'])
              expect(corrected).to eq ['var = if a',
                                       '        b',
                                       'end', # Not this cop's job to fix end.
                                       '',
                                       'var = while a',
                                       '        b',
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
      it 'registers an offense for bad indentation of an unless body' do
        inspect_source(cop,
                       ['unless cond',
                        ' func',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'accepts an empty unless' do
        inspect_source(cop,
                       ['unless a',
                        'else',
                        'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with case' do
      it 'registers an offense for bad indentation in a case/when body' do
        inspect_source(cop,
                       ['case a',
                        'when b',
                        ' c',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation in a case/else body' do
        inspect_source(cop,
                       ['case a',
                        'when b',
                        '  c',
                        'when d',
                        '  e',
                        'else',
                        '   f',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
      end

      it 'accepts correctly indented case/when/else' do
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

      it 'accepts aligned values in when clause' do
        inspect_source(cop,
                       ['case superclass',
                        'when /\A(#{NAMESPACEMATCH})(?:\s|\Z)/,',
                        '     /\A(Struct|OStruct)\.new/,',
                        '     /\ADelegateClass\((.+?)\)\s*\Z/,',
                        '     /\A(#{NAMESPACEMATCH})\(/',
                        '  $1',
                        'when "self"',
                        '  namespace.path',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts case/when/else laid out as a table' do
        inspect_source(cop,
                       ['case sexp.loc.keyword.source',
                        "when 'if'     then cond, body, _else = *sexp",
                        "when 'unless' then cond, _else, body = *sexp",
                        'else               cond, body = *sexp',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts case/when/else with then beginning a line' do
        inspect_source(cop,
                       ['case sexp.loc.keyword.source',
                        "when 'if'",
                        'then cond, body, _else = *sexp',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts indented when/else plus indented body' do
        # "Indent when as deep as case" is the job of another cop.
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

    context 'with while/until' do
      it 'registers an offense for bad indentation of a while body' do
        inspect_source(cop,
                       ['while cond',
                        ' func',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation of begin/end/while' do
        inspect_source(cop,
                       ['something = begin',
                        ' func1',
                        '   func2',
                        'end while cond'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation of an until body' do
        inspect_source(cop,
                       ['until cond',
                        ' func',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'accepts an empty while' do
        inspect_source(cop,
                       ['while a',
                        'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with for' do
      it 'registers an offense for bad indentation of a for body' do
        inspect_source(cop,
                       ['for var in 1..10',
                        ' func',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'accepts an empty for' do
        inspect_source(cop,
                       ['for var in 1..10',
                        'end'])
        expect(cop.offenses).to be_empty
      end
    end

    context 'with def/defs' do
      shared_examples 'without modifier on the same line' do
        it 'registers an offense for bad indentation of a def body' do
          inspect_source(cop,
                         ['def test',
                          '    func1',
                          '     func2', # No offense registered for this.
                          'end'])
          expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
        end

        it 'registers an offense for bad indentation of a defs body' do
          inspect_source(cop,
                         ['def self.test',
                          '   func',
                          'end'])
          expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
        end

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

        it 'with an assignment' do
          inspect_source(cop,
                         ['something = def self.foo',
                          'end'])
          expect(cop.offenses).to be_empty
        end
      end

      context 'when end is aligned with start of line' do
        let(:def_end_alignment_config) do
          { 'Enabled' => true, 'AlignWith' => 'start_of_line' }
        end

        include_examples 'without modifier on the same line'

        if RUBY_VERSION >= '2.1'
          context 'when modifier and def are on the same line' do
            it 'accepts a correctly aligned body' do
              inspect_source(cop,
                             ['foo def test',
                              '  something',
                              'end'])
              expect(cop.offenses).to be_empty
            end

            it 'registers an offense for bad indentation of a def body' do
              inspect_source(cop,
                             ['foo def test',
                              '      something',
                              '    end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 6) spaces for indentation.'])
            end

            it 'registers an offense for bad indentation of a defs body' do
              inspect_source(cop,
                             ['foo def self.test',
                              '      something',
                              '    end'])
              expect(cop.messages)
                .to eq(['Use 2 (not 6) spaces for indentation.'])
            end
          end
        end
      end

      context 'when end is aligned with def' do
        let(:def_end_alignment_config) do
          { 'Enabled' => true, 'AlignWith' => 'def' }
        end

        include_examples 'without modifier on the same line'

        if RUBY_VERSION >= '2.1'
          context 'when modifier and def are on the same line' do
            it 'accepts a correctly aligned body' do
              inspect_source(cop,
                             ['foo def test',
                              '      something',
                              'end'])
              expect(cop.offenses).to be_empty
            end

            it 'registers an offense for bad indentation of a def body' do
              inspect_source(cop,
                             ['foo def test',
                              '  something',
                              '    end'])
              expect(cop.messages)
                .to eq(['Use 2 (not -2) spaces for indentation.'])
            end

            it 'registers an offense for bad indentation of a defs body' do
              inspect_source(cop,
                             ['foo def self.test',
                              '  something',
                              '    end'])
              expect(cop.messages)
                .to eq(['Use 2 (not -2) spaces for indentation.'])
            end
          end
        end
      end
    end

    context 'with class' do
      it 'registers an offense for bad indentation of a class body' do
        inspect_source(cop,
                       ['class Test',
                        '    def func',
                        '    end',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
      end

      it 'accepts an empty class body' do
        inspect_source(cop,
                       ['class Test',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      context 'when consistency style is normal' do
        it 'accepts indented public, protected, and private' do
          inspect_source(cop,
                         ['class Test',
                          '  public',
                          '',
                          '  def e',
                          '  end',
                          '',
                          '  protected',
                          '',
                          '  def f',
                          '  end',
                          '',
                          '  private',
                          '',
                          '  def g',
                          '  end',
                          'end'])
          expect(cop.offenses).to be_empty
        end
      end

      context 'when consistency style is rails' do
        let(:consistency_config) { { 'EnforcedStyle' => 'rails' } }

        it 'registers an offense for normal non-rails indentation' do
          inspect_source(cop,
                         ['class Test',
                          '  public',
                          '',
                          '  def e',
                          '  end',
                          '',
                          '  protected',
                          '',
                          '  def f',
                          '  end',
                          '',
                          '  private',
                          '',
                          '  def g',
                          '  end',
                          'end'])
          expect(cop.messages)
            .to eq(['Use 2 (not 0) spaces for rails indentation.'] * 2)
          expect(cop.offenses.map(&:line)).to eq([9, 14])
        end
      end
    end

    context 'with module' do
      context 'when consistency style is normal' do
        it 'registers an offense for bad indentation of a module body' do
          inspect_source(cop,
                         ['module Test',
                          '    def func',
                          '    end',
                          'end'])
          expect(cop.messages).to eq(['Use 2 (not 4) spaces for indentation.'])
        end

        it 'accepts an empty module body' do
          inspect_source(cop,
                         ['module Test',
                          'end'])
          expect(cop.offenses).to be_empty
        end
      end

      context 'when consistency style is rails' do
        let(:consistency_config) { { 'EnforcedStyle' => 'rails' } }

        it 'registers an offense for bad indentation of a module body' do
          inspect_source(cop,
                         ['module Test',
                          '   def func1',
                          '   end',
                          '  private',
                          ' def func2',
                          ' end',
                          'end'])
          expect(cop.messages)
            .to eq(['Use 2 (not 3) spaces for indentation.',
                    'Use 2 (not -1) spaces for rails indentation.'])
        end

        it 'accepts normal non-rails indentation of module functions' do
          inspect_source(cop,
                         ['module Test',
                          '  module_function',
                          '  def func',
                          '  end',
                          'end'])
          expect(cop.offenses).to be_empty
        end
      end
    end

    context 'with begin/rescue/else/ensure/end' do
      it 'registers an offense for bad indentation of bodies' do
        inspect_source(cop,
                       ['def my_func',
                        "  puts 'do something outside block'",
                        '  begin',
                        "  puts 'do something error prone'",
                        '  rescue SomeException, SomeOther => e',
                        "   puts 'wrongly intended error handling'",
                        '  rescue',
                        "   puts 'wrongly intended error handling'",
                        '  else',
                        "     puts 'wrongly intended normal case handling'",
                        '  ensure',
                        "      puts 'wrongly intended common handling'",
                        '  end',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 0) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 3) spaces for indentation.',
                                    'Use 2 (not 4) spaces for indentation.'])
      end
    end

    context 'with def/rescue/end' do
      it 'registers an offense for bad indentation of bodies' do
        inspect_source(cop,
                       ['def my_func',
                        "  puts 'do something error prone'",
                        'rescue SomeException',
                        " puts 'wrongly intended error handling'",
                        'rescue',
                        " puts 'wrongly intended error handling'",
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indent of defs bodies with a modifier' do
        inspect_source(cop,
                       ['foo def self.my_func',
                        "  puts 'do something error prone'",
                        'rescue SomeException',
                        " puts 'wrongly intended error handling'",
                        'rescue',
                        " puts 'wrongly intended error handling'",
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.',
                                    'Use 2 (not 1) spaces for indentation.'])
      end
    end

    context 'with block' do
      it 'registers an offense for bad indentation of a do/end body' do
        inspect_source(cop,
                       ['a = func do',
                        ' b',
                        'end'])
        expect(cop.messages).to eq(['Use 2 (not 1) spaces for indentation.'])
      end

      it 'registers an offense for bad indentation of a {} body' do
        inspect_source(cop,
                       ['func {',
                        '   b',
                        '}'])
        expect(cop.messages).to eq(['Use 2 (not 3) spaces for indentation.'])
      end

      it 'accepts a correctly indented block body' do
        inspect_source(cop,
                       ['a = func do',
                        '  b',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts an empty block body' do
        inspect_source(cop,
                       ['a = func do',
                        'end'])
        expect(cop.offenses).to be_empty
      end

      # The cop uses the block end/} as the base for indentation, so if it's not
      # on its own line, all bets are off.
      it 'accepts badly indented code if block end is not on separate line' do
        inspect_source(cop,
                       ['foo {',
                        'def baz',
                        'end }'])
        expect(cop.offenses).to be_empty
      end
    end
  end
end
