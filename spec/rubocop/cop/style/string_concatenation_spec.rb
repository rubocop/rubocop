# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringConcatenation, :config do
  it 'registers an offense and corrects for string concatenation' do
    expect_offense(<<~RUBY)
      email_with_name = user.name + ' <' + user.email + '>'
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
    RUBY

    expect_correction(<<~RUBY)
      email_with_name = "\#{user.name} <\#{user.email}>"
    RUBY
  end

  it 'registers an offense and corrects for string concatenation as part of other expression' do
    expect_offense(<<~RUBY)
      users = (user.name + ' ' + user.email) * 5
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
    RUBY

    expect_correction(<<~RUBY)
      users = ("\#{user.name} \#{user.email}") * 5
    RUBY
  end

  it 'correctly handles strings with special characters' do
    expect_offense(<<-RUBY)
      email_with_name = "\\n" + user.name + ' ' + user.email + '\\n'
                        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
    RUBY

    expect_correction(<<-RUBY)
      email_with_name = "\\n\#{user.name} \#{user.email}\\\\n"
    RUBY
  end

  it 'correctly handles nested concatenatable parts' do
    expect_offense(<<~RUBY)
      (user.vip? ? greeting + ', ' : '') + user.name + ' <' + user.email + '>'
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
                   ^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
    RUBY

    expect_correction(<<~RUBY)
      "\#{(user.vip? ? "\#{greeting}, " : '')}\#{user.name} <\#{user.email}>"
    RUBY
  end

  it 'does not register an offense when using `+` with all non string arguments' do
    expect_no_offenses(<<~RUBY)
      user.name + user.email
    RUBY
  end

  context 'multiline' do
    context 'string continuation' do
      it 'does not register an offense' do
        # handled by `Style/LineEndConcatenation` instead.
        expect_no_offenses(<<~RUBY)
          "this is a long string " +
            "this is a continuation"
        RUBY
      end
    end

    context 'simple expressions' do
      it 'registers an offense and corrects' do
        expect_offense(<<-RUBY)
          email_with_name = user.name +
                            ^^^^^^^^^^^ Prefer string interpolation to string concatenation.
            ' ' +
            user.email +
            '\\n'
        RUBY

        expect_correction(<<-RUBY)
          email_with_name = "\#{user.name} \#{user.email}\\\\n"
        RUBY
      end
    end

    context 'if condition' do
      it 'registers an offense but does not correct' do
        expect_offense(<<~RUBY)
          "result:" + if condition
          ^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
            "true"
          else
            "false"
          end
        RUBY

        expect_no_corrections
      end
    end

    context 'multiline block' do
      it 'registers an offense but does not correct' do
        expect_offense(<<~RUBY)
          '(' + values.map do |v|
          ^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
              v.titleize
          end.join(', ') + ')'
        RUBY

        expect_no_corrections
      end
    end
  end

  context 'nested interpolation' do
    it 'registers an offense and corrects' do
      expect_offense(<<~'RUBY')
        "foo" + "bar: #{baz}"
        ^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<~'RUBY')
        "foobar: #{baz}"
      RUBY
    end
  end

  context 'inline block' do
    it 'registers an offense but does not correct' do
      expect_offense(<<~RUBY)
        '(' + values.map { |v| v.titleize }.join(', ') + ')'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_no_corrections
    end
  end

  context 'heredoc' do
    it 'registers an offense but does not correct' do
      expect_offense(<<~RUBY)
        "foo" + <<~STR
        ^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
          text
        STR
      RUBY

      expect_no_corrections
    end

    it 'registers an offense but does not correct when string concatenation with multiline heredoc text' do
      expect_offense(<<~RUBY)
        "foo" + <<~TEXT
        ^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
          bar
          baz
        TEXT
      RUBY

      expect_no_corrections
    end
  end

  context 'double quotes inside string' do
    it 'registers an offense and corrects with double quotes' do
      expect_offense(<<-'RUBY')
        email_with_name = "He said " + "\"Arrest that man!\"."
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<-'RUBY')
        email_with_name = "He said \"Arrest that man!\"."
      RUBY
    end

    it 'registers an offense and corrects with percentage quotes' do
      expect_offense(<<-RUBY)
        email_with_name = %(He said ) + %("Arrest that man!".)
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<-'RUBY')
        email_with_name = "He said \"Arrest that man!\"."
      RUBY
    end
  end

  context 'empty quotes' do
    it 'registers offense and corrects' do
      expect_offense(<<-RUBY)
        '"' + "foo" + '"'
        ^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        '"' + "foo" + "'"
        ^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        "'" + "foo" + '"'
        ^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        "'" + "foo" + '"' + "bar"
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<-'RUBY')
        "\"foo\""
        "\"foo'"
        "'foo\""
        "'foo\"bar"
      RUBY
    end
  end

  context 'double quotes inside string surrounded single quotes' do
    it 'registers an offense and corrects with double quotes' do
      expect_offense(<<-RUBY)
        '"bar"' + foo
        ^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<-'RUBY')
        "\"bar\"#{foo}"
      RUBY
    end
  end

  context 'Mode = conservative' do
    let(:cop_config) { { 'Mode' => 'conservative' } }

    context 'when first operand is not string literal' do
      it 'does not register offense' do
        expect_no_offenses(<<~RUBY)
          user.name + "!!"
          user.name + "<"
          user.name + "<" + "user.email" + ">"
        RUBY
      end
    end

    context 'when first operand is string literal' do
      it 'registers offense' do
        expect_offense(<<~RUBY)
          "Hello " + user.name
          ^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
          "Hello " + user.name + "!!"
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        RUBY

        expect_correction(<<~RUBY)
          "Hello \#{user.name}"
          "Hello \#{user.name}!!"
        RUBY
      end
    end
  end
end
