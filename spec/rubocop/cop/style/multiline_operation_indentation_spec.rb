# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineOperationIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Style/MultilineOperationIndentation']
             .merge(cop_config)
    RuboCop::Config
      .new('Style/MultilineOperationIndentation' => merged,
           'Style/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }

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
                     ['a',
                      ' .b'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.b'])
    end

    it 'registers an offense for proc call without a selector' do
      inspect_source(cop,
                     ['a',
                      ' .(args)'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.('])
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

    it 'registers an offense for badly indented operands in chained ' \
       'method call' do
      inspect_source(cop,
                     ['Foo',
                      '.a',
                      '  .b'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.a'])
    end

    it 'registers an offense for badly indented operands in chained ' \
       'method call' do
      inspect_source(cop,
                     ['Foo',
                      '.a',
                      '  .b(c)'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.a'])
    end

    it 'accepts even indentation of consecutive lines in typical RSpec code' do
      inspect_source(cop,
                     ['expect { Foo.new }.',
                      '  to change { Bar.count }.',
                      '  from(1).to(2)'])
      expect(cop.messages).to be_empty
    end

    it 'accepts any indentation of parameters to #[]' do
      inspect_source(cop,
                     ['payment = Models::IncomingPayments[',
                      "        id:      input['incoming-payment-id'],",
                      '           user_id: @user[:id]]'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for extra indentation of 3rd line in typical ' \
       'RSpec code' do
      inspect_source(cop,
                     ['expect { Foo.new }.',
                      '  to change { Bar.count }.',
                      '      from(1).to(2)'])
      expect(cop.messages).to eq(['Use 2 (not 6) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
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

    it 'registers an offense for misaligned operands in if condition' do
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

    it 'registers an offense for misaligned string operand when the first ' \
       'operand has backslash continuation' do
      inspect_source(cop,
                     ["flash[:error] = 'Here is a string ' \\",
                      "                'That spans' <<",
                      "  'multiple lines'"])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned string operand when plus is used' do
      inspect_source(cop,
                     ["flash[:error] = 'Here is a string ' +",
                      "                'That spans' <<",
                      "  'multiple lines'"])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned operands in unless condition' do
      inspect_source(cop,
                     ['unless a',
                      '  .b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`unless` statement spanning multiple ' \
                                  'lines.'])
      expect(cop.highlights).to eq(['.b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for misaligned operands in while condition' do
      inspect_source(cop,
                     ['while a.',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align the operands of a condition in a ' \
                                  '`while` statement spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for misaligned operands in until condition' do
      inspect_source(cop,
                     ['until a.',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`until` statement spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts aligned operands in assignment' do
      inspect_source(cop,
                     ['formatted_int = int_part',
                      '                .to_s',
                      '                .reverse',
                      "                .gsub(/...(?=.)/, '\&_')"])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for unaligned operands in assignment' do
      inspect_source(cop,
                     ['bar = Foo',
                      '  .a',
                      '      .b(c)'])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(['.a'])
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, ['until a.',
                                            '    b',
                                            '  something',
                                            'end'])
      expect(new_source).to eq(['until a.',
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
                     ['a(b.',
                      '    c',
                      '.d)'])
      expect(cop.messages).to be_empty
    end

    it 'accepts normal indentation inside grouped expression' do
      inspect_source(cop,
                     ['arg_array.size == a.size && (',
                      '  arg_array == a ||',
                      '  arg_array.map(&:children) == a.map(&:children)',
                      ')'])
      expect(cop.messages).to be_empty
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
                        'end',
                        "#{keyword} receiver.",
                        '  nil?',
                        'end'])
        expect(cop.highlights).to eq(['!args.empty?',
                                      'BLACKLIST.include?(method_name)',
                                      'nil?'])
        expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                    "condition in #{article} `#{keyword}` " \
                                    'statement spanning multiple lines.'] * 3)
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
                     ['formatted_int = int_part',
                      '  .abs',
                      '  .to_s',
                      '  .reverse',
                      "  .gsub(/...(?=.)/, '\&_')",
                      '  .reverse'])
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
                     ['formatted_int = int_part',
                      '                .abs',
                      '                .reverse'])
      expect(cop.messages).to eq(['Use 2 (not 16) spaces for indenting an ' \
                                  'expression in an assignment spanning ' \
                                  'multiple lines.'] * 2)
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(cop, ['until a.',
                                            '      b',
                                            '  something',
                                            'end'])
      expect(new_source).to eq(['until a.',
                                '    b',
                                '  something',
                                'end'].join("\n"))
    end
  end
end
