# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::OrderedGems, :config do
  let(:cop_config) { { 'TreatCommentsAsGroupSeparators' => treat_comments_as_group_separators } }
  let(:treat_comments_as_group_separators) { false }

  context 'When gems are alphabetically sorted' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec'
        gem 'rubocop'
      RUBY
    end
  end

  context 'when a gem is referenced from a variable' do
    it 'ignores the line' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec'
        gem ENV['env_key_undefined'] if ENV.key?('env_key_undefined')
        gem 'rubocop'
      RUBY
    end

    it 'resets the sorting to a new block' do
      expect_no_offenses(<<~RUBY)
        gem 'rubocop'
        gem ENV['env_key_undefined'] if ENV.key?('env_key_undefined')
        gem 'ast'
      RUBY
    end
  end

  context 'When gems are not alphabetically sorted' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        gem 'rubocop'
        gem 'rspec'
        ^^^^^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `rspec` should appear before `rubocop`.
      RUBY

      expect_correction(<<~RUBY)
        gem 'rspec'
        gem 'rubocop'
      RUBY
    end
  end

  context 'When each individual group of line is sorted' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec'
        gem 'rubocop'

        gem 'hello'
        gem 'world'
      RUBY
    end
  end

  context 'When a gem declaration takes several lines' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        gem 'rubocop',
            '0.1.1'
        gem 'rspec'
        ^^^^^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `rspec` should appear before `rubocop`.
      RUBY

      expect_correction(<<~RUBY)
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
    it 'registers some offenses' do
      expect_offense(<<~RUBY)
        gem "d"
        gem "b"
        ^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `b` should appear before `d`.
        gem "e"
        gem "a"
        ^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `a` should appear before `e`.
        gem "c"

        gem "h"
        gem "g"
        ^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `g` should appear before `h`.
        gem "j"
        gem "f"
        ^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `f` should appear before `j`.
        gem "i"
      RUBY

      expect_correction(<<~RUBY)
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
    context 'with TreatCommentsAsGroupSeparators: true' do
      let(:treat_comments_as_group_separators) { true }

      it 'accepts' do
        expect_no_offenses(<<~RUBY)
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
        expect_offense(<<~RUBY)
          # For code quality
          gem 'rubocop'
          # For
          # test
          gem 'rspec'
          ^^^^^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `rspec` should appear before `rubocop`.
        RUBY

        expect_correction(<<~RUBY)
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
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        gem 'rubocop' # For code quality
        gem 'pry'
        ^^^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `pry` should appear before `rubocop`.
        gem 'rspec'   # For test
      RUBY

      expect_correction(<<~RUBY)
        gem 'pry'
        gem 'rspec'   # For test
        gem 'rubocop' # For code quality
      RUBY
    end
  end

  context 'When gems are asciibetically sorted irrespective of _' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        gem 'paperclip'
        gem 'paper_trail'
      RUBY
    end
  end

  context 'When a gem that starts with a capital letter is sorted' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        gem 'a'
        gem 'Z'
      RUBY
    end
  end

  context 'When a gem that starts with a capital letter is not sorted' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        gem 'Z'
        gem 'a'
        ^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `a` should appear before `Z`.
      RUBY

      expect_correction(<<~RUBY)
        gem 'a'
        gem 'Z'
      RUBY
    end
  end

  context 'When a gem is sorted but not so when disregarding _-' do
    context 'by default' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          gem 'active-admin-some_plugin'
          gem 'active_admin_other_plugin'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `active_admin_other_plugin` should appear before `active-admin-some_plugin`.
          gem 'activeadmin'
          ^^^^^^^^^^^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `activeadmin` should appear before `active_admin_other_plugin`.
        RUBY

        expect_correction(<<~RUBY)
          gem 'activeadmin'
          gem 'active_admin_other_plugin'
          gem 'active-admin-some_plugin'
        RUBY
      end
    end

    context 'when ConsiderPunctuation is true' do
      let(:cop_config) { super().merge({ 'ConsiderPunctuation' => true }) }

      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          gem 'active-admin-some_plugin'
          gem 'active_admin_other_plugin'
          gem 'activeadmin'
        RUBY
      end
    end
  end

  context 'When there are duplicated gems in group' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        gem 'a'

        group :development do
          gem 'b'
          gem 'c'
          gem 'b'
          ^^^^^^^ Gems should be sorted in an alphabetical order within their section of the Gemfile. Gem `b` should appear before `c`.
        end
      RUBY

      expect_correction(<<~RUBY)
        gem 'a'

        group :development do
          gem 'b'
          gem 'b'
          gem 'c'
        end
      RUBY
    end
  end
end
