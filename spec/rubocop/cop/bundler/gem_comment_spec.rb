# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::GemComment, :config do
  let(:cop_config) do
    {
      'Include' => ['**/Gemfile'],
      'IgnoredGems' => ['rake'],
      'OnlyFor' => []
    }
  end

  context 'when investigating Ruby files' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY, '/foo.rb')
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

    context 'and the gem is commented on the same line' do
      it 'does not register any offenses' do
        expect_no_offenses(<<~RUBY, 'Gemfile')
          gem 'rubocop' # Style-guide enforcer.
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
        expect_offense(<<-RUBY, 'Gemfile')
          gem 'rubocop'
          ^^^^^^^^^^^^^ Missing gem description comment.
        RUBY
      end
    end

    context 'when the "OnlyFor" option is set' do
      before { cop_config['OnlyFor'] = checked_options }

      context 'including "version_specifiers"' do
        let(:checked_options) { ['version_specifiers'] }

        context 'when a gem is commented' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, 'Gemfile')
              # Style-guide enforcer.
              gem 'rubocop'
            RUBY
          end
        end

        context 'when a gem is uncommented and has no version specified' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
            gem 'rubocop'
            RUBY
          end
        end

        context 'when a gem is uncommented and has options but no version specifiers' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
              gem 'rubocop', group: development
            RUBY
          end
        end

        context 'when a gem is uncommented and has a version specifier' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', '~> 12.0'
                ^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has multiple version specifiers' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', '~> 12.0', '>= 11.0'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has a version specifier along with other options' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
              gem 'rubocop', '~> 12.0', required: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end
      end

      context 'including "restrictive_version_specifiers"' do
        let(:checked_options) { ['restrictive_version_specifiers'] }

        context 'when a gem is commented' do
          it 'does not register an offense' do
            expect_no_offenses(<<~RUBY, 'Gemfile')
              # Style-guide enforcer.
              gem 'rubocop'
            RUBY
          end
        end

        context 'when a gem is uncommented and has no version specified' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
            gem 'rubocop'
            RUBY
          end
        end

        context 'when a gem is uncommented and has options but no version specifiers' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
              gem 'rubocop', group: development
            RUBY
          end
        end

        context 'when a gem is uncommented and has only a minimum version specifier' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
              gem 'rubocop', '>= 12.0'
            RUBY
          end
        end

        context 'when a gem is uncommented and has a non-minimum version specifier with a leading space' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', ' ~> 12.0'
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has a version specifier without operator' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', '12.0'
                ^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has a frozen version specifier' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', '= 12.0'
                ^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has a pessimistic version specifier' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', '~> 12.0'
                ^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has both minimum and non-minimum version specifier' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
                gem 'rubocop', '~> 12.0', '>= 11.0'
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has a version specifier along with other options' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
              gem 'rubocop', '~> 12.0', required: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end
      end

      context 'including one or more option names but not "version_specifiers"' do
        let(:checked_options) { %w[github required] }

        context 'when a gem is uncommented and has one of the specified options' do
          it 'registers an offense' do
            expect_offense(<<-RUBY, 'Gemfile')
              gem 'rubocop', github: 'some_user/some_fork'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            RUBY
          end
        end

        context 'when a gem is uncommented and has a version specifier but none of the specified options' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
              gem 'rubocop', '~> 12.0'
            RUBY
          end
        end

        context 'when a gem is uncommented and contains only options not specified' do
          it 'does not register an offense' do
            expect_no_offenses(<<-RUBY, 'Gemfile')
              gem 'rubocop', group: development
            RUBY
          end
        end
      end
    end
  end
end
