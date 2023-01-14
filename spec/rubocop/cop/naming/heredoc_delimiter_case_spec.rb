# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::HeredocDelimiterCase, :config do
  context 'when enforced style is uppercase' do
    let(:cop_config) do
      {
        'SupportedStyles' => %w[uppercase lowercase],
        'EnforcedStyle' => 'uppercase'
      }
    end

    context 'with an interpolated heredoc' do
      it 'registers an offense and corrects with a lowercase delimiter' do
        expect_offense(<<~RUBY)
          <<-sql
            foo
          sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<-SQL
            foo
          SQL
        RUBY
      end

      it 'registers an offense with a camel case delimiter' do
        expect_offense(<<~RUBY)
          <<-Sql
            foo
          Sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY
      end

      it 'does not register an offense with an uppercase delimiter' do
        expect_no_offenses(<<~RUBY)
          <<-SQL
            foo
          SQL
        RUBY
      end
    end

    context 'with a non-interpolated heredoc' do
      context 'when using single quoted delimiters' do
        it 'registers an offense and corrects with a lowercase delimiter' do
          expect_offense(<<~RUBY)
            <<-'sql'
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY

          expect_correction(<<~RUBY)
            <<-'SQL'
              foo
            SQL
          RUBY
        end

        it 'registers an offense and corrects with a camel case delimiter' do
          expect_offense(<<~RUBY)
            <<-'Sql'
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY

          expect_correction(<<~RUBY)
            <<-'SQL'
              foo
            SQL
          RUBY
        end

        it 'does not register an offense with an uppercase delimiter' do
          expect_no_offenses(<<~RUBY)
            <<-'SQL'
              foo
            SQL
          RUBY
        end
      end

      context 'when using double quoted delimiters' do
        it 'registers an offense and corrects with a lowercase delimiter' do
          expect_offense(<<~RUBY)
            <<-"sql"
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY

          expect_correction(<<~RUBY)
            <<-"SQL"
              foo
            SQL
          RUBY
        end

        it 'registers an offense and corrects with a camel case delimiter' do
          expect_offense(<<~RUBY)
            <<-"Sql"
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY

          expect_correction(<<~RUBY)
            <<-"SQL"
              foo
            SQL
          RUBY
        end

        it 'does not register an offense with an uppercase delimiter' do
          expect_no_offenses(<<~RUBY)
            <<-"SQL"
              foo
            SQL
          RUBY
        end
      end

      context 'when using back tick delimiters' do
        it 'registers an offense and corrects with a lowercase delimiter' do
          expect_offense(<<~RUBY)
            <<-`sql`
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY

          expect_correction(<<~RUBY)
            <<-`SQL`
              foo
            SQL
          RUBY
        end

        it 'registers an offense and corrects with a camel case delimiter' do
          expect_offense(<<~RUBY)
            <<-`Sql`
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY

          expect_correction(<<~RUBY)
            <<-`SQL`
              foo
            SQL
          RUBY
        end

        it 'does not register an offense with an uppercase delimiter' do
          expect_no_offenses(<<~RUBY)
            <<-`SQL`
              foo
            SQL
          RUBY
        end
      end

      context 'when using non-word delimiters' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            <<-'+'
              foo
            +
          RUBY
        end
      end
    end

    context 'with a squiggly heredoc' do
      it 'registers an offense and corrects with a lowercase delimiter' do
        expect_offense(<<~RUBY)
          <<~sql
            foo
          sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<~SQL
            foo
          SQL
        RUBY
      end

      it 'registers an offense and corrects with a camel case delimiter' do
        expect_offense(<<~RUBY)
          <<~Sql
            foo
          Sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<~SQL
            foo
          SQL
        RUBY
      end

      it 'does not register an offense with an uppercase delimiter' do
        expect_no_offenses(<<~RUBY)
          <<~SQL
            foo
          SQL
        RUBY
      end
    end
  end

  context 'when enforced style is lowercase' do
    let(:cop_config) do
      {
        'SupportedStyles' => %w[uppercase lowercase],
        'EnforcedStyle' => 'lowercase'
      }
    end

    context 'with an interpolated heredoc' do
      it 'does not register an offense with a lowercase delimiter' do
        expect_no_offenses(<<~RUBY)
          <<-sql
            foo
          sql
        RUBY
      end

      it 'registers an offense and corrects with a camel case delimiter' do
        expect_offense(<<~RUBY)
          <<-Sql
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<-sql
            foo
          sql
        RUBY
      end

      it 'registers an offense and corrects with an uppercase delimiter' do
        expect_offense(<<~RUBY)
          <<-SQL
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<-sql
            foo
          sql
        RUBY
      end
    end

    context 'with a non-interpolated heredoc' do
      it 'does not register an offense with a lowercase delimiter' do
        expect_no_offenses(<<~RUBY)
          <<-'sql'
            foo
          sql
        RUBY
      end

      it 'registers an offense and corrects with a camel case delimiter' do
        expect_offense(<<~RUBY)
          <<-'Sql'
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<-'sql'
            foo
          sql
        RUBY
      end

      it 'registers an offense and corrects with an uppercase delimiter' do
        expect_offense(<<~RUBY)
          <<-'SQL'
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<-'sql'
            foo
          sql
        RUBY
      end
    end

    context 'with a squiggly heredoc' do
      it 'does not register an offense with a lowercase delimiter' do
        expect_no_offenses(<<~RUBY)
          <<~sql
            foo
          sql
        RUBY
      end

      it 'registers an offense and corrects with a camel case delimiter' do
        expect_offense(<<~RUBY)
          <<~Sql
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<~sql
            foo
          sql
        RUBY
      end

      it 'registers an offense and corrects with an uppercase delimiter' do
        expect_offense(<<~RUBY)
          <<~SQL
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
        RUBY

        expect_correction(<<~RUBY)
          <<~sql
            foo
          sql
        RUBY
      end
    end
  end
end
