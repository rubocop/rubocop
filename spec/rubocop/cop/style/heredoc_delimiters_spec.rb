# frozen_string_literal: true

describe RuboCop::Cop::Style::HeredocDelimiters, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Style/HeredocDelimiters' => cop_config)
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
      expect_offense(<<~RUBY.strip_indent)
        <<-'END'
          foo
        END
        ^^^ Use meaningful heredoc delimiters.
      RUBY
    end

    it 'does not register an offense with a meaningful delimiter' do
      expect_no_offenses(<<~RUBY.strip_indent)
        <<-'SQL'
          foo
        SQL
      RUBY
    end
  end
end
