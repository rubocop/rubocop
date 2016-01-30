# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineOperationIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Style/MultilineOperationIndentation']
             .merge(cop_config)
             .merge('IndentationWidth' => cop_indent)
    RuboCop::Config
      .new('Style/MultilineOperationIndentation' => merged,
           'Style/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }
  let(:cop_indent) { nil } # use indentation width from Style/IndentationWidth

  shared_examples 'common' do
    it 'accepts indented operands in ordinary statement' do
      inspect_source(cop,
                     ['a +',
                      '  b'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for no indentation of second line' do
      inspect_source(cop,
                     ['a +',
                      'b'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for one space indentation of second line' do
      inspect_source(cop,
                     ['a +',
                      ' b'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'does not check method calls' do
      inspect_source(cop,
                     ['a',
                      ' .(args)',
                      '',
                      'Foo',
                      '.a',
                      '  .b',
                      '',
                      'Foo',
                      '.a',
                      '  .b(c)',
                      '',
                      'expect { Foo.new }.',
                      '  to change { Bar.count }.',
                      '      from(1).to(2)'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for three spaces indentation of second line' do
      inspect_source(cop,
                     ['a ||',
                      '   b',
                      'c and',
                      '   d'])
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indenting an ' \
                                  'expression spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(%w(b d))
    end

    it 'registers an offense for extra indentation of third line' do
      inspect_source(cop,
                     ['   a ||',
                      '     b ||',
                      '       c'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['c'])
    end

    it 'registers an offense for the emacs ruby-mode 1.1 indentation of an ' \
       'expression in an array' do
      inspect_source(cop,
                     ['  [',
                      '   a +',
                      '   b',
                      '  ]'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts indented operands in an array' do
      inspect_source(cop, ['    dm[i][j] = [',
                           '      dm[i-1][j-1] +',
                           '        (this[j-1] == that[i-1] ? 0 : sub),',
                           '      dm[i][j-1] + ins,',
                           '      dm[i-1][j] + del',
                           '    ].min'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts two spaces indentation in assignment of local variable' do
      inspect_source(cop,
                     ['a =',
                      "  'foo' +",
                      "  'bar'"])
      expect(cop.messages).to be_empty
    end

    it 'accepts two spaces indentation in assignment of array element' do
      inspect_source(cop,
                     ["a['test'] =",
                      "  'foo' +",
                      "  'bar'"])
      expect(cop.messages).to be_empty
    end

    it 'accepts two spaces indentation of second line' do
      inspect_source(cop,
                     ['   a ||',
                      '     b'])
      expect(cop.messages).to be_empty
    end

    it 'accepts no extra indentation of third line' do
      inspect_source(cop,
                     ['   a &&',
                      '     b &&',
                      '     c'])
      expect(cop.messages).to be_empty
    end

    it 'accepts indented operands in for body' do
      inspect_source(cop,
                     ['for x in a',
                      '  something &&',
                      '    something_else',
                      'end'])
      expect(cop.highlights).to be_empty
    end

    it 'accepts alignment inside a grouped expression' do
      inspect_source(cop,
                     ['(a +',
                      ' b)'])
      expect(cop.messages).to be_empty
    end

    it 'accepts an expression where the first operand spans multiple lines' do
      inspect_source(cop,
                     ['subject.each do |item|',
                      '  result = resolve(locale) and return result',
                      'end and nil'])
      expect(cop.messages).to be_empty
    end

    it 'accepts any indentation of parameters to #[]' do
      inspect_source(cop,
                     ['payment = Models::IncomingPayments[',
                      "        id:      input['incoming-payment-id'],",
                      '           user_id: @user[:id]]'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for an unindented multiline operation that is ' \
       'the left operand in another operation' do
      inspect_source(cop, ['a +',
                           'b < 3'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'

    it 'accepts aligned operands in if condition' do
      inspect_source(cop,
                     ['if a +',
                      '   b',
                      '  something',
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for indented operands in if condition' do
      inspect_source(cop,
                     ['if a +',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`if` statement spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'accepts indented code on LHS of equality operator' do
      inspect_source(cop, ['def config_to_allow_offenses',
                           '  a +',
                           '    b == c ',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts indented operands inside block + assignment' do
      inspect_source(cop, ['a = b.map do |c|',
                           '  c +',
                           '    d',
                           'end',
                           '',
                           'requires_interpolation = node.children.any? do |s|',
                           '  s.type == :dstr ||',
                           '    s.loc.expression.source =~ REGEXP',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for indented second part of string' do
      inspect_source(cop,
                     ['it "should convert " +',
                      '  "a to " +',
                      '  "b" do',
                      'end'])
      expect(cop.messages).to eq(['Align the operands of an expression ' \
                                  'spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(['"a to "', '"b"'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'registers an offense for indented operand in second argument' do
      inspect_source(cop,
                     ['puts a, 1 +',
                      '  2'])
      expect(cop.messages)
        .to eq(['Align the operands of an expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['2'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'registers an offense for misaligned string operand when the first ' \
       'operand has backslash continuation' do
      inspect_source(cop,
                     ['def f',
                      "  flash[:error] = 'Here is a string ' \\",
                      "                  'That spans' <<",
                      "    'multiple lines'",
                      'end'])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned string operand when plus is used' do
      inspect_source(cop,
                     ["Error = 'Here is a string ' +",
                      "        'That spans' <<",
                      "  'multiple lines'"])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned operands in unless condition' do
      inspect_source(cop,
                     ['unless a +',
                      '  b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`unless` statement spanning multiple ' \
                                  'lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    [
      %w(an if),
      %w(an unless),
      %w(a while),
      %w(an until)
    ].each do |article, keyword|
      it "registers an offense for misaligned operands in #{keyword} " \
         'condition' do
        inspect_source(cop,
                       ["#{keyword} a or",
                        '    b',
                        '  something',
                        'end'])
        expect(cop.messages).to eq(['Align the operands of a condition in ' \
                                    "#{article} `#{keyword}` statement " \
                                    'spanning multiple lines.'])
        expect(cop.highlights).to eq(['b'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'indented')
      end
    end

    it 'accepts aligned operands in assignment' do
      inspect_source(cop,
                     ['a = b +',
                      '    c +',
                      '    d'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned or:ed operands in assignment' do
      inspect_source(cop,
                     ["tmp_dir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] ||",
                      "          Etc.systmpdir || '/tmp'"])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for unaligned operands in op-assignment' do
      inspect_source(cop,
                     ['bar *= Foo +',
                      '  a +',
                      '       b(c)'])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(['a'])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, ['until a +',
                                            '    b',
                                            '  something',
                                            'end'])
      expect(new_source).to eq(['until a +',
                                '      b',
                                '  something',
                                'end'].join("\n"))
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'

    it 'accepts indented operands in if condition' do
      inspect_source(cop,
                     ['if a +',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for aligned operands in if condition' do
      inspect_source(cop,
                     ['if a +',
                      '   b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Use 4 (not 3) spaces for indenting a ' \
                                  'condition in an `if` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'aligned')
    end

    it 'accepts the indentation of a broken string' do
      inspect_source(cop,
                     ["MSG = 'Use 2 (not %d) spaces for indenting a ' \\",
                      "      'broken line.'"])
      expect(cop.messages).to be_empty
    end

    it 'accepts normal indentation of method parameters' do
      inspect_source(cop,
                     ['Parser::Source::Range.new(expr.source_buffer,',
                      '                          begin_pos,',
                      '                          begin_pos + line.length)'])
      expect(cop.messages).to be_empty
    end

    it 'accepts any indentation of method parameters' do
      inspect_source(cop,
                     ['a(b +',
                      '    c +',
                      'd)'])
      expect(cop.messages).to be_empty
    end

    it 'accepts normal indentation inside grouped expression' do
      inspect_source(cop,
                     ['arg_array.size == a.size && (',
                      '  arg_array == a ||',
                      '  arg_array.map(&:children) == a.map(&:children)',
                      ')'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for aligned code on LHS of equality operator' do
      inspect_source(cop, ['def config_to_allow_offenses',
                           '  a +',
                           '  b == c ',
                           'end'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
    end

    [
      %w(an if),
      %w(an unless),
      %w(a while),
      %w(an until)
    ].each do |article, keyword|
      it "accepts double indentation of #{keyword} condition" do
        inspect_source(cop,
                       ["#{keyword} receiver.nil? &&",
                        '    !args.empty? &&',
                        '    BLACKLIST.include?(method_name)',
                        'end',
                        "#{keyword} receiver.",
                        '    nil?',
                        'end'])
        expect(cop.messages).to be_empty
      end

      it "registers an offense for a 2 space indentation of #{keyword} " \
         'condition' do
        inspect_source(cop,
                       ["#{keyword} receiver.nil? &&",
                        '  !args.empty? &&',
                        '  BLACKLIST.include?(method_name)',
                        'end'])
        expect(cop.highlights).to eq(['!args.empty?',
                                      'BLACKLIST.include?(method_name)'])
        expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                    "condition in #{article} `#{keyword}` " \
                                    'statement spanning multiple lines.'] * 2)
      end

      it "accepts indented operands in #{keyword} body" do
        inspect_source(cop,
                       ["#{keyword} a",
                        '  something &&',
                        '    something_else',
                        'end'])
        expect(cop.highlights).to be_empty
      end
    end

    %w(unless if).each do |keyword|
      it "accepts special indentation of return #{keyword} condition" do
        inspect_source(cop,
                       ["return #{keyword} receiver.nil? &&",
                        '    !args.empty? &&',
                        '    BLACKLIST.include?(method_name)'])
        expect(cop.messages).to be_empty
      end
    end

    it 'registers an offense for wrong indentation of for expression' do
      inspect_source(cop,
                     ['for n in a +',
                      '  b',
                      'end'])
      expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                  'collection in a `for` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts special indentation of for expression' do
      inspect_source(cop,
                     ['for n in a +',
                      '    b',
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'accepts indentation of assignment' do
      inspect_source(cop,
                     ['a = b +',
                      '  c +',
                      '  d'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for correct + unrecognized style' do
      inspect_source(cop,
                     ['a ||',
                      '  b',
                      'c and',
                      '    d'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(%w(d))
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for aligned operators in assignment' do
      inspect_source(cop,
                     ['a = b +',
                      '    c +',
                      '    d'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression in an assignment spanning ' \
                                  'multiple lines.'] * 2)
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, ['until a +',
                                            '      b',
                                            '  something',
                                            'end'])
      expect(new_source).to eq(['until a +',
                                '    b',
                                '  something',
                                'end'].join("\n"))
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 6 }

      it 'accepts indented operands in if condition' do
        inspect_source(cop,
                       ['if a +',
                        '        b',
                        '  something',
                        'end'])
        expect(cop.messages).to be_empty
      end

      [
        %w(an if),
        %w(an unless),
        %w(a while),
        %w(an until)
      ].each do |article, keyword|
        it "accepts indentation of #{keyword} condition which is offset " \
           'by a single normal indentation step' do
          # normal code indentation is 2 spaces, and we have configured
          # multiline method indentation to 6 spaces
          # so in this case, 8 spaces are required
          inspect_source(cop,
                         ["#{keyword} receiver.nil? &&",
                          '        !args.empty? &&',
                          '        BLACKLIST.include?(method_name)',
                          'end',
                          "#{keyword} receiver.",
                          '        nil?',
                          'end'])
          expect(cop.messages).to be_empty
        end

        it "registers an offense for a 4 space indentation of #{keyword} " \
           'condition' do
          inspect_source(cop,
                         ["#{keyword} receiver.nil? &&",
                          '    !args.empty? &&',
                          '    BLACKLIST.include?(method_name)',
                          'end'])
          expect(cop.highlights).to eq(['!args.empty?',
                                        'BLACKLIST.include?(method_name)'])
          expect(cop.messages).to eq(['Use 8 (not 4) spaces for indenting a ' \
                                      "condition in #{article} `#{keyword}` " \
                                      'statement spanning multiple lines.'] * 2)
        end

        it "accepts indented operands in #{keyword} body" do
          inspect_source(cop,
                         ["#{keyword} a",
                          '  something &&',
                          '        something_else',
                          'end'])
          expect(cop.highlights).to be_empty
        end
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, ['until a +',
                                              '      b',
                                              '  something',
                                              'end'])
        expect(new_source).to eq(['until a +',
                                  '        b',
                                  '  something',
                                  'end'].join("\n"))
      end
    end
  end
end
