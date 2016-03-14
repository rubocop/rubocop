# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Style::MultilineMethodCallIndentation do
  subject(:cop) { described_class.new(config) }
  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Style/MultilineMethodCallIndentation']
             .merge(cop_config)
             .merge('IndentationWidth' => cop_indent)
    RuboCop::Config
      .new('Style/MultilineMethodCallIndentation' => merged,
           'Style/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }
  let(:cop_indent) { nil } # use indentation width from Style/IndentationWidth

  shared_examples 'common' do
    it 'accepts indented methods in LHS of []= assignment' do
      inspect_source(cop,
                     ['a',
                      '  .b[c] = 0'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts indented methods inside and outside a block' do
      inspect_source(cop,
                     ['a = b.map do |c|',
                      '  c',
                      '    .b',
                      '    .d do',
                      '      x',
                      '        .y',
                      '    end',
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'accepts indentation relative to first receiver' do
      inspect_source(cop,
                     ['node',
                      '  .children.map { |n| string_source(n) }.compact',
                      '  .any? { |s| preferred.any? { |d| s.include?(d) } }'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts indented methods in ordinary statement' do
      inspect_source(cop,
                     ['a.',
                      '  b'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for no indentation of second line' do
      inspect_source(cop,
                     ['a.',
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

    it 'registers an offense for 3 spaces indentation of second line' do
      inspect_source(cop,
                     ['a.',
                      '   b',
                      'c.',
                      '   d'])
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indenting an ' \
                                  'expression spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(%w(b d))
    end

    it 'accepts no extra indentation of third line' do
      inspect_source(cop,
                     ['   a.',
                      '     b.',
                      '     c'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for extra indentation of third line' do
      inspect_source(cop,
                     ['   a.',
                      '     b.',
                      '       c'])
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['c'])
    end

    it 'registers an offense for the emacs ruby-mode 1.1 indentation of an ' \
       'expression in an array' do
      inspect_source(cop,
                     ['  [',
                      '   a.',
                      '   b',
                      '  ]'])
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts indented methods in for body' do
      inspect_source(cop,
                     ['for x in a',
                      '  something.',
                      '    something_else',
                      'end'])
      expect(cop.highlights).to be_empty
    end

    it 'accepts alignment inside a grouped expression' do
      inspect_source(cop,
                     ['(a.',
                      ' b)'])
      expect(cop.messages).to be_empty
    end

    it 'accepts an expression where the first method spans multiple lines' do
      inspect_source(cop,
                     ['subject.each do |item|',
                      '  result = resolve(locale) and return result',
                      'end.a'])
      expect(cop.messages).to be_empty
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
      expect(cop.highlights).to eq(['from'])
    end

    it "doesn't fail on unary operators" do
      inspect_source(cop,
                     ['def foo',
                      '  !0',
                      '  .nil?',
                      'end'])
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'

    # We call it semantic alignment when a dot is aligned with the first dot in
    # a chain of calls, and that first dot does not begin its line.
    context 'for semantic alignment' do
      it 'accepts method being aligned with method' do
        inspect_source(cop,
                       ['User.all.first',
                        '    .age.to_s'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts method being aligned with method in assignment' do
        inspect_source(cop,
                       ['age = User.all.first',
                        '          .age.to_s'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts aligned method with blocks in operation assignment' do
        inspect_source(cop,
                       ['@comment_lines ||=',
                        '  src.comments',
                        '     .select { |c| begins_its_line?(c) }',
                        '     .map { |c| c.loc.line }'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts 3 aligned methods' do
        inspect_source(cop,
                       ["a_class.new(severity, location, 'message', 'CopName')",
                        '       .severity',
                        '       .level'])
        expect(cop.offenses).to be_empty
      end

      it 'registers an offense for unaligned methods' do
        inspect_source(cop,
                       ['User.a',
                        '  .b',
                        ' .c'])
        expect(cop.messages).to eq(['Align `.b` with `.a` on line 1.',
                                    'Align `.c` with `.a` on line 1.'])
        expect(cop.highlights).to eq(['.b', '.c'])
      end

      it 'registers an offense for unaligned method in block body' do
        inspect_source(cop,
                       ['a do',
                        '  b.c',
                        '    .d',
                        'end'])
        expect(cop.messages).to eq(['Align `.d` with `.c` on line 2.'])
        expect(cop.highlights).to eq(['.d'])
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(cop, ['User.all.first',
                                              '  .age.to_s'])
        expect(new_source).to eq(['User.all.first',
                                  '    .age.to_s'].join("\n"))
      end
    end

    it 'accepts correctly aligned methods in operands' do
      inspect_source(cop, ['1 + a',
                           '    .b',
                           '    .c + d.',
                           '         e'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts correctly aligned methods in assignment' do
      inspect_source(cop, ['def investigate(processed_source)',
                           '  @modifier = processed_source',
                           '              .tokens',
                           '              .select { |t| t.type == :k }',
                           '              .map(&:pos)',
                           'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned methods in if + assignment' do
      inspect_source(cop,
                     ['KeyMap = Hash.new do |map, key|',
                      '  value = if key.respond_to?(:to_str)',
                      '    key',
                      '  else',
                      "    key.to_s.split('_').",
                      '      each { |w| w.capitalize! }.',
                      "      join('-')",
                      '  end',
                      '  keymap_mutex.synchronize { map[key] = value }',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts indented method when there is nothing to align with' do
      inspect_source(cop,
                     ["expect { custom_formatter_class('NonExistentClass') }",
                      '  .to raise_error(NameError)'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for one space indentation of third line' do
      inspect_source(cop,
                     ['a',
                      '  .b',
                      ' .c'])
      expect(cop.messages)
        .to eq(['Use 2 (not 1) spaces for indenting an expression spanning ' \
                'multiple lines.'])
      expect(cop.highlights).to eq(['.c'])
    end

    it 'accepts indented and aligned methods in binary operation' do
      inspect_source(cop,
                     ['a.',
                      '  b + c',   # b is indented relative to a
                      '      .d']) # .d is aligned with c
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned methods in if condition' do
      inspect_source(cop,
                     ['if a.',
                      '   b',
                      '  something',
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for misaligned methods in if condition' do
      inspect_source(cop,
                     ['if a.',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align `b` with `a.` on line 1.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'falls back to indentation in complicated cases' do
      inspect_source(cop,
                     # There are two method call chains here. The last one is
                     # an argument to the first, and they both start on the
                     # same line.
                     ['expect(RuboCop::ConfigLoader).to receive(:file).once',
                      "    .with('dir')"])
      expect(cop.messages)
        .to eq(['Use 2 (not 4) spaces for indenting an expression spanning ' \
                'multiple lines.'])
      expect(cop.highlights).to eq(['.with'])
    end

    it 'does not check binary operations' do
      inspect_source(cop,
                     ["flash[:error] = 'Here is a string ' \\",
                      "                'That spans' <<",
                      "  'multiple lines'"])
      expect(cop.offenses).to be_empty
    end

    it 'does not check binary operations' do
      inspect_source(cop,
                     ["flash[:error] = 'Here is a string ' +",
                      "                'That spans' <<",
                      "  'multiple lines'"])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for misaligned method in []= call' do
      inspect_source(cop,
                     ['flash[:error] = here_is_a_string.',
                      '                that_spans.',
                      '   multiple_lines'])
      expect(cop.messages)
        .to eq(['Align `multiple_lines` with `here_is_a_string.` on line 1.'])
      expect(cop.highlights).to eq(['multiple_lines'])
    end

    it 'registers an offense for misaligned methods in unless condition' do
      inspect_source(cop,
                     ['unless a',
                      '.b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align `.b` with `a` on line 1.'])
      expect(cop.highlights).to eq(['.b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for misaligned methods in while condition' do
      inspect_source(cop,
                     ['while a.',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align `b` with `a.` on line 1.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for misaligned methods in until condition' do
      inspect_source(cop,
                     ['until a.',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Align `b` with `a.` on line 1.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts aligned method in return' do
      inspect_source(cop,
                     ['def a',
                      '  return b.',
                      '         c',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned method in assignment + block + assignment' do
      inspect_source(cop,
                     ['a = b do',
                      '  c.d = e.',
                      '        f',
                      'end'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned methods in assignment' do
      inspect_source(cop,
                     ['formatted_int = int_part',
                      '                .to_s',
                      '                .reverse',
                      "                .gsub(/...(?=.)/, '\&_')"])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for misaligned methods in local variable ' \
       'assignment' do
      inspect_source(cop, ['a = b.c.',
                           ' d'])
      expect(cop.messages).to eq(['Align `d` with `b.c.` on line 1.'])
      expect(cop.highlights).to eq(['d'])
    end

    it 'accepts aligned methods in constant assignment' do
      inspect_source(cop, ['A = b',
                           '    .c'])
      expect(cop.offenses).to be_empty
    end

    it 'accepts aligned methods in operator assignment' do
      inspect_source(cop, ['a +=',
                           '  b',
                           '  .c'])
      expect(cop.offenses).to be_empty
    end

    it 'registers an offense for unaligned methods in assignment' do
      inspect_source(cop,
                     ['bar = Foo',
                      '  .a',
                      '      .b(c)'])
      expect(cop.messages).to eq(['Align `.a` with `Foo` on line 1.'])
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

    # We call it semantic alignment when a dot is aligned with the first dot in
    # a chain of calls, and that first dot does not begin its line. But for the
    # indented style, it doesn't come into play.
    context 'for possible semantic alignment' do
      it 'accepts indented methods' do
        inspect_source(cop,
                       ['User.a',
                        '  .c',
                        '  .b'])
        expect(cop.offenses).to be_empty
      end
    end

    it 'accepts correctly indented methods in operation' do
      inspect_source(cop, ['        1 + a',
                           '          .b',
                           '          .c'])
      expect(cop.offenses).to be_empty
      expect(cop.highlights).to be_empty
    end

    it 'registers an offense for one space indentation of third line' do
      inspect_source(cop,
                     ['a',
                      '  .b',
                      ' .c'])
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['.c'])
    end

    it 'accepts indented methods in if condition' do
      inspect_source(cop,
                     ['if a.',
                      '    b',
                      '  something',
                      'end'])
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for aligned methods in if condition' do
      inspect_source(cop,
                     ['if a.',
                      '   b',
                      '  something',
                      'end'])
      expect(cop.messages).to eq(['Use 4 (not 3) spaces for indenting a ' \
                                  'condition in an `if` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'aligned')
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
                       ["#{keyword} receiver.",
                        '    nil? &&',
                        '    !args.empty?',
                        'end'])
        expect(cop.messages).to be_empty
      end

      it "registers an offense for a 2 space indentation of #{keyword} " \
         'condition' do
        inspect_source(cop,
                       ["#{keyword} receiver",
                        '  .nil? &&',
                        '  !args.empty?',
                        'end'])
        expect(cop.highlights).to eq(['.nil?'])
        expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                    "condition in #{article} `#{keyword}` " \
                                    'statement spanning multiple lines.'])
      end

      it "accepts indented methods in #{keyword} body" do
        inspect_source(cop,
                       ["#{keyword} a",
                        '  something.',
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
                     ['for n in a.',
                      '  b',
                      'end'])
      expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                  'collection in a `for` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts special indentation of for expression' do
      inspect_source(cop,
                     ['for n in a.',
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
                     ['a.',
                      '  b',
                      'c.',
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

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 7 }

      it 'accepts indented methods' do
        inspect_source(cop,
                       ['User.a',
                        '       .c',
                        '       .b'])
        expect(cop.offenses).to be_empty
      end

      it 'accepts correctly indented methods in operation' do
        inspect_source(cop, ['        1 + a',
                             '               .b',
                             '               .c'])
        expect(cop.offenses).to be_empty
        expect(cop.highlights).to be_empty
      end

      it 'accepts indented methods in if condition' do
        inspect_source(cop,
                       ['if a.',
                        '         b',
                        '  something',
                        'end'])
        expect(cop.messages).to be_empty
      end

      it 'accepts indentation of assignment' do
        inspect_source(cop,
                       ['formatted_int = int_part',
                        '       .abs',
                        '       .to_s',
                        '       .reverse'])
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
          # multiline method indentation to 7 spaces
          # so in this case, 9 spaces are required
          inspect_source(cop,
                         ["#{keyword} receiver.",
                          '         nil? &&',
                          '         !args.empty?',
                          'end'])
          expect(cop.messages).to be_empty
        end

        it "registers an offense for a 4 space indentation of #{keyword} " \
           'condition' do
          inspect_source(cop,
                         ["#{keyword} receiver",
                          '    .nil? &&',
                          '    !args.empty?',
                          'end'])
          expect(cop.highlights).to eq(['.nil?'])
          expect(cop.messages).to eq(['Use 9 (not 4) spaces for indenting a ' \
                                      "condition in #{article} `#{keyword}` " \
                                      'statement spanning multiple lines.'])
        end

        it "accepts indented methods in #{keyword} body" do
          inspect_source(cop,
                         ["#{keyword} a",
                          '  something.',
                          '         something_else',
                          'end'])
          expect(cop.highlights).to be_empty
        end
      end
    end
  end
end
