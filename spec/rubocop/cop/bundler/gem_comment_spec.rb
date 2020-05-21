# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::GemComment, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    {
      'Include' => ['**/Gemfile'],
      'IgnoredGems' => ['rake'],
      'OnlyWhenUsingAnyOf' => []
    }
  end

  context 'when investigating Ruby files' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY)
        gem('rubocop')
      RUBY
    end
  end

  context 'when investigating Gemfiles' do
    context 'and the file is empty' do
      it 'does not register any offenses' do
        expect_no_offenses('', 'Gemfile')
      end
    end

    context 'and the gem is commented' do
      it 'does not register any offenses' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          # Style-guide enforcer.
          gem 'rubocop'
        RUBY
      end
    end

    context 'and the gem is permitted' do
      it 'does not register any offenses' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          gem 'rake'
        RUBY
      end
    end

    context 'and the file contains source and group' do
      it 'does not register any offenses' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          source 'http://rubygems.org'

          # Style-guide enforcer.
          group :development do
            # …
          end
        RUBY
      end
    end

    context 'and a gem has no comment' do
      it 'registers an offense' do
        expect_offense(<<-GEM, 'Gemfile')
          gem 'rubocop'
          ^^^^^^^^^^^^^ Missing gem description comment.
        GEM
      end
    end

    context 'and the OnlyWhenUsingAnyOf option is set' do
      before { cop_config['OnlyWhenUsingAnyOf'] = checked_options }

      context 'and version specifiers are checked' do
        let(:checked_options) { ['with_version_specifiers'] }

        it 'does not register an offense if a gem is commented' do
          expect_no_offenses(<<~RUBY, 'Gemfile')
            # Style-guide enforcer.
            gem 'rubocop'
          RUBY
        end

        it 'does not register an offense if an uncommented gem has no options' do
          expect_no_offenses(<<-GEM, 'Gemfile')
            gem 'rubocop'
          GEM
        end

        it 'does not register an offense if an uncommented gem has options but no version specifiers' do
          expect_no_offenses(<<-GEM, 'Gemfile')
            gem 'rubocop', group: development
          GEM
        end

        it 'registers an offense if an uncommented gem has a version specifier' do
          expect_offense(<<-GEM, 'Gemfile')
              gem 'rubocop', '~> 12.0'
              ^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
          GEM
        end

        it 'registers an offense if an uncommented gem has multiple version specifiers' do
          expect_offense(<<-GEM, 'Gemfile')
              gem 'rubocop', '~> 12.0', '>= 11.0'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
          GEM
        end

        it 'registers an offense if an uncommented gem has version specifiers and unrelated options' do
          expect_offense(<<-GEM, 'Gemfile')
            gem 'rubocop', '~> 12.0', required: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
          GEM
        end
      end

      context 'and some other options are checked' do
        let(:checked_options) { %w[github required] }

        it 'registers an offense if an uncommented gem has one of the checked options' do
          expect_offense(<<-GEM, 'Gemfile')
            gem 'rubocop', github: 'some_user/some_fork'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
          GEM
        end

        it 'does not register an offense if an uncommented gem has version specifiers but no other options' do
          expect_no_offenses(<<-GEM, 'Gemfile')
            gem 'rubocop', '~> 12.0'
          GEM
        end

        it 'does not register an offense if an uncommented gem has only unchecked options' do
          expect_no_offenses(<<-GEM, 'Gemfile')
            gem 'rubocop', group: development
          GEM
        end
      end
    end
  end
end
