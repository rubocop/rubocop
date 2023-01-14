# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::HeredocDelimiterNaming, :config do
  let(:cop_config) { { 'ForbiddenDelimiters' => %w[END] } }

  context 'with an interpolated heredoc' do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<~RUBY)
        <<-END
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<~RUBY)
        <<-SQL
          foo
        SQL
      RUBY
    end
  end

  context 'with a non-interpolated heredoc' do
    context 'when using single quoted delimiters' do
      it 'registers an offense with a non-meaningful delimiter' do
        expect_offense(<<~RUBY)
          <<-'END'
            foo
          END
          ^^^ Use meaningful heredoc delimiters.
        RUBY
      end

      it 'does not register an offense with a meaningful delimiter' do
        expect_no_offenses(<<~RUBY)
          <<-'SQL'
            foo
          SQL
        RUBY
      end
    end

    context 'when using double quoted delimiters' do
      it 'registers an offense with a non-meaningful delimiter' do
        expect_offense(<<~RUBY)
          <<-"END"
            foo
          END
          ^^^ Use meaningful heredoc delimiters.
        RUBY
      end

      it 'does not register an offense with a meaningful delimiter' do
        expect_no_offenses(<<~RUBY)
          <<-'SQL'
            foo
          SQL
        RUBY
      end
    end

    context 'when using back tick delimiters' do
      it 'registers an offense with a non-meaningful delimiter' do
        expect_offense(<<~RUBY)
          <<-`END`
            foo
          END
          ^^^ Use meaningful heredoc delimiters.
        RUBY
      end

      it 'does not register an offense with a meaningful delimiter' do
        expect_no_offenses(<<~RUBY)
          <<-`SQL`
            foo
          SQL
        RUBY
      end
    end

    context 'when using non-word delimiters' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          <<-'+'
            foo
          +
          ^ Use meaningful heredoc delimiters.
        RUBY
      end
    end
  end

  context 'with a squiggly heredoc' do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<~RUBY)
        <<~END
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<~RUBY)
        <<~SQL
          foo
        SQL
      RUBY
    end
  end

  context 'with a naked heredoc' do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<~RUBY)
        <<END
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<~RUBY)
        <<SQL
          foo
        SQL
      RUBY
    end
  end

  context 'when the delimiter contains non-letter characters' do
    it 'does not register an offense when delimiter contains an underscore' do
      expect_no_offenses(<<~RUBY)
        <<-SQL_CODE
          foo
        SQL_CODE
      RUBY
    end

    it 'does not register an offense when delimiter contains a number' do
      expect_no_offenses(<<~RUBY)
        <<-BASE64
          foo
        BASE64
      RUBY
    end
  end

  context 'with multiple heredocs starting on the same line' do
    it 'registers an offense with a leading non-meaningful delimiter' do
      expect_offense(<<~RUBY)
        foo(<<-END, <<-SQL)
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
          bar
        SQL
      RUBY
    end

    it 'registers an offense with a trailing non-meaningful delimiter' do
      expect_offense(<<~RUBY)
        foo(<<-SQL, <<-END)
          foo
        SQL
          bar
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with meaningful delimiters' do
      expect_no_offenses(<<~RUBY)
        foo(<<-SQL, <<-JS)
          foo
        SQL
          bar
        JS
      RUBY
    end
  end
end
