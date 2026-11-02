# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::MultilineMethodCallBraceLayout, :config do
  let(:enforced_style) { 'symmetrical' }
  let(:cop_config) { { 'EnforcedStyle' => enforced_style } }

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

  context 'when `Lint/HeredocMethodCallPosition` is enabled' do
    let(:other_cops) { { 'Lint/HeredocMethodCallPosition' => { 'Enabled' => true } } }

    it 'does not register an offense when the last argument is a method call after the HEREDOC terminator' do
      expect_no_offenses(<<~RUBY)
        foo(<<~EOS
          text
        EOS
        .do_something
        )
      RUBY
    end

    it 'does not register an offense when the last argument is a safe navigation method call after the HEREDOC terminator' do
      expect_no_offenses(<<~RUBY)
        foo(<<~EOS
          text
        EOS
        &.do_something
        )
      RUBY
    end

    it 'registers an offense when the last argument is a method call on the HEREDOC opening line' do
      expect_offense(<<~RUBY)
        foo(<<~EOS.do_something, arg
          text
        EOS
        )
        ^ Closing method call brace must be on the same line as the last argument when opening brace is on the same line as the first argument.
      RUBY

      expect_correction(<<~RUBY)
        foo(<<~EOS.do_something, arg)
          text
        EOS
      RUBY
    end
  end

  context 'when `Lint/HeredocMethodCallPosition` is disabled' do
    let(:other_cops) { { 'Lint/HeredocMethodCallPosition' => { 'Enabled' => false } } }

    it 'registers an offense when the last argument is a method call after the HEREDOC terminator' do
      expect_offense(<<~RUBY)
        foo(<<~EOS
          text
        EOS
        .do_something
        )
        ^ Closing method call brace must be on the same line as the last argument when opening brace is on the same line as the first argument.
      RUBY

      expect_correction(<<~RUBY)
        foo(<<~EOS
          text
        EOS
        .do_something)
      RUBY
    end
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
    let(:enforced_style) { 'new_line' }

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

    context 'with EnforcedStyle: same_line' do
      let(:enforced_style) { 'same_line' }

      it 'registers an offense and corrects when the last argument is a hash whose last element has a comment' do
        expect_offense(<<~RUBY)
          foo(
            {
              bar: 1 # comment
            }
          )
          ^ Closing method call brace must be on the same line as the last argument.
        RUBY

        expect_correction(<<~RUBY)
          foo(
            {
              bar: 1 # comment
            })
        RUBY
      end

      it 'registers an offense and corrects when a comment line precedes the closing brace followed by a method call' do
        expect_offense(<<~RUBY)
          foo(
            bar,
            # comment
          ).baz
          ^ Closing method call brace must be on the same line as the last argument.
        RUBY

        expect_correction(<<~RUBY)
          foo(
            bar,).baz
            # comment
        RUBY
      end
    end
  end

  context 'with safe navigation' do
    it 'ignores single-line calls' do
      expect_no_offenses('foo&.bar(1,2)')
    end

    context 'with EnforcedStyle: symmetrical' do
      let(:enforced_style) { 'symmetrical' }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo&.bar(
            baz)
               ^ Closing method call brace must be on the line after the last argument when opening brace is on a separate line from the first argument.
        RUBY

        expect_correction(<<~RUBY)
          foo&.bar(
            baz
          )
        RUBY
      end
    end

    context 'with EnforcedStyle: new_line' do
      let(:enforced_style) { 'new_line' }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo&.bar(
            baz)
               ^ Closing method call brace must be on the line after the last argument.
        RUBY

        expect_correction(<<~RUBY)
          foo&.bar(
            baz
          )
        RUBY
      end
    end

    context 'with EnforcedStyle: same_line' do
      let(:enforced_style) { 'same_line' }

      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          foo&.bar(
            baz
          )
          ^ Closing method call brace must be on the same line as the last argument.
        RUBY

        expect_correction(<<~RUBY)
          foo&.bar(
            baz)
        RUBY
      end
    end
  end
end
