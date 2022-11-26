# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineMethodCallBraceLayout, :config do
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit calls' do
    expect_no_offenses(<<~RUBY)
      foo 1,
      2
    RUBY
  end

  it 'ignores single-line calls' do
    expect_no_offenses('foo(1,2)')
  end

  it 'ignores calls without arguments' do
    expect_no_offenses('puts')
  end

  it 'ignores calls with an empty brace' do
    expect_no_offenses('puts()')
  end

  it 'ignores calls with a multiline empty brace' do
    expect_no_offenses(<<~RUBY)
      puts(
      )
    RUBY
  end

  it 'registers an offense when using method chain for heredoc argument in multiline literal brace layout' do
    expect_offense(<<~RUBY)
      foo(<<~EOS, arg
        text
      EOS
      ).do_something
      ^ Closing method call brace must be on the same line as the last argument when opening brace is on the same line as the first argument.
    RUBY

    expect_correction(<<~RUBY)
      foo(<<~EOS, arg).do_something
        text
      EOS
    RUBY
  end

  it 'registers an offense when using safe navigation method chain for heredoc argument in multiline literal brace layout' do
    expect_offense(<<~RUBY)
      foo(<<~EOS, arg
        text
      EOS
      )&.do_something
      ^ Closing method call brace must be on the same line as the last argument when opening brace is on the same line as the first argument.
    RUBY

    expect_correction(<<~RUBY)
      foo(<<~EOS, arg)&.do_something
        text
      EOS
    RUBY
  end

  it_behaves_like 'multiline literal brace layout' do
    let(:open) { 'foo(' }
    let(:close) { ')' }
  end

  it_behaves_like 'multiline literal brace layout trailing comma' do
    let(:open) { 'foo(' }
    let(:close) { ')' }

    let(:same_line_message) do
      'Closing method call brace must be on the same line as the last ' \
        'argument when opening [...]'
    end
    let(:always_same_line_message) do
      'Closing method call brace must be on the same line as the last argument.'
    end
  end

  context 'when EnforcedStyle is new_line' do
    let(:cop_config) { { 'EnforcedStyle' => 'new_line' } }

    it 'still ignores single-line calls' do
      expect_no_offenses('puts("Hello world!")')
    end

    it 'ignores single-line calls with multi-line receiver' do
      expect_no_offenses(<<~RUBY)
        [
        ].join(" ")
      RUBY
    end

    it 'ignores single-line calls with multi-line receiver with leading dot' do
      expect_no_offenses(<<~RUBY)
        [
        ]
        .join(" ")
      RUBY
    end
  end

  context 'when comment present before closing brace' do
    it 'corrects closing brace without crashing' do
      expect_offense(<<~RUBY)
        super(bar(baz,
          ham # comment
        ))
        ^ Closing method call brace must be on the same line as the last argument when opening brace is on the same line as the first argument.
      RUBY

      expect_correction(<<~RUBY)
        super(bar(baz,
          ham)) # comment
      RUBY
    end
  end
end
