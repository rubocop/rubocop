# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringConcatenation, :config do
  shared_examples 'string concatenation' do |node|
    it 'registers an offense and corrects for string concatenation' do
      expect_offense(<<~RUBY, node: node)
        email_with_name = user.name %{node} ' <' %{node} user.email %{node} '>'
                          ^^^^^^^^^^^{node}^^^^^^^{node}^^^^^^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<~RUBY)
        email_with_name = "\#{user.name} <\#{user.email}>"
      RUBY
    end

    it 'registers an offense and corrects for string concatenation as part of other expression' do
      expect_offense(<<~RUBY, node: node)
        users = (user.name %{node} ' ' %{node} user.email) * 5
                 ^^^^^^^^^^^{node}^^^^^^{node}^^^^^^^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<~RUBY)
        users = ("\#{user.name} \#{user.email}") * 5
      RUBY
    end

    it 'correctly handles strings with special characters' do
      expect_offense(<<-RUBY, node: node)
        email_with_name = "\\n" %{node} user.name %{node} ' ' %{node} user.email %{node} '\\n'
                          ^^^^^^^{node}^^^^^^^^^^^^{node}^^^^^^{node}^^^^^^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<-RUBY)
        email_with_name = "\\n\#{user.name} \#{user.email}\\\\n"
      RUBY
    end

    it 'correctly handles nested concatenable parts' do
      expect_offense(<<~RUBY, node: node)
        (user.vip? ? greeting %{node} ', ' : '') %{node} user.name %{node} ' <' %{node} user.email %{node} '>'
        ^^^^^^^^^^^^^^^^^^^^^^^{node}^^^^^^^^^^^^^{node}^^^^^^^^^^^^{node}^^^^^^^{node}^^^^^^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
                     ^^^^^^^^^^{node}^^^^^ Prefer string interpolation to string concatenation.
      RUBY

      expect_correction(<<~RUBY)
        "\#{(user.vip? ? "\#{greeting}, " : '')}\#{user.name} <\#{user.email}>"
      RUBY
    end

    it "does not register an offense when using `#{node}` with all non string arguments" do
      expect_no_offenses(<<~RUBY)
        user.name #{node} user.email
      RUBY
    end

    context 'multiline' do
      context 'string continuation' do
        it 'does not register an offense' do
          # handled by `Style/LineEndConcatenation` instead.
          expect_no_offenses(<<~RUBY)
            "this is a long string " #{node}
              "this is a continuation"
          RUBY
        end
      end

      context 'simple expressions' do
        it 'registers an offense and corrects' do
          expect_offense(<<-RUBY, node: node)
            email_with_name = user.name %{node}
                              ^^^^^^^^^^^{node} Prefer string interpolation to string concatenation.
              ' ' %{node}
              user.email %{node}
              '\\n'
          RUBY

          expect_correction(<<-RUBY)
            email_with_name = "\#{user.name} \#{user.email}\\\\n"
          RUBY
        end
      end

      context 'if condition' do
        it 'registers an offense but does not correct' do
          expect_offense(<<~RUBY, node: node)
            "result:" %{node} if condition
            ^^^^^^^^^^^{node}^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
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
          expect_offense(<<~RUBY, node: node)
            '(' %{node} values.map do |v|
            ^^^^^{node}^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
                v.titleize
            end.join(', ') %{node} ')'
          RUBY

          expect_no_corrections
        end
      end
    end

    context 'nested interpolation' do
      it 'registers an offense and corrects' do
        expect_offense(<<~'RUBY', node: node)
          "foo" %{node} "bar: #{baz}"
          ^^^^^^^{node}^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        RUBY

        expect_correction(<<~'RUBY')
          "foobar: #{baz}"
        RUBY
      end
    end

    context 'inline block' do
      it 'registers an offense but does not correct' do
        expect_offense(<<~RUBY, node: node)
          '(' %{node} values.map { |v| v.titleize }.join(', ') %{node} ')'
          ^^^^^{node}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
        RUBY

        expect_no_corrections
      end
    end

    context 'heredoc' do
      it 'registers an offense but does not correct' do
        expect_offense(<<~RUBY, node: node)
          "foo" %{node} <<~STR
          ^^^^^^^{node}^^^^^^^ Prefer string interpolation to string concatenation.
            text
          STR
        RUBY

        expect_no_corrections
      end

      it 'registers an offense but does not correct when string concatenation with multiline heredoc text' do
        expect_offense(<<~RUBY, node: node)
          "foo" %{node} <<~TEXT
          ^^^^^^^{node}^^^^^^^^ Prefer string interpolation to string concatenation.
            bar
            baz
          TEXT
        RUBY

        expect_no_corrections
      end
    end

    context 'double quotes inside string' do
      it 'registers an offense and corrects with double quotes' do
        expect_offense(<<-'RUBY', node: node)
          email_with_name = "He said " %{node} "\"Arrest that man!\"."
                            ^^^^^^^^^^^^{node}^^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        RUBY

        expect_correction(<<-'RUBY')
          email_with_name = "He said \"Arrest that man!\"."
        RUBY
      end

      it 'registers an offense and corrects with percentage quotes' do
        expect_offense(<<-RUBY, node: node)
          email_with_name = %(He said ) %{node} %("Arrest that man!".)
                            ^^^^^^^^^^^^^{node}^^^^^^^^^^^^^^^^^^^^^^^ Prefer string interpolation to string concatenation.
        RUBY

        expect_correction(<<-'RUBY')
          email_with_name = "He said \"Arrest that man!\"."
        RUBY
      end
    end

    context 'empty quotes' do
      it 'registers offense and corrects' do
        expect_offense(<<-RUBY, node: node)
          '"' %{node} "foo" %{node} '"'
          ^^^^^{node}^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
          '"' %{node} "foo" %{node} "'"
          ^^^^^{node}^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
          "'" %{node} "foo" %{node} '"'
          ^^^^^{node}^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
          "'" %{node} "foo" %{node} '"' %{node} "bar"
          ^^^^^{node}^^^^^^^^{node}^^^^^^{node}^^^^^^ Prefer string interpolation to string concatenation.
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
        expect_offense(<<-RUBY, node: node)
          '"bar"' %{node} foo
          ^^^^^^^^^{node}^^^^ Prefer string interpolation to string concatenation.
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
            user.name #{node} "!!"
            user.name #{node} "<"
            user.name #{node} "<" #{node} "user.email" #{node} ">"
          RUBY
        end
      end

      context 'when first operand is string literal' do
        it 'registers offense' do
          expect_offense(<<~RUBY, node: node)
            "Hello " %{node} user.name
            ^^^^^^^^^^{node}^^^^^^^^^^ Prefer string interpolation to string concatenation.
            "Hello " %{node} user.name %{node} "!!"
            ^^^^^^^^^^{node}^^^^^^^^^^^^{node}^^^^^ Prefer string interpolation to string concatenation.
          RUBY

          expect_correction(<<~RUBY)
            "Hello \#{user.name}"
            "Hello \#{user.name}!!"
          RUBY
        end
      end
    end
  end

  it_behaves_like 'string concatenation', :+
  it_behaves_like 'string concatenation', :<<
end
