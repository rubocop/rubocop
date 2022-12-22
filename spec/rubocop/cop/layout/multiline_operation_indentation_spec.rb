# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineOperationIndentation, :config do
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
    it 'accepts unary operations' do
      expect_no_offenses(<<~RUBY)
        call a,
             !b
      RUBY
    end

    it 'accepts indented operands in ordinary statement' do
      expect_no_offenses(<<~RUBY)
        a +
          b
      RUBY
    end

    it 'accepts indented operands inside and outside a block' do
      expect_no_offenses(<<~RUBY)
        a = b.map do |c|
          c +
            b +
            d do
              x +
                y
            end
        end
      RUBY
    end

    it 'registers an offense and corrects no indentation of second line' do
      expect_offense(<<~RUBY)
        a +
        b
        ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a +
          b
      RUBY
    end

    it 'registers an offense and corrects one space indentation of second line' do
      expect_offense(<<~RUBY)
        a +
         b
         ^ Use 2 (not 1) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a +
          b
      RUBY
    end

    it 'does not check method calls' do
      expect_no_offenses(<<~RUBY)
        a
         .(args)

        Foo
        .a
          .b

        Foo
        .a
          .b(c)

        Foo.&(
            foo,
            bar
        )

        expect { Foo.new }.
          to change { Bar.count }.
              from(1).to(2)
      RUBY
    end

    it 'registers an offense and corrects three space indentation of second line' do
      expect_offense(<<~RUBY)
        a ||
           b
           ^ Use 2 (not 3) spaces for indenting an expression spanning multiple lines.
        c and
           d
           ^ Use 2 (not 3) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a ||
          b
        c and
          d
      RUBY
    end

    it 'registers an offense and corrects extra indentation of third line' do
      expect_offense(<<~RUBY)
        a ||
          b ||
            c
            ^ Use 2 (not 4) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a ||
          b ||
          c
      RUBY
    end

    it 'registers an offense and corrects emacs ruby-mode 1.1 indentation of ' \
       'an expression in an array' do
      expect_offense(<<~RUBY)
        [
         a +
         b
         ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        ]
      RUBY

      expect_correction(<<~RUBY)
        [
         a +
           b
        ]
      RUBY
    end

    it 'accepts indented operands in an array' do
      expect_no_offenses(<<~RUBY)
        dm[i][j] = [
          dm[i-1][j-1] +
            (this[j-1] == that[i-1] ? 0 : sub),
          dm[i][j-1] + ins,
          dm[i-1][j] + del
        ].min
      RUBY
    end

    it 'accepts two spaces indentation in assignment of local variable' do
      expect_no_offenses(<<~RUBY)
        a =
          'foo' +
          'bar'
      RUBY
    end

    it 'accepts two spaces indentation in assignment of array element' do
      expect_no_offenses(<<~RUBY)
        a['test'] =
          'foo' +
          'bar'
      RUBY
    end

    it 'accepts two spaces indentation of second line' do
      expect_no_offenses(<<~RUBY)
        a ||
          b
      RUBY
    end

    it 'accepts no extra indentation of third line' do
      expect_no_offenses(<<~RUBY)
        a &&
          b &&
          c
      RUBY
    end

    it 'accepts indented operands in for body' do
      expect_no_offenses(<<~RUBY)
        for x in a
          something &&
            something_else
        end
      RUBY
    end

    it 'accepts alignment inside a grouped expression' do
      expect_no_offenses(<<~RUBY)
        (a +
         b)
      RUBY
    end

    it 'accepts an expression where the first operand spans multiple lines' do
      expect_no_offenses(<<~RUBY)
        subject.each do |item|
          result = resolve(locale) and return result
        end and nil
      RUBY
    end

    it 'accepts any indentation of parameters to #[]' do
      expect_no_offenses(<<~RUBY)
        payment = Models::IncomingPayments[
                id:      input['incoming-payment-id'],
                   user_id: @user[:id]]
      RUBY
    end

    it 'registers an offense and corrects an unindented multiline operation ' \
       'that is the left operand in another operation' do
      expect_offense(<<~RUBY)
        a +
        b < 3
        ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a +
          b < 3
      RUBY
    end
  end

  context 'when EnforcedStyle is aligned' do
    let(:cop_config) { { 'EnforcedStyle' => 'aligned' } }

    include_examples 'common'

    it 'accepts aligned operands in if condition' do
      expect_no_offenses(<<~RUBY)
        if a +
           b
          something
        end
      RUBY
    end

    it 'registers an offense and corrects indented operands in if condition' do
      expect_offense(<<~RUBY)
        if a +
            b
            ^ Align the operands of a condition in an `if` statement spanning multiple lines.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        if a +
           b
          something
        end
      RUBY
    end

    it 'accepts indented code on LHS of equality operator' do
      expect_no_offenses(<<~RUBY)
        def config_to_allow_offenses
          a +
            b == c
        end
      RUBY
    end

    it 'accepts indented operands inside block + assignment' do
      expect_no_offenses(<<~RUBY)
        a = b.map do |c|
          c +
            d
        end

        requires_interpolation = node.children.any? do |s|
          s.type == :dstr ||
            s.source_range.source =~ REGEXP
        end
      RUBY
    end

    it 'accepts indented operands with ternary operators' do
      expect_no_offenses(<<~RUBY)
        one ||
          two ? 3 : 5
      RUBY
    end

    it 'registers an offense and corrects indented second part of string' do
      expect_offense(<<~RUBY)
        it "should convert " +
          "a to " +
          ^^^^^^^ Align the operands of an expression spanning multiple lines.
          "b" do
          ^^^ Align the operands of an expression spanning multiple lines.
        end
      RUBY

      expect_correction(<<~RUBY)
        it "should convert " +
           "a to " +
           "b" do
        end
      RUBY
    end

    it 'registers an offense and corrects indented operand in second argument' do
      expect_offense(<<~RUBY)
        puts a, 1 +
          2
          ^ Align the operands of an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        puts a, 1 +
                2
      RUBY
    end

    it 'registers an offense and corrects misaligned string operand ' \
       'when the first operand has backslash continuation' do
      expect_offense(<<~'RUBY')
        def f
          flash[:error] = 'Here is a string ' \
                          'That spans' <<
              'multiple lines'
              ^^^^^^^^^^^^^^^^ Align the operands of an expression in an assignment spanning multiple lines.
        end
      RUBY

      expect_correction(<<~'RUBY')
        def f
          flash[:error] = 'Here is a string ' \
                          'That spans' <<
                          'multiple lines'
        end
      RUBY
    end

    it 'registers an offense and corrects misaligned string operand when plus is used' do
      expect_offense(<<~RUBY)
        Error = 'Here is a string ' +
                'That spans' <<
          'multiple lines'
          ^^^^^^^^^^^^^^^^ Align the operands of an expression in an assignment spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        Error = 'Here is a string ' +
                'That spans' <<
                'multiple lines'
      RUBY
    end

    it 'registers an offense and corrects misaligned operands in unless condition' do
      expect_offense(<<~RUBY)
        unless a +
          b
          ^ Align the operands of a condition in an `unless` statement spanning multiple lines.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        unless a +
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
      it "registers an offense for misaligned operands in #{keyword} condition" do
        expect_offense(<<~RUBY)
          #{keyword} a or
              b
              ^ Align the operands of a condition in #{article} `#{keyword}` statement spanning multiple lines.
            something
          end
        RUBY
      end
    end

    it 'accepts aligned operands in assignment' do
      expect_no_offenses(<<~RUBY)
        a = b +
            c +
            d
      RUBY
    end

    it 'accepts aligned or:ed operands in assignment' do
      expect_no_offenses(<<~RUBY)
        tmp_dir = ENV['TMPDIR'] || ENV['TMP'] || ENV['TEMP'] ||
                  Etc.systmpdir || '/tmp'
      RUBY
    end

    it 'registers an offense and corrects unaligned operands in op-assignment' do
      expect_offense(<<~RUBY)
        bar *= Foo +
          a +
          ^ Align the operands of an expression in an assignment spanning multiple lines.
               b(c)
      RUBY

      expect_correction(<<~RUBY)
        bar *= Foo +
               a +
               b(c)
      RUBY
    end
  end

  context 'when EnforcedStyle is indented' do
    let(:cop_config) { { 'EnforcedStyle' => 'indented' } }

    include_examples 'common'

    it 'accepts indented operands in if condition' do
      expect_no_offenses(<<~RUBY)
        if a +
            b
          something
        end
      RUBY
    end

    it 'registers an offense and corrects aligned operands in if conditions' do
      expect_offense(<<~RUBY)
        if a +
           b
           ^ Use 4 (not 3) spaces for indenting a condition in an `if` statement spanning multiple lines.
          something
        end
      RUBY

      expect_correction(<<~RUBY)
        if a +
            b
          something
        end
      RUBY
    end

    it 'accepts the indentation of a broken string' do
      expect_no_offenses(<<~'RUBY')
        MSG = 'Use 2 (not %d) spaces for indenting a ' \
              'broken line.'
      RUBY
    end

    it 'accepts normal indentation of method parameters' do
      expect_no_offenses(<<~RUBY)
        Parser::Source::Range.new(expr.source_buffer,
                                  begin_pos,
                                  begin_pos + line.length)
      RUBY
    end

    it 'accepts any indentation of method parameters' do
      expect_no_offenses(<<~RUBY)
        a(b +
            c +
        d)
      RUBY
    end

    it 'accepts normal indentation inside grouped expression' do
      expect_no_offenses(<<~RUBY)
        arg_array.size == a.size && (
          arg_array == a ||
          arg_array.map(&:children) == a.map(&:children)
        )
      RUBY
    end

    it 'registers an offense and corrects aligned code on LHS of equality operator' do
      expect_offense(<<~RUBY)
        def config_to_allow_offenses
          a +
          b == c
          ^ Use 2 (not 0) spaces for indenting an expression spanning multiple lines.
        end
      RUBY

      expect_correction(<<~RUBY)
        def config_to_allow_offenses
          a +
            b == c
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
        expect_no_offenses(<<~RUBY)
          #{keyword} receiver.nil? &&
              !args.empty? &&
              FORBIDDEN_METHODS.include?(method_name)
          end
          #{keyword} receiver.
              nil?
          end
        RUBY
      end

      it "registers an offense for a 2 space indentation of #{keyword} condition" do
        expect_offense(<<~RUBY)
          #{keyword} receiver.nil? &&
            !args.empty? &&
            ^^^^^^^^^^^^ Use 4 (not 2) spaces for indenting a condition in #{article} `#{keyword}` statement spanning multiple lines.
            FORBIDDEN_METHODS.include?(method_name)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 4 (not 2) spaces for indenting a condition in #{article} `#{keyword}` statement spanning multiple lines.
          end
        RUBY
      end

      it "accepts indented operands in #{keyword} body" do
        expect_no_offenses(<<~RUBY)
          #{keyword} a
            something &&
              something_else
          end
        RUBY
      end
    end

    %w[unless if].each do |keyword|
      it "accepts indentation of return #{keyword} condition" do
        expect_no_offenses(<<~RUBY)
          return #{keyword} receiver.nil? &&
            !args.empty? &&
            FORBIDDEN_METHODS.include?(method_name)
        RUBY
      end

      it "accepts indentation of next #{keyword} condition" do
        expect_no_offenses(<<~RUBY)
          next #{keyword} 5 ||
            7
        RUBY
      end
    end

    it 'registers an offense and corrects wrong indentation of for expression' do
      expect_offense(<<~RUBY)
        for n in a +
          b
          ^ Use 4 (not 2) spaces for indenting a collection in a `for` statement spanning multiple lines.
        end
      RUBY

      expect_correction(<<~RUBY)
        for n in a +
            b
        end
      RUBY
    end

    it 'accepts special indentation of for expression' do
      expect_no_offenses(<<~RUBY)
        for n in a +
            b
        end
      RUBY
    end

    it 'accepts indentation of assignment' do
      expect_no_offenses(<<~RUBY)
        a = b +
          c +
          d
      RUBY
    end

    it 'registers an offense and corrects correct + unrecognized style' do
      expect_offense(<<~RUBY)
        a ||
          b
        c and
            d
            ^ Use 2 (not 4) spaces for indenting an expression spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a ||
          b
        c and
          d
      RUBY
    end

    it 'registers an offense and corrects aligned operators in assignment' do
      expect_offense(<<~RUBY)
        a = b +
            c +
            ^ Use 2 (not 4) spaces for indenting an expression in an assignment spanning multiple lines.
            d
            ^ Use 2 (not 4) spaces for indenting an expression in an assignment spanning multiple lines.
      RUBY

      expect_correction(<<~RUBY)
        a = b +
          c +
          d
      RUBY
    end

    context 'when indentation width is overridden for this cop' do
      let(:cop_indent) { 6 }

      it 'accepts indented operands in if condition' do
        expect_no_offenses(<<~RUBY)
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
          expect_no_offenses(<<~RUBY)
            #{keyword} receiver.nil? &&
                    !args.empty? &&
                    FORBIDDEN_METHODS.include?(method_name)
            end
            #{keyword} receiver.
                    nil?
            end
          RUBY
        end

        it "registers an offense for a 4 space indentation of #{keyword} condition" do
          expect_offense(<<~RUBY)
            #{keyword} receiver.nil? &&
                !args.empty? &&
                ^^^^^^^^^^^^ Use 8 (not 4) spaces for indenting a condition in #{article} `#{keyword}` statement spanning multiple lines.
                FORBIDDEN_METHODS.include?(method_name)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use 8 (not 4) spaces for indenting a condition in #{article} `#{keyword}` statement spanning multiple lines.
            end
          RUBY
        end

        it "accepts indented operands in #{keyword} body" do
          expect_no_offenses(<<~RUBY)
            #{keyword} a
              something &&
                    something_else
            end
          RUBY
        end
      end

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          until a +
                b
                ^ Use 8 (not 6) spaces for indenting a condition in an `until` statement spanning multiple lines.
            something
          end
        RUBY

        expect_correction(<<~RUBY)
          until a +
                  b
            something
          end
        RUBY
      end
    end
  end
end
