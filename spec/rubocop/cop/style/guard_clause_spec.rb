# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::GuardClause, :config do
  let(:other_cops) do
    {
      'Layout/LineLength' => {
        'Enabled' => line_length_enabled,
        'Max' => 80
      }
    }
  end
  let(:line_length_enabled) { true }

  shared_examples 'reports offense' do |body|
    it 'reports an offense if method body is if / unless without else' do
      expect_offense(<<~RUBY)
        def func
          if something
          ^^ Use a guard clause (`return unless something`) instead of wrapping the code inside a conditional expression.
            #{body}
          end
        end

        def func
          unless something
          ^^^^^^ Use a guard clause (`return if something`) instead of wrapping the code inside a conditional expression.
            #{body}
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          return unless something
            #{body}
         #{trailing_whitespace}
        end

        def func
          return if something
            #{body}
         #{trailing_whitespace}
        end
      RUBY
    end

    it 'reports an offense if method body ends with if / unless without else' do
      expect_offense(<<~RUBY)
        def func
          test
          if something
          ^^ Use a guard clause (`return unless something`) instead of wrapping the code inside a conditional expression.
            #{body}
          end
        end

        def func
          test
          unless something
          ^^^^^^ Use a guard clause (`return if something`) instead of wrapping the code inside a conditional expression.
            #{body}
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          test
          return unless something
            #{body}
         #{trailing_whitespace}
        end

        def func
          test
          return if something
            #{body}
         #{trailing_whitespace}
        end
      RUBY
    end
  end

  it_behaves_like('reports offense', 'work')
  it_behaves_like('reports offense', '# TODO')
  it_behaves_like('reports offense', 'do_something(foo)')

  it 'does not report an offense if body is if..elsif..end' do
    expect_no_offenses(<<~RUBY)
      def func
        if something
          a
        elsif something_else
          b
        end
      end
    RUBY
  end

  it "doesn't report an offense if condition has multiple lines" do
    expect_no_offenses(<<~RUBY)
      def func
        if something &&
             something_else
          work
        end
      end

      def func
        unless something &&
                 something_else
          work
        end
      end
    RUBY
  end

  it 'accepts a method which body is if / unless with else' do
    expect_no_offenses(<<~RUBY)
      def func
        if something
          work
        else
          test
        end
      end

      def func
        unless something
          work
        else
          test
        end
      end
    RUBY
  end

  it 'registers an offense when using `|| raise` in `then` branch' do
    expect_offense(<<~RUBY)
      def func
        if something
        ^^ Use a guard clause (`work || raise('message') if something`) instead of wrapping the code inside a conditional expression.
          work || raise('message')
        else
          test
        end
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `|| raise` in `else` branch' do
    expect_offense(<<~RUBY)
      def func
        if something
        ^^ Use a guard clause (`test || raise('message') unless something`) instead of wrapping the code inside a conditional expression.
          work
        else
          test || raise('message')
        end
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `raise` in `else` branch in a one-liner with `then`' do
    expect_offense(<<~RUBY)
      if something then work else raise('message') end
      ^^ Use a guard clause (`raise('message') unless something`) instead of wrapping the code inside a conditional expression.
    RUBY

    expect_correction(<<~RUBY)
      raise('message') unless something#{trailing_whitespace}
       work#{trailing_whitespace * 3}
    RUBY
  end

  it 'registers an offense when using `and return` in `then` branch' do
    expect_offense(<<~RUBY)
      def func
        if something
        ^^ Use a guard clause (`work and return if something`) instead of wrapping the code inside a conditional expression.
          work and return
        else
          test
        end
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when using `and return` in `else` branch' do
    expect_offense(<<~RUBY)
      def func
        if something
        ^^ Use a guard clause (`test and return unless something`) instead of wrapping the code inside a conditional expression.
          work
        else
          test and return
        end
      end
    RUBY

    expect_no_corrections
  end

  it 'accepts a method which body does not end with if / unless' do
    expect_no_offenses(<<~RUBY)
      def func
        if something
          work
        end
        test
      end

      def func
        unless something
          work
        end
        test
      end
    RUBY
  end

  it 'accepts a method whose body is a modifier if / unless' do
    expect_no_offenses(<<~RUBY)
      def func
        work if something
      end

      def func
        work unless something
      end
    RUBY
  end

  it 'accepts a method with empty parentheses as its body' do
    expect_no_offenses(<<~RUBY)
      def func
        ()
      end
    RUBY
  end

  it 'does not register an offense when assigning the result of a guard condition with `else`' do
    expect_no_offenses(<<~RUBY)
      def func
        result = if something
          work || raise('message')
        else
          test
        end
      end
    RUBY
  end

  it 'registers an offense when using heredoc as an argument of raise in `then` branch' do
    expect_offense(<<~RUBY)
      def func
        if condition
        ^^ Use a guard clause (`raise <<~MESSAGE unless condition`) instead of wrapping the code inside a conditional expression.
          foo
        else
          raise <<~MESSAGE
            oops
          MESSAGE
        end
      end
    RUBY

    # NOTE: Let `Layout/HeredocIndentation`, `Layout/ClosingHeredocIndentation`, and
    #       `Layout/IndentationConsistency` cops autocorrect inconsistent indentations.
    expect_correction(<<~RUBY)
      def func
        raise <<~MESSAGE unless condition
            oops
          MESSAGE
      foo
      end
    RUBY
  end

  it 'registers an offense when using heredoc as an argument of raise in `else` branch' do
    expect_offense(<<~RUBY)
      def func
        unless condition
        ^^^^^^ Use a guard clause (`raise <<~MESSAGE unless condition`) instead of wrapping the code inside a conditional expression.
          raise <<~MESSAGE
            oops
          MESSAGE
        else
          foo
        end
      end
    RUBY

    # NOTE: Let `Layout/HeredocIndentation`, `Layout/ClosingHeredocIndentation`, and
    #       `Layout/IndentationConsistency` cops autocorrect inconsistent indentations.
    expect_correction(<<~RUBY)
      def func
        raise <<~MESSAGE unless condition
            oops
          MESSAGE
      foo
      end
    RUBY
  end

  it 'registers an offense when using heredoc as an argument of raise in `then` branch and it does not have `else` branch' do
    expect_offense(<<~RUBY)
      def func
        if condition
        ^^ Use a guard clause (`return unless condition`) instead of wrapping the code inside a conditional expression.
          raise <<~MESSAGE
            oops
          MESSAGE
        end
      end
    RUBY

    # NOTE: Let `Layout/HeredocIndentation`, `Layout/ClosingHeredocIndentation`, and
    #       `Layout/IndentationConsistency` cops autocorrect inconsistent indentations.
    expect_correction(<<~RUBY)
      def func
        return unless condition
          raise <<~MESSAGE
            oops
          MESSAGE
        end
      end
    RUBY
  end

  it 'registers an offense when using xstr heredoc as an argument of raise in `else` branch' do
    expect_offense(<<~RUBY)
      def func
        unless condition
        ^^^^^^ Use a guard clause (`raise <<~`MESSAGE` unless condition`) instead of wrapping the code inside a conditional expression.
          raise <<~`MESSAGE`
            oops
          MESSAGE
        else
          foo
        end
      end
    RUBY

    # NOTE: Let `Layout/HeredocIndentation`, `Layout/ClosingHeredocIndentation`, and
    #       `Layout/IndentationConsistency` cops autocorrect inconsistent indentations.
    expect_correction(<<~RUBY)
      def func
        raise <<~`MESSAGE` unless condition
            oops
          MESSAGE
      foo
      end
    RUBY
  end

  it 'registers an offense when using lvar as an argument of raise in `else` branch' do
    expect_offense(<<~RUBY)
      if condition
      ^^ Use a guard clause (`raise e unless condition`) instead of wrapping the code inside a conditional expression.
        do_something
      else
        raise e
      end
    RUBY

    # NOTE: Let `Layout/TrailingWhitespace`, `Layout/EmptyLine`, and
    #       `Layout/EmptyLinesAroundMethodBody` cops autocorrect inconsistent indentations
    #       and blank lines.
    expect_correction(<<~RUBY)
      raise e unless condition
        do_something

       #{trailing_whitespace}

    RUBY
  end

  context 'MinBodyLength: 1' do
    let(:cop_config) { { 'MinBodyLength' => 1 } }

    it 'reports an offense for if whose body has 1 line' do
      expect_offense(<<~RUBY)
        def func
          if something
          ^^ Use a guard clause (`return unless something`) instead of wrapping the code inside a conditional expression.
            work
          end
        end

        def func
          unless something
          ^^^^^^ Use a guard clause (`return if something`) instead of wrapping the code inside a conditional expression.
            work
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def func
          return unless something
            work
         #{trailing_whitespace}
        end

        def func
          return if something
            work
         #{trailing_whitespace}
        end
      RUBY
    end
  end

  context 'MinBodyLength: 4' do
    let(:cop_config) { { 'MinBodyLength' => 4 } }

    it 'accepts a method whose body has 3 lines' do
      expect_no_offenses(<<~RUBY)
        def func
          if something
            work
            work
            work
          end
        end

        def func
          unless something
            work
            work
            work
          end
        end
      RUBY
    end
  end

  context 'Invalid MinBodyLength' do
    let(:cop_config) { { 'MinBodyLength' => -2 } }

    it 'fails with an error' do
      source = <<~RUBY
        def func
          if something
            work
          end
        end
      RUBY

      expect { expect_no_offenses(source) }
        .to raise_error('MinBodyLength needs to be a positive integer!')
    end
  end

  context 'AllowConsecutiveConditionals: false' do
    let(:cop_config) { { 'AllowConsecutiveConditionals' => false } }

    it 'reports an offense when not allowed same depth multiple if statement and' \
       'preceding expression is a conditional at the same depth' do
      expect_offense(<<~RUBY)
        def func
          if foo?
            work
          end

          if bar?
          ^^ Use a guard clause (`return unless bar?`) instead of wrapping the code inside a conditional expression.
            work
          end
        end
      RUBY
    end
  end

  context 'AllowConsecutiveConditionals: true' do
    let(:cop_config) { { 'AllowConsecutiveConditionals' => true } }

    it 'does not register an offense when allowed same depth multiple if statement and' \
       'preceding expression is not a conditional at the same depth' do
      expect_no_offenses(<<~RUBY)
        def func
          if foo?
            work
          end

          if bar?
            work
          end
        end
      RUBY
    end

    it 'reports an offense when allowed same depth multiple if statement and' \
       'preceding expression is not a conditional at the same depth' do
      expect_offense(<<~RUBY)
        def func
          if foo?
            work
          end

          do_something

          if bar?
          ^^ Use a guard clause (`return unless bar?`) instead of wrapping the code inside a conditional expression.
            work
          end
        end
      RUBY
    end
  end

  shared_examples 'on if nodes which exit current scope' do |kw|
    it "registers an error with #{kw} in the if branch" do
      expect_offense(<<~RUBY)
        if something
        ^^ Use a guard clause (`#{kw} if something`) instead of wrapping the code inside a conditional expression.
          #{kw}
        else
          puts "hello"
        end
      RUBY

      expect_correction(<<~RUBY)
        #{kw} if something
         #{trailing_whitespace}

          puts "hello"

      RUBY
    end

    it "registers an error with #{kw} in the else branch" do
      expect_offense(<<~RUBY)
        if something
        ^^ Use a guard clause (`#{kw} unless something`) instead of wrapping the code inside a conditional expression.
         puts "hello"
        else
          #{kw}
        end
      RUBY

      expect_correction(<<~RUBY)
        #{kw} unless something
         puts "hello"

         #{trailing_whitespace}

      RUBY
    end

    it "doesn't register an error if condition has multiple lines" do
      expect_no_offenses(<<~RUBY)
        if something &&
             something_else
          #{kw}
        else
          puts "hello"
        end
      RUBY
    end

    it "does not report an offense if #{kw} is inside elsif" do
      expect_no_offenses(<<~RUBY)
        if something
          a
        elsif something_else
          #{kw}
        end
      RUBY
    end

    it "does not report an offense if #{kw} is inside then body of if..elsif..end" do
      expect_no_offenses(<<~RUBY)
        if something
          #{kw}
        elsif something_else
          a
        end
      RUBY
    end

    it "does not report an offense if #{kw} is inside if..elsif..else..end" do
      expect_no_offenses(<<~RUBY)
        if something
          a
        elsif something_else
          b
        else
          #{kw}
        end
      RUBY
    end

    it "doesn't register an error if control flow expr has multiple lines" do
      expect_no_offenses(<<~RUBY)
        if something
          #{kw} 'blah blah blah' \\
                'blah blah blah'
        else
          puts "hello"
        end
      RUBY
    end

    it 'registers an error if non-control-flow branch has multiple lines' do
      expect_offense(<<~RUBY)
        if something
        ^^ Use a guard clause (`#{kw} if something`) instead of wrapping the code inside a conditional expression.
          #{kw}
        else
          puts "hello" \\
               "blah blah blah"
        end
      RUBY

      expect_correction(<<~RUBY)
        #{kw} if something
         #{trailing_whitespace}

          puts "hello" \\
               "blah blah blah"

      RUBY
    end
  end

  context 'with Metrics/MaxLineLength enabled' do
    context 'when the correction is too long for a single line' do
      context 'with a trivial body' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            def test
              if something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
                work
              end
            end
          RUBY
        end
      end

      context 'with a nested `if` node' do
        it 'does registers an offense' do
          expect_offense(<<~RUBY)
            def test
              if something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
              ^^ Use a guard clause (`unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line; return; end`) instead of wrapping the code inside a conditional expression.
                if something_else
                ^^ Use a guard clause (`return unless something_else`) instead of wrapping the code inside a conditional expression.
                  work
                end
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            def test
              unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
              return
            end
                return unless something_else
                  work
               #{trailing_whitespace}
             #{trailing_whitespace}
            end
          RUBY
        end
      end

      context 'with a nested `begin` node' do
        it 'does registers an offense' do
          expect_offense(<<~RUBY)
            def test
              if something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
              ^^ Use a guard clause (`unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line; return; end`) instead of wrapping the code inside a conditional expression.
                work
                more_work
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            def test
              unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
              return
            end
                work
                more_work
             #{trailing_whitespace}
            end
          RUBY
        end
      end
    end
  end

  context 'with Metrics/MaxLineLength disabled' do
    let(:line_length_enabled) { false }

    it 'registers an offense with modifier example code regardless of length' do
      expect_offense(<<~RUBY)
        def test
          if something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
          ^^ Use a guard clause (`return unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line`) instead of wrapping the code inside a conditional expression.
            work
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        def test
          return unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
            work
         #{trailing_whitespace}
        end
      RUBY
    end
  end

  include_examples('on if nodes which exit current scope', 'return')
  include_examples('on if nodes which exit current scope', 'next')
  include_examples('on if nodes which exit current scope', 'break')
  include_examples('on if nodes which exit current scope', 'raise "error"')

  context 'method in module' do
    it 'registers an offense for instance method' do
      expect_offense(<<~RUBY)
        module CopTest
          def test
            if something
            ^^ Use a guard clause (`return unless something`) instead of wrapping the code inside a conditional expression.
              work
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module CopTest
          def test
            return unless something
              work
           #{trailing_whitespace}
          end
        end
      RUBY
    end

    it 'registers an offense for singleton methods' do
      expect_offense(<<~RUBY)
        module CopTest
          def self.test
            if something && something_else
            ^^ Use a guard clause (`return unless something && something_else`) instead of wrapping the code inside a conditional expression.
              work
            end
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        module CopTest
          def self.test
            return unless something && something_else
              work
           #{trailing_whitespace}
          end
        end
      RUBY
    end
  end
end
