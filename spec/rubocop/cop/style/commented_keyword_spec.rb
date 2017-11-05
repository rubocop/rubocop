# frozen_string_literal: true

describe RuboCop::Cop::Style::CommentedKeyword do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when commenting on the same line as `end`' do
    inspect_source(<<-RUBY.strip_indent)
      if x
        y
      end # comment
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `end` keyword.'])
  end

  it 'registers an offense when commenting on the same line as `begin`' do
    inspect_source(<<-RUBY.strip_indent)
      begin # comment
        y
      end
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `begin` keyword.'])
  end

  it 'registers an offense when commenting on the same line as `class`' do
    inspect_source(<<-RUBY.strip_indent)
      class X # comment
        y
      end
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `class` keyword.'])
  end

  it 'registers an offense when commenting on the same line as `module`' do
    inspect_source(<<-RUBY.strip_indent)
      module X # comment
        y
      end
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `module` keyword.'])
  end

  it 'registers an offense when commenting on the same line as `def`' do
    inspect_source(<<-RUBY.strip_indent)
      def x # comment
        y
      end
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `def` keyword.'])
  end

  it 'registers an offense when commenting on indented keywords' do
    inspect_source(<<-RUBY.strip_indent)
      module X
        class Y # comment
          z
        end
      end
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `class` keyword.'])
  end

  it 'registers an offense when commenting after keyword with spaces' do
    inspect_source(<<-RUBY.strip_indent)
      def x(a, b) # comment
        y
      end
    RUBY
    expect(cop.highlights).to eq(['# comment'])
    expect(cop.messages).to eq(['Do not place comments on the same line as ' \
                                'the `def` keyword.'])
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
end
