# frozen_string_literal: true

describe RuboCop::Cop::Bundler::OrderedGems, :config do
  let(:cop_config) do
    {
      'TreatCommentsAsGroupSeparators' => treat_comments_as_group_separators,
      'Include' => nil
    }
  end
  let(:treat_comments_as_group_separators) { false }
  let(:message) do
    'Gems should be sorted in an alphabetical order within their ' \
      'section of the Gemfile. Gem `%s` should appear before `%s`.'
  end
  subject(:cop) { described_class.new(config) }

  context 'When gems are alphabetically sorted' do
    it 'does not register any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        gem 'rspec'
        gem 'rubocop'
      RUBY
    end
  end

  context 'When gems are not alphabetically sorted' do
    let(:source) { <<-RUBY.strip_indent }
      gem 'rubocop'
      gem 'rspec'
    RUBY

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'rubocop'
        gem 'rspec'
        ^^^^^^^^^^^ #{format(message, 'rspec', 'rubocop')}
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        gem 'rspec'
        gem 'rubocop'
      RUBY
    end
  end

  context 'When each individual group of line is sorted' do
    it 'does not register any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        gem 'rspec'
        gem 'rubocop'

        gem 'hello'
        gem 'world'
      RUBY
    end
  end

  context 'When a gem declaration takes several lines' do
    let(:source) { <<-RUBY.strip_indent }
      gem 'rubocop',
          '0.1.1'
      gem 'rspec'
    RUBY

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'rubocop',
            '0.1.1'
        gem 'rspec'
        ^^^^^^^^^^^ #{format(message, 'rspec', 'rubocop')}
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        gem 'rspec'
        gem 'rubocop',
            '0.1.1'
      RUBY
    end
  end

  context 'When the gemfile is empty' do
    it 'does not register any offenses' do
      expect_no_offenses('# Gemfile')
    end
  end

  context 'When each individual group of line is not sorted' do
    let(:source) { <<-RUBY.strip_indent }
        gem "d"
        gem "b"
        gem "e"
        gem "a"
        gem "c"

        gem "h"
        gem "g"
        gem "j"
        gem "f"
        gem "i"
    RUBY

    it 'registers some offenses' do
      expect_offense(<<-RUBY.strip_indent)
        gem "d"
        gem "b"
        ^^^^^^^ #{format(message, 'b', 'd')}
        gem "e"
        gem "a"
        ^^^^^^^ #{format(message, 'a', 'e')}
        gem "c"

        gem "h"
        gem "g"
        ^^^^^^^ #{format(message, 'g', 'h')}
        gem "j"
        gem "f"
        ^^^^^^^ #{format(message, 'f', 'j')}
        gem "i"
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        gem "a"
        gem "b"
        gem "c"
        gem "d"
        gem "e"

        gem "f"
        gem "g"
        gem "h"
        gem "i"
        gem "j"
      RUBY
    end
  end

  context 'When gem groups is separated by multiline comment' do
    let(:source) { <<-RUBY.strip_indent }
      # For code quality
      gem 'rubocop'
      # For
      # test
      gem 'rspec'
    RUBY

    context 'with TreatCommentsAsGroupSeparators: true' do
      let(:treat_comments_as_group_separators) { true }

      it 'accepts' do
        expect_no_offenses(<<-RUBY.strip_indent)
          # For code quality
          gem 'rubocop'
          # For
          # test
          gem 'rspec'
        RUBY
      end
    end

    context 'with TreatCommentsAsGroupSeparators: false' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          # For code quality
          gem 'rubocop'
          # For
          # test
          gem 'rspec'
          ^^^^^^^^^^^ #{format(message, 'rspec', 'rubocop')}
        RUBY
      end

      it 'autocorrects' do
        new_source = autocorrect_source_with_loop(cop, source)
        expect(new_source).to eq(<<-RUBY.strip_indent)
          # For
          # test
          gem 'rspec'
          # For code quality
          gem 'rubocop'
        RUBY
      end
    end
  end

  context 'When gems have an inline comment, and not sorted' do
    let(:source) { <<-RUBY.strip_indent }
      gem 'rubocop' # For code quality
      gem 'pry'
      gem 'rspec'   # For test
    RUBY

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'rubocop' # For code quality
        gem 'pry'
        ^^^^^^^^^ #{format(message, 'pry', 'rubocop')}
        gem 'rspec'   # For test
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        gem 'pry'
        gem 'rspec'   # For test
        gem 'rubocop' # For code quality
      RUBY
    end
  end

  context 'When gems are asciibetically sorted' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        gem 'paper_trail'
        gem 'paperclip'
      RUBY
    end
  end

  context 'When a gem that starts with a capital letter is sorted' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        gem 'a'
        gem 'Z'
      RUBY
    end
  end

  context 'When a gem that starts with a capital letter is not sorted' do
    let(:source) { <<-RUBY.strip_indent }
      gem 'Z'
      gem 'a'
    RUBY

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        gem 'Z'
        gem 'a'
        ^^^^^^^ #{format(message, 'a', 'Z')}
      RUBY
    end

    it 'autocorrects' do
      new_source = autocorrect_source_with_loop(cop, source)
      expect(new_source).to eq(<<-RUBY.strip_indent)
        gem 'a'
        gem 'Z'
      RUBY
    end
  end
end
