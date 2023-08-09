# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::DuplicatedGroup, :config do
  let(:cop_config) { { 'Include' => ['**/Gemfile'] } }

  context 'when investigating Ruby files' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY, 'foo.rb')
        # cop will not read these contents
        group :development
        group :development
      RUBY
    end
  end

  context 'when investigating Gemfiles' do
    context 'and the file is empty' do
      it 'does not register any offenses' do
        expect_no_offenses('', 'Gemfile')
      end
    end

    context 'and no duplicate groups are present' do
      it 'does not register any offenses' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          group :development do
            gem 'rubocop'
          end
          group :test do
            gem 'flog'
          end
        RUBY
      end
    end

    context 'and a group is duplicated' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'Gemfile')
          group :development do
            gem 'rubocop'
          end
          group :development do
          ^^^^^^^^^^^^^^^^^^ Gem group `development` already defined on line 1 of the Gemfile.
            gem 'rubocop-rails'
          end
        RUBY
      end
    end

    context 'and a group is duplicated using different argument types' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'Gemfile')
          group :development do
            gem 'rubocop'
          end
          group 'development' do
          ^^^^^^^^^^^^^^^^^^^ Gem group `development` already defined on line 1 of the Gemfile.
            gem 'rubocop-rails'
          end
        RUBY
      end
    end

    context 'and a group is present in different sets of groups' do
      it 'does not register any offenses' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          group :development do
            gem 'rubocop'
          end
          group :development, :test do
            gem 'rspec'
          end
          group :ci, :development do
            gem 'flog'
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'Gemfile')
          group :test, :development do
            gem 'rubocop'
          end
          group :development, :test do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Gem group `development, test` already defined on line 1 of the Gemfile.
            gem 'rubocop-rails'
          end
        RUBY
      end
    end
  end
end
