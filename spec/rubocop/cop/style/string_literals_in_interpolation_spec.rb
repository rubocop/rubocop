# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StringLiteralsInInterpolation, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured with single quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'single_quotes' } }

    it 'registers an offense for double quotes within embedded expression' do
      src = '"#{"A"}"'
      inspect_source(src)
      expect(cop.messages)
        .to eq(['Prefer single-quoted strings inside interpolations.'])
    end

    it 'registers an offense for double quotes within embedded expression in ' \
       'a heredoc string' do
      src = ['<<RUBY',
             '#{"A"}',
             'RUBY']
      inspect_source(src)
      expect(cop.messages)
        .to eq(['Prefer single-quoted strings inside interpolations.'])
    end

    it 'accepts double quotes on a static string' do
      expect_no_offenses('"A"')
    end

    it 'accepts double quotes on a broken static string' do
      expect_no_offenses(<<-RUBY.strip_indent)
        "A" \
          "B"
      RUBY
    end

    it 'accepts double quotes on static strings within a method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def m
          puts "A"
          puts "B"
        end
      RUBY
    end

    it 'can handle a built-in constant parsed as string' do
      # Parser will produce str nodes for constants such as __FILE__.
      expect_no_offenses(<<-RUBY.strip_indent)
        if __FILE__ == $PROGRAM_NAME
        end
      RUBY
    end

    it 'can handle character literals' do
      expect_no_offenses('a = ?/')
    end

    it 'auto-corrects " with \'' do
      new_source = autocorrect_source('s = "#{"abc"}"')
      expect(new_source).to eq(%q(s = "#{'abc'}"))
    end
  end

  context 'configured with double quotes preferred' do
    let(:cop_config) { { 'EnforcedStyle' => 'double_quotes' } }

    it 'registers an offense for single quotes within embedded expression' do
      src = %q("#{'A'}")
      inspect_source(src)
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings inside interpolations.'])
    end

    it 'registers an offense for single quotes within embedded expression in ' \
       'a heredoc string' do
      src = ['<<RUBY',
             '#{\'A\'}',
             'RUBY']
      inspect_source(src)
      expect(cop.messages)
        .to eq(['Prefer double-quoted strings inside interpolations.'])
    end
  end

  context 'when configured with a bad value' do
    let(:cop_config) { { 'EnforcedStyle' => 'other' } }

    it 'fails' do
      expect { inspect_source('a = "#{"b"}"') }
        .to raise_error(RuntimeError)
    end
  end
end
