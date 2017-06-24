# frozen_string_literal: true

describe RuboCop::Cop::Style::HeredocDelimiterNaming, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Style/HeredocDelimiterNaming' => cop_config)
  end

  let(:cop_config) do
    { 'Blacklist' => %w[END] }
  end

  context 'with an interpolated heredoc' do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<-RUBY.strip_indent)
        <<-END
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<-RUBY.strip_indent)
        <<-SQL
          foo
        SQL
      RUBY
    end
  end

  context 'with a non-interpolated heredoc', :ruby20 do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<-RUBY.strip_indent)
        <<-'END'
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<-RUBY.strip_indent)
        <<-'SQL'
          foo
        SQL
      RUBY
    end
  end

  context 'with a squiggly heredoc', :ruby23 do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<-RUBY.strip_indent)
        <<~END
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<-RUBY.strip_indent)
        <<~SQL
          foo
        SQL
      RUBY
    end
  end

  context 'with a naked heredoc', :ruby23 do
    it 'registers an offense with a non-meaningful delimiter' do
      expect_offense(<<-RUBY.strip_indent)
        <<END
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<-RUBY.strip_indent)
        <<SQL
          foo
        SQL
      RUBY
    end
  end

  context 'when the delimiter contains non-letter characters' do
    it 'does not register an offense when delimiter contains an underscore' do
      expect_no_offenses(<<-RUBY.strip_indent)
        <<-SQL_CODE
          foo
        SQL_CODE
      RUBY
    end

    it 'does not register an offense when delimiter contains a number' do
      expect_no_offenses(<<-RUBY.strip_indent)
        <<-BASE64
          foo
        BASE64
      RUBY
    end
  end

  context 'with multiple heredocs starting on the same line' do
    it 'registers an offense with a leading non-meaningful delimiter' do
      expect_offense(<<-RUBY.strip_indent)
        foo(<<-END, <<-SQL)
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
          bar
        SQL
      RUBY
    end

    it 'registers an offense with a trailing non-meaningful delimiter' do
      expect_offense(<<-RUBY.strip_indent)
        foo(<<-SQL, <<-END)
          foo
        SQL
          bar
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with meaningful delimiters' do
      expect_no_offenses(<<-RUBY.strip_indent)
        foo(<<-SQL, <<-JS)
          foo
        SQL
          bar
        JS
      RUBY
    end
  end
end
