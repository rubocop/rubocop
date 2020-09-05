# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringConcatenation do
  subject(:cop) { described_class.new }

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

  it 'does not register an offense when using `+` with all non string arguments' do
    expect_no_offenses(<<~RUBY)
      user.name + user.email
    RUBY
  end

  context 'multiline' do
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
    it 'registers an offense but does not correct' do
      expect_offense(<<~RUBY)
        "foo" + "bar: \#{baz}"
        ^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_no_corrections
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
  end
end
