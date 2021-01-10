# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CommentedKeyword, :config do
  let(:config) { RuboCop::Config.new }

  it 'registers an offense and corrects when commenting on the same line as `end`' do
    expect_offense(<<~RUBY)
      if x
        y
      end # comment
          ^^^^^^^^^ Do not place comments on the same line as the `end` keyword.
    RUBY

    expect_correction(<<~RUBY)
      if x
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `begin`' do
    expect_offense(<<~RUBY)
      begin # comment
            ^^^^^^^^^ Do not place comments on the same line as the `begin` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      begin
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `class`' do
    expect_offense(<<~RUBY)
      class X # comment
              ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      class X
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `module`' do
    expect_offense(<<~RUBY)
      module X # comment
               ^^^^^^^^^ Do not place comments on the same line as the `module` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      module X
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on the same line as `def`' do
    expect_offense(<<~RUBY)
      def x # comment
            ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      def x
        y
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting on indented keywords' do
    expect_offense(<<~RUBY)
      module X
        class Y # comment
                ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
          z
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      module X
      # comment
        class Y
          z
        end
      end
    RUBY
  end

  it 'registers an offense and corrects when commenting after keyword with spaces' do
    expect_offense(<<~RUBY)
      def x(a, b) # comment
                  ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
    RUBY

    expect_correction(<<~RUBY)
      # comment
      def x(a, b)
        y
      end
    RUBY
  end

  it 'registers an offense and corrects for one-line cases' do
    expect_offense(<<~RUBY)
      def x; end # comment
                 ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
    RUBY

    expect_correction(<<~RUBY)
      # comment
      def x; end
    RUBY
  end

  it 'does not register an offense if there are no comments after keywords' do
    expect_no_offenses(<<~RUBY)
      if x
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      class X
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      begin
        x
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      module X
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      # module Y # trap comment
    RUBY
    expect_no_offenses(<<~RUBY)
      'end' # comment
    RUBY
    expect_no_offenses(<<~RUBY)
      <<-HEREDOC
        def # not a comment
      HEREDOC
    RUBY
  end

  it 'does not register an offense for certain comments' do
    expect_no_offenses(<<~RUBY)
      class X # :nodoc:
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      class X
        def y # :yields:
          yield
        end
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x # rubocop:disable Metrics/MethodLength
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x # rubocop:todo Metrics/MethodLength
        y
      end
    RUBY
  end

  it 'does not register an offense if AST contains # symbol' do
    expect_no_offenses(<<~RUBY)
      def x(y = "#value")
        y
      end
    RUBY
    expect_no_offenses(<<~RUBY)
      def x(y: "#value")
        y
      end
    RUBY
  end

  it 'accepts keyword letter sequences that are not keywords' do
    expect_no_offenses(<<~RUBY)
      options = {
        end_buttons: true, # comment
      }
    RUBY
    expect_no_offenses(<<~RUBY)
      defined?(SomeModule).should be_nil # comment
    RUBY
    expect_no_offenses(<<~RUBY)
      foo = beginning_statement # comment
    RUBY
  end
end
