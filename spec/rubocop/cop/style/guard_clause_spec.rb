# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::GuardClause do
  let(:cop) { described_class.new(config) }
  let(:config) do
    RuboCop::Config.new(
      'Layout/LineLength' => {
        'Enabled' => line_length_enabled,
        'Max' => 80
      },
      'Style/GuardClause' => cop_config
    )
  end
  let(:line_length_enabled) { true }
  let(:cop_config) { {} }

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
    end
  end

  it_behaves_like('reports offense', 'work')
  it_behaves_like('reports offense', '# TODO')

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

  context 'MinBodyLength: 1' do
    let(:cop_config) do
      { 'MinBodyLength' => 1 }
    end

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
    end
  end

  context 'MinBodyLength: 4' do
    let(:cop_config) do
      { 'MinBodyLength' => 4 }
    end

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
    let(:cop_config) do
      { 'MinBodyLength' => -2 }
    end

    it 'fails with an error' do
      source = <<~RUBY
        def func
          if something
            work
          end
        end
      RUBY

      expect { inspect_source(source) }
        .to raise_error('MinBodyLength needs to be a positive integer!')
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
    end
  end

  context 'with Metrics/MaxLineLength enabled' do
    it 'registers an offense with non-modifier example code if too long for ' \
       'single line' do
      expect_offense(<<~RUBY)
        def test
          if something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line
          ^^ Use a guard clause (`unless something && something_that_makes_the_guard_clause_too_long_to_fit_on_one_line; return; end`) instead of wrapping the code inside a conditional expression.
            work
          end
        end
      RUBY
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
    end
  end
end
