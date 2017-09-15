# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineOperationIndentation do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    merged = RuboCop::ConfigLoader
             .default_configuration['Layout/MultilineOperationIndentation']
             .merge(cop_config)
             .merge('IndentationWidth' => cop_indent)
    RuboCop::Config
      .new('Layout/MultilineOperationIndentation' => merged,
           'Layout/IndentationWidth' => { 'Width' => indentation_width })
  end
  let(:indentation_width) { 2 }
  let(:cop_indent) { nil } # use indentation width from Layout/IndentationWidth

  shared_examples 'common' do
    it 'accepts indented operands in ordinary statement' do
      inspect_source(<<-RUBY.strip_indent)
        a +
          b
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts indented operands inside and outside a block' do
      inspect_source(<<-RUBY.strip_indent)
        a = b.map do |c|
          c +
            b +
            d do
              x +
                y
            end
        end
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'registers an offense for no indentation of second line' do
      inspect_source(<<-RUBY.strip_indent)
        a +
        b
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'registers an offense for one space indentation of second line' do
      inspect_source(<<-RUBY.strip_indent)
        a +
         b
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 1) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'does not check method calls' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a
         .(args)

        Foo
        .a
          .b

        Foo
        .a
          .b(c)

        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
      RUBY
    end

    it 'registers an offense for three spaces indentation of second line' do
      inspect_source(<<-RUBY.strip_indent)
        a ||
           b
        c and
           d
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 3) spaces for indenting an ' \
                                  'expression spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(%w[b d])
    end

    it 'registers an offense for extra indentation of third line' do
      inspect_source(<<-RUBY.strip_margin('|'))
        |   a ||
        |     b ||
        |       c
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['c'])
    end

    it 'registers an offense for the emacs ruby-mode 1.1 indentation of an ' \
       'expression in an array' do
      inspect_source(<<-RUBY.strip_margin('|'))
        |  [
        |   a +
        |   b
        |  ]
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end

    it 'accepts indented operands in an array' do
      inspect_source(<<-RUBY.strip_margin('|'))
        |    dm[i][j] = [
        |      dm[i-1][j-1] +
        |        (this[j-1] == that[i-1] ? 0 : sub),
        |      dm[i][j-1] + ins,
        |      dm[i-1][j] + del
        |    ].min
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    it 'accepts two spaces indentation in assignment of local variable' do
      inspect_source(<<-RUBY.strip_indent)
        a =
          'foo' +
          'bar'
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts two spaces indentation in assignment of array element' do
      inspect_source(<<-RUBY.strip_indent)
        a['test'] =
          'foo' +
          'bar'
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts two spaces indentation of second line' do
      inspect_source(<<-RUBY.strip_margin('|'))
        |   a ||
        |     b
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts no extra indentation of third line' do
      inspect_source(<<-RUBY.strip_margin('|'))
        |   a &&
        |     b &&
        |     c
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts indented operands in for body' do
      inspect_source(<<-RUBY.strip_indent)
        for x in a
          something &&
            something_else
        end
      RUBY
      expect(cop.highlights.empty?).to be(true)
    end

    it 'accepts alignment inside a grouped expression' do
      inspect_source(<<-RUBY.strip_indent)
        (a +
         b)
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts an expression where the first operand spans multiple lines' do
      inspect_source(<<-RUBY.strip_indent)
        subject.each do |item|
          result = resolve(locale) and return result
        end and nil
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'accepts any indentation of parameters to #[]' do
      inspect_source(<<-RUBY.strip_indent)
        payment = Models::IncomingPayments[
                id:      input['incoming-payment-id'],
                   user_id: @user[:id]]
      RUBY
      expect(cop.messages.empty?).to be(true)
    end

    it 'registers an offense for an unindented multiline operation that is ' \
       'the left operand in another operation' do
      inspect_source(<<-RUBY.strip_indent)
        a +
        b < 3
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 0) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'

    it 'accepts aligned operands in if condition' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if a +
           b
          something
        end
      RUBY
    end

    it 'registers an offense for indented operands in if condition' do
      inspect_source(<<-RUBY.strip_indent)
        if a +
            b
          something
        end
      RUBY
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`if` statement spanning multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'accepts indented code on LHS of equality operator' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def config_to_allow_offenses
          a +
            b == c
        end
      RUBY
    end

    it 'accepts indented operands inside block + assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = b.map do |c|
          c +
            d
        end

        requires_interpolation = node.children.any? do |s|
          s.type == :dstr ||
            s.loc.expression.source =~ REGEXP
        end
      RUBY
    end

    it 'registers an offense for indented second part of string' do
      inspect_source(<<-RUBY.strip_indent)
        it "should convert " +
          "a to " +
          "b" do
        end
      RUBY
      expect(cop.messages).to eq(['Align the operands of an expression ' \
                                  'spanning multiple lines.'] * 2)
      expect(cop.highlights).to eq(['"a to "', '"b"'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'registers an offense for indented operand in second argument' do
      inspect_source(<<-RUBY.strip_indent)
        puts a, 1 +
          2
      RUBY
      expect(cop.messages)
        .to eq(['Align the operands of an expression spanning multiple lines.'])
      expect(cop.highlights).to eq(['2'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'indented')
    end

    it 'registers an offense for misaligned string operand when the first ' \
       'operand has backslash continuation' do
      inspect_source(['def f',
                      "  flash[:error] = 'Here is a string ' \\",
                      "                  'That spans' <<",
                      "    'multiple lines'",
                      'end'])
      expect(cop.messages).to eq(['Align the operands of an expression in an ' \
                                  'assignment spanning multiple lines.'])
      expect(cop.highlights).to eq(["'multiple lines'"])
    end

    it 'registers an offense for misaligned string operand when plus is used' do
      expect_offense(<<-RUBY.strip_indent)
        Error = 'Here is a string ' +
                'That spans' <<
          'multiple lines'
          ^^^^^^^^^^^^^^^^ Align the operands of an expression in an assignment spanning multiple lines.
      RUBY
    end

    it 'registers an offense for misaligned operands in unless condition' do
      inspect_source(<<-RUBY.strip_indent)
        unless a +
          b
          something
        end
      RUBY
      expect(cop.messages).to eq(['Align the operands of a condition in an ' \
                                  '`unless` statement spanning multiple ' \
                                  'lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    [
      %w[an if],
      %w[an unless],
      %w[a while],
      %w[an until]
    ].each do |article, keyword|
      it "registers an offense for misaligned operands in #{keyword} " \
         'condition' do
        inspect_source(<<-RUBY.strip_indent)
          #{keyword} a or
              b
            something
          end
        RUBY
        expect(cop.messages).to eq(['Align the operands of a condition in ' \
                                    "#{article} `#{keyword}` statement " \
                                    'spanning multiple lines.'])
        expect(cop.highlights).to eq(['b'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'indented')
      end
    end

    it 'accepts aligned operands in assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = b +
            c +
            d
      RUBY
    end

    it 'accepts aligned or:ed operands in assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        tmp_dir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] ||
                  Etc.systmpdir || '/tmp'
      RUBY
    end

    it 'registers an offense for unaligned operands in op-assignment' do
      expect_offense(<<-RUBY.strip_indent)
        bar *= Foo +
          a +
          ^ Align the operands of an expression in an assignment spanning multiple lines.
               b(c)
      RUBY
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        until a +
            b
          something
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        until a +
              b
          something
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'

    it 'accepts indented operands in if condition' do
      expect_no_offenses(<<-RUBY.strip_indent)
        if a +
            b
          something
        end
      RUBY
    end

    it 'registers an offense for aligned operands in if condition' do
      inspect_source(<<-RUBY.strip_indent)
        if a +
           b
          something
        end
      RUBY
      expect(cop.messages).to eq(['Use 4 (not 3) spaces for indenting a ' \
                                  'condition in an `if` statement spanning ' \
                                  'multiple lines.'])
      expect(cop.highlights).to eq(['b'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'aligned')
    end

    it 'accepts the indentation of a broken string' do
      expect_no_offenses(<<-RUBY.strip_indent)
        MSG = 'Use 2 (not %d) spaces for indenting a ' \
              'broken line.'
      RUBY
    end

    it 'accepts normal indentation of method parameters' do
      expect_no_offenses(<<-RUBY.strip_indent)
        Parser::Source::Range.new(expr.source_buffer,
                                  begin_pos,
                                  begin_pos + line.length)
      RUBY
    end

    it 'accepts any indentation of method parameters' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a(b +
            c +
        d)
      RUBY
    end

    it 'accepts normal indentation inside grouped expression' do
      expect_no_offenses(<<-RUBY.strip_indent)
        arg_array.size == a.size && (
          arg_array == a ||
          arg_array.map(&:children) == a.map(&:children)
        )
      RUBY
    end

    it 'registers an offense for aligned code on LHS of equality operator' do
      expect_offense(<<-RUBY.strip_indent)
        def config_to_allow_offenses
          a +
          b == c
          ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        end
      RUBY
    end

    [
      %w[an if],
      %w[an unless],
      %w[a while],
      %w[an until]
    ].each do |article, keyword|
      it "accepts double indentation of #{keyword} condition" do
        inspect_source(<<-RUBY.strip_indent)
          #{keyword} receiver.nil? &&
              !args.empty? &&
              BLACKLIST.include?(method_name)
          end
          #{keyword} receiver.
              nil?
          end
        RUBY
        expect(cop.messages.empty?).to be(true)
      end

      it "registers an offense for a 2 space indentation of #{keyword} " \
         'condition' do
        inspect_source(<<-RUBY.strip_indent)
          #{keyword} receiver.nil? &&
            !args.empty? &&
            BLACKLIST.include?(method_name)
          end
        RUBY
        expect(cop.highlights).to eq(['!args.empty?',
                                      'BLACKLIST.include?(method_name)'])
        expect(cop.messages).to eq(['Use 4 (not 2) spaces for indenting a ' \
                                    "condition in #{article} `#{keyword}` " \
                                    'statement spanning multiple lines.'] * 2)
      end

      it "accepts indented operands in #{keyword} body" do
        inspect_source(<<-RUBY.strip_indent)
          #{keyword} a
            something &&
              something_else
          end
        RUBY
        expect(cop.highlights.empty?).to be(true)
      end
    end

    %w[unless if].each do |keyword|
      it "accepts special indentation of return #{keyword} condition" do
        inspect_source(<<-RUBY.strip_indent)
          return #{keyword} receiver.nil? &&
              !args.empty? &&
              BLACKLIST.include?(method_name)
        RUBY
        expect(cop.messages.empty?).to be(true)
      end
    end

    it 'registers an offense for wrong indentation of for expression' do
      expect_offense(<<-RUBY.strip_indent)
        for n in a +
          b
          ^ Use 4 (not 2) spaces for indenting a collection in a `for` statement spanning multiple lines.
        end
      RUBY
    end

    it 'accepts special indentation of for expression' do
      expect_no_offenses(<<-RUBY.strip_indent)
        for n in a +
            b
        end
      RUBY
    end

    it 'accepts indentation of assignment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = b +
          c +
          d
      RUBY
    end

    it 'registers an offense for correct + unrecognized style' do
      inspect_source(<<-RUBY.strip_indent)
        a ||
          b
        c and
            d
      RUBY
      expect(cop.messages).to eq(['Use 2 (not 4) spaces for indenting an ' \
                                  'expression spanning multiple lines.'])
      expect(cop.highlights).to eq(%w[d])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for aligned operators in assignment' do
      msg = 'Use %d (not %d) spaces for indenting an expression in ' \
              'an assignment spanning multiple lines.'
      expect_offense(<<-RUBY.strip_indent)
        a = b +
            c +
            ^ #{format(msg, 2, 4)}
            d
            ^ #{format(msg, 2, 4)}
      RUBY
    end

    it 'auto-corrects' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        until a +
              b
          something
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        until a +
            b
          something
        end
      RUBY
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 6 }

      it 'accepts indented operands in if condition' do
        expect_no_offenses(<<-RUBY.strip_indent)
          if a +
                  b
            something
          end
        RUBY
      end

      [
        %w[an if],
        %w[an unless],
        %w[a while],
        %w[an until]
      ].each do |article, keyword|
        it "accepts indentation of #{keyword} condition which is offset " \
           'by a single normal indentation step' do
          # normal code indentation is 2 spaces, and we have configured
          # multiline method indentation to 6 spaces
          # so in this case, 8 spaces are required
          inspect_source(<<-RUBY.strip_indent)
            #{keyword} receiver.nil? &&
                    !args.empty? &&
                    BLACKLIST.include?(method_name)
            end
            #{keyword} receiver.
                    nil?
            end
          RUBY
          expect(cop.messages.empty?).to be(true)
        end

        it "registers an offense for a 4 space indentation of #{keyword} " \
           'condition' do
          inspect_source(<<-RUBY.strip_indent)
            #{keyword} receiver.nil? &&
                !args.empty? &&
                BLACKLIST.include?(method_name)
            end
          RUBY
          expect(cop.highlights).to eq(['!args.empty?',
                                        'BLACKLIST.include?(method_name)'])
          expect(cop.messages).to eq(['Use 8 (not 4) spaces for indenting a ' \
                                      "condition in #{article} `#{keyword}` " \
                                      'statement spanning multiple lines.'] * 2)
        end

        it "accepts indented operands in #{keyword} body" do
          inspect_source(<<-RUBY.strip_indent)
            #{keyword} a
              something &&
                    something_else
            end
          RUBY
          expect(cop.highlights.empty?).to be(true)
        end
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          until a +
                b
            something
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          until a +
                  b
            something
          end
        RUBY
      end
    end
  end
end
