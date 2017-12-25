# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::HeredocDelimiterCase, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(described_class.badge.to_s => cop_config)
  end

  context 'when enforced style is uppercase' do
    let(:cop_config) do
      {
        'SupportedStyles' => %w[uppercase lowercase],
        'EnforcedStyle' => 'uppercase'
      }
    end

    context 'with an interpolated heredoc' do
      it 'registers an offense with a lowercase delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<-sql
            foo
          sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY
      end

      it 'registers an offense with a camel case delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<-Sql
            foo
          Sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY
      end

      it 'does not register an offense with an uppercase delimiter' do
        expect_no_offenses(<<-RUBY.strip_indent)
          <<-SQL
            foo
          SQL
        RUBY
      end
    end

    context 'with a non-interpolated heredoc' do
      context 'when using single quoted delimiters' do
        it 'registers an offense with a lowercase delimiter' do
          expect_offense(<<-RUBY.strip_indent)
            <<-'sql'
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY
        end

        it 'registers an offense with a camel case delimiter' do
          expect_offense(<<-RUBY.strip_indent)
            <<-'Sql'
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY
        end

        it 'does not register an offense with an uppercase delimiter' do
          expect_no_offenses(<<-RUBY.strip_indent)
            <<-'SQL'
              foo
            SQL
          RUBY
        end
      end

      context 'when using double quoted delimiters' do
        it 'registers an offense with a lowercase delimiter' do
          expect_offense(<<-RUBY.strip_indent)
            <<-"sql"
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY
        end

        it 'registers an offense with a camel case delimiter' do
          expect_offense(<<-RUBY.strip_indent)
            <<-"Sql"
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY
        end

        it 'does not register an offense with an uppercase delimiter' do
          expect_no_offenses(<<-RUBY.strip_indent)
            <<-"SQL"
              foo
            SQL
          RUBY
        end
      end

      context 'when using back tick delimiters' do
        it 'registers an offense with a lowercase delimiter' do
          expect_offense(<<-RUBY.strip_indent)
            <<-`sql`
              foo
            sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY
        end

        it 'registers an offense with a camel case delimiter' do
          expect_offense(<<-RUBY.strip_indent)
            <<-`Sql`
              foo
            Sql
            ^^^ Use uppercase heredoc delimiters.
          RUBY
        end

        it 'does not register an offense with an uppercase delimiter' do
          expect_no_offenses(<<-RUBY.strip_indent)
            <<-`SQL`
              foo
            SQL
          RUBY
        end
      end

      context 'when using non-word delimiters' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            <<-'+'
              foo
            +
          RUBY
        end
      end
    end

    context 'with a squiggly heredoc', :ruby23 do
      it 'registers an offense with a lowercase delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<~sql
            foo
          sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY
      end

      it 'registers an offense with a camel case delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<~Sql
            foo
          Sql
          ^^^ Use uppercase heredoc delimiters.
        RUBY
      end

      it 'does not register an offense with an uppercase delimiter' do
        expect_no_offenses(<<-RUBY.strip_indent)
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
        expect_no_offenses(<<-RUBY.strip_indent)
          <<-sql
            foo
          sql
        RUBY
      end

      it 'registers an offense with a camel case delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<-Sql
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
        RUBY
      end

      it 'registers an offense with an uppercase delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<-SQL
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
        RUBY
      end
    end

    context 'with a non-interpolated heredoc' do
      it 'does not reguster an offense with a lowercase delimiter' do
        expect_no_offenses(<<-RUBY.strip_indent)
          <<-'sql'
            foo
          sql
        RUBY
      end

      it 'registers an offense with a camel case delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<-'Sql'
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
        RUBY
      end

      it 'registers an offense with an uppercase delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<-'SQL'
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
        RUBY
      end
    end

    context 'with a squiggly heredoc', :ruby23 do
      it 'does not register an offense with a lowercase delimiter' do
        expect_no_offenses(<<-RUBY.strip_indent)
          <<~sql
            foo
          sql
        RUBY
      end

      it 'registers an offense with a camel case delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<~Sql
            foo
          Sql
          ^^^ Use lowercase heredoc delimiters.
        RUBY
      end

      it 'registers an offense with an uppercase delimiter' do
        expect_offense(<<-RUBY.strip_indent)
          <<~SQL
            foo
          SQL
          ^^^ Use lowercase heredoc delimiters.
        RUBY
      end
    end
  end
end
