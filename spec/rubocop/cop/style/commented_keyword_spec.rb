# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CommentedKeyword do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when commenting on the same line as `end`' do
    expect_offense(<<-RUBY.strip_indent)
      if x
        y
      end # comment
          ^^^^^^^^^ Do not place comments on the same line as the `end` keyword.
    RUBY
  end

  it 'registers an offense when commenting on the same line as `begin`' do
    expect_offense(<<-RUBY.strip_indent)
      begin # comment
            ^^^^^^^^^ Do not place comments on the same line as the `begin` keyword.
        y
      end
    RUBY
  end

  it 'registers an offense when commenting on the same line as `class`' do
    expect_offense(<<-RUBY.strip_indent)
      class X # comment
              ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
        y
      end
    RUBY
  end

  it 'registers an offense when commenting on the same line as `module`' do
    expect_offense(<<-RUBY.strip_indent)
      module X # comment
               ^^^^^^^^^ Do not place comments on the same line as the `module` keyword.
        y
      end
    RUBY
  end

  it 'registers an offense when commenting on the same line as `def`' do
    expect_offense(<<-RUBY.strip_indent)
      def x # comment
            ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
    RUBY
  end

  it 'registers an offense when commenting on indented keywords' do
    expect_offense(<<-RUBY.strip_indent)
      module X
        class Y # comment
                ^^^^^^^^^ Do not place comments on the same line as the `class` keyword.
          z
        end
      end
    RUBY
  end

  it 'registers an offense when commenting after keyword with spaces' do
    expect_offense(<<-RUBY.strip_indent)
      def x(a, b) # comment
                  ^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
        y
      end
    RUBY
  end

  it 'registers an offense for one-line cases' do
    expect_offense(<<-RUBY.strip_indent)
      def x; end # comment'
                 ^^^^^^^^^^ Do not place comments on the same line as the `def` keyword.
    RUBY
  end

  it 'does not register an offense if there are no comments after keywords' do
    expect_no_offenses(<<-RUBY.strip_indent)
      if x
        y
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      class X
        y
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        x
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      def x
        y
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      module X
        y
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      # module Y # trap comment
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      'end' # comment
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      <<-HEREDOC
        def # not a comment
      HEREDOC
    RUBY
  end

  it 'does not register an offense for certain comments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class X # :nodoc:
        y
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      class X
        def y # :yields:
          yield
        end
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      def x # rubocop:disable Metrics/MethodLength
        y
      end
    RUBY
  end

  it 'does not register an offense if AST contains # symbol' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def x(y = "#value")
        y
      end
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      def x(y: "#value")
        y
      end
    RUBY
  end

  it 'accepts keyword letter sequences that are not keywords' do
    expect_no_offenses(<<-RUBY.strip_indent)
      options = {
        end_buttons: true, # comment
      }
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      defined?(SomeModule).should be_nil # comment
    RUBY
    expect_no_offenses(<<-RUBY.strip_indent)
      foo = beginning_statement # comment
    RUBY
  end
end
