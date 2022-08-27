# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyHeredoc, :config do
  it 'registers an offense when using empty `<<~EOS` heredoc' do
    expect_offense(<<~RUBY)
      <<~EOS
      ^^^^^^ Use an empty string literal instead of heredoc.
      EOS
    RUBY

    expect_correction(<<~RUBY)
      ''
    RUBY
  end

  it 'registers an offense when using empty `<<-EOS` heredoc' do
    expect_offense(<<~RUBY)
      <<-EOS
      ^^^^^^ Use an empty string literal instead of heredoc.
      EOS
    RUBY

    expect_correction(<<~RUBY)
      ''
    RUBY
  end

  it 'registers an offense when using empty `<<EOS` heredoc' do
    expect_offense(<<~RUBY)
      <<EOS
      ^^^^^ Use an empty string literal instead of heredoc.
      EOS
    RUBY

    expect_correction(<<~RUBY)
      ''
    RUBY
  end

  it 'registers an offense when using empty heredoc single argument' do
    expect_offense(<<~RUBY)
      do_something(<<~EOS)
                   ^^^^^^ Use an empty string literal instead of heredoc.
      EOS
    RUBY

    expect_correction(<<~RUBY)
      do_something('')
    RUBY
  end

  it 'registers an offense when using empty heredoc argument with other argument' do
    expect_offense(<<~RUBY)
      do_something(<<~EOS, arg)
                   ^^^^^^ Use an empty string literal instead of heredoc.
      EOS
    RUBY

    expect_correction(<<~RUBY)
      do_something('', arg)
    RUBY
  end

  it 'does not register an offense when using not empty heredoc' do
    expect_no_offenses(<<~RUBY)
      <<~EOS
        Hello.
      EOS
    RUBY
  end

  context 'when double-quoted string literals are preferred' do
    let(:other_cops) do
      super().merge('Style/StringLiterals' => { 'EnforcedStyle' => 'double_quotes' })
    end

    it 'registers an offense when using empty `<<~EOS` heredoc' do
      expect_offense(<<~RUBY)
        <<~EOS
        ^^^^^^ Use an empty string literal instead of heredoc.
        EOS
      RUBY

      expect_correction(<<~RUBY)
        ""
      RUBY
    end
  end
end
