# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringLiteralsInInterpolation, :config do
  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers an offense for double quotes within embedded expression' do
      expect_offense(<<~'RUBY')
        "#{"A"}"
           ^^^ Prefer single-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{'A'}"
      RUBY
    end

    it 'registers an offense for double quotes within embedded expression in a heredoc string' do
      expect_offense(<<~'SOURCE')
        <<RUBY
        #{"A"}
          ^^^ Prefer single-quoted strings inside interpolations.
        RUBY
      SOURCE

      expect_correction(<<~'SOURCE')
        <<RUBY
        #{'A'}
        RUBY
      SOURCE
    end

    it 'accepts double quotes on a static string' do
      expect_no_offenses('"A"')
    end

    it 'accepts double quotes on a broken static string' do
      expect_no_offenses(<<~'RUBY')
        "A" \
          "B"
      RUBY
    end

    it 'accepts double quotes on static strings within a method' do
      expect_no_offenses(<<~RUBY)
        def m
          puts "A"
          puts "B"
        end
      RUBY
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<~RUBY)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end

    it 'can handle character literals' do
      expect_no_offenses('a = ?/')
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers an offense for single quotes within embedded expression' do
      expect_offense(<<~'RUBY')
        "#{'A'}"
           ^^^ Prefer double-quoted strings inside interpolations.
      RUBY

      expect_correction(<<~'RUBY')
        "#{"A"}"
      RUBY
    end

    it 'registers an offense for single quotes within embedded expression in a heredoc string' do
      expect_offense(<<~'SOURCE')
        <<RUBY
        #{'A'}
          ^^^ Prefer double-quoted strings inside interpolations.
        RUBY
      SOURCE

      expect_correction(<<~'SOURCE')
        <<RUBY
        #{"A"}
        RUBY
      SOURCE
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { expect_no_offenses('a = "#{"b"}"') }.to raise_error(RuntimeError)
    end
  end
end
