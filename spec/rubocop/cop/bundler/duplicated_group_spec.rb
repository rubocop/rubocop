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
        expect_offense(<<~RUBY, 'Gemfile')
          group :development do
            gem 'rubocop'
          end
          group :development do
          ^^^^^^^^^^^^^^^^^^ Gem group `:development` already defined on line 1 of the Gemfile.
            gem 'rubocop-rails'
          end
        RUBY
      end
    end

    context 'and a group is duplicated using different argument types' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          group :development do
            gem 'rubocop'
          end
          group 'development' do
          ^^^^^^^^^^^^^^^^^^^ Gem group `'development'` already defined on line 1 of the Gemfile.
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

    context 'and same groups with different keyword names' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          group :test, foo: true do
            gem 'activesupport'
          end

          group :test, bar: true do
            gem 'rspec'
          end
        RUBY
      end
    end

    context 'and same groups with different keyword values' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          group :test, foo: true do
            gem 'activesupport'
          end

          group :test, foo: false do
            gem 'rspec'
          end
        RUBY
      end
    end

    context 'and same groups with same keyword option and the option order is the same' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          group :test, foo: true, bar: true do
            gem 'activesupport'
          end

          group :test, foo: true, bar: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem group `:test, foo: true, bar: true` already defined on line 1 of the Gemfile.
            gem 'rspec'
          end
        RUBY
      end
    end

    context 'and same groups with same keyword option and the option order is different' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          group :test, foo: true, bar: true do
            gem 'activesupport'
          end

          group :test, bar: true, foo: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem group `:test, bar: true, foo: true` already defined on line 1 of the Gemfile.
            gem 'rspec'
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          group :test, :development do
            gem 'rubocop'
          end
          group :development, :test do
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Gem group `:development, :test` already defined on line 1 of the Gemfile.
            gem 'rubocop-rails'
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated and `group` value is a splat value' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          group(*LIVE_ENVS) do
            gem 'admin_ui'
          end

          group(*LIVE_ENVS) do
          ^^^^^^^^^^^^^^^^^ Gem group `*LIVE_ENVS` already defined on line 1 of the Gemfile.
            gem 'public_ui'
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated but `source` URLs are different' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          source 'https://rubygems.pkg.github.com/private-org' do
            group :development do
              gem 'rubocop'
            end
          end

          group :development do
            gem 'rubocop-rails'
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated and `source` URLs are the same' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          source 'https://rubygems.pkg.github.com/private-org' do
            group :development do
              gem 'rubocop'
            end
          end

          source 'https://rubygems.pkg.github.com/private-org' do
            group :development do
            ^^^^^^^^^^^^^^^^^^ Gem group `:development` already defined on line 2 of the Gemfile.
              gem 'rubocop-rails'
            end
          end

          group :development do
            gem 'rubocop-performance'
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated but `git` URLs are different' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          git 'https://github.com/rubocop/rubocop.git' do
            group :default do
              gem 'rubocop'
            end
          end

          git 'https://github.com/rails/rails.git' do
            group :default do
              gem 'activesupport'
              gem 'actionpack'
            end
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated and `git` URLs are the same' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          git 'https://github.com/rails/rails.git' do
            group :default do
              gem 'activesupport'
            end
          end

          git 'https://github.com/rails/rails.git' do
            group :default do
            ^^^^^^^^^^^^^^ Gem group `:default` already defined on line 2 of the Gemfile.
              gem 'actionpack'
            end
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated but `platforms` values are different' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          platforms :ruby do
            group :default do
              gem 'openssl'
            end
          end

          platforms :jruby do
            group :default do
              gem 'jruby-openssl'
            end
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated and `platforms` values are the same' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          platforms :ruby do
            group :default do
              gem 'ruby-debug'
            end
          end

          platforms :ruby do
            group :default do
            ^^^^^^^^^^^^^^ Gem group `:default` already defined on line 2 of the Gemfile.
              gem 'sqlite3'
            end
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated but `path` values are different' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          path 'components_admin' do
            group :default do
              gem 'admin_ui'
            end
          end

          path 'components_public' do
            group :default do
              gem 'public_ui'
            end
          end
        RUBY
      end
    end

    context 'and a set of groups is duplicated and `path` values are the same' do
      it 'registers an offense' do
        expect_offense(<<~RUBY, 'Gemfile')
          path 'components' do
            group :default do
              gem 'admin_ui'
            end
          end

          path 'components' do
            group :default do
            ^^^^^^^^^^^^^^ Gem group `:default` already defined on line 2 of the Gemfile.
              gem 'public_ui'
            end
          end
        RUBY
      end
    end

    context 'when `source` URL argument is not given' do
      it 'does not crash' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          source do
            group :development do
              gem 'rubocop'
            end
          end
        RUBY
      end
    end
  end
end
