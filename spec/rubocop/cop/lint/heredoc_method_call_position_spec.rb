# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::HeredocMethodCallPosition, :config do
  context 'correct cases' do
    it 'accepts simple correct case' do
      expect_no_offenses(<<~RUBY)
        <<~SQL
          foo
        SQL
      RUBY
    end

    it 'accepts chained correct case' do
      expect_no_offenses(<<~RUBY)
        <<~SQL.bar
          foo
        SQL
      RUBY
    end

    it 'ignores if no call' do
      expect_no_offenses(<<~RUBY)
        <<-SQL
          foo
        SQL
      RUBY
    end
  end

  context 'incorrect cases' do
    context 'simple incorrect case' do
      it 'detects' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          .strip_indent
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          <<-SQL.strip_indent
            foo
          SQL
        RUBY
      end
    end

    context 'simple incorrect case with paren' do
      it 'detects' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          .foo(bar_baz)
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          <<-SQL.foo(bar_baz)
            foo
          SQL
        RUBY
      end
    end

    context 'chained case no parens' do
      it 'detects' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          .strip_indent.foo
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          <<-SQL.strip_indent.foo
            foo
          SQL
        RUBY
      end
    end

    context 'chained case with parens' do
      it 'detects' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          .abc(1, 2, 3).foo
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
        RUBY

        expect_correction(<<~RUBY)
          <<-SQL.abc(1, 2, 3).foo
            foo
          SQL
        RUBY
      end
    end

    context 'with trailing comma in method call' do
      it 'detects' do
        expect_offense(<<~RUBY)
          bar(<<-SQL
            foo
          SQL
          .abc,
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
          )
        RUBY

        expect_correction(<<~RUBY)
          bar(<<-SQL.abc,
            foo
          SQL
          )
        RUBY
      end
    end

    context 'chained case with multiple line args' do
      it 'detects' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          .abc(1, 2,
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
          3).foo
        RUBY

        expect_no_corrections
      end
    end

    context 'chained case without args' do
      it 'detects' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          .abc
          ^ Put a method call with a HEREDOC receiver on the same line as the HEREDOC opening.
          .foo
        RUBY

        expect_no_corrections
      end
    end
  end
end
