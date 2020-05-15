# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::GemComment, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    {
      'Include' => ['**/Gemfile'],
      'IgnoredGems' => ['rake']
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

    context 'and the OnlyIfVersionRestricted option is set to true' do
      before { cop_config['OnlyIfVersionRestricted'] = true }

      context 'and a gem is commented' do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, 'Gemfile')
            # Style-guide enforcer.
            gem 'rubocop'
          RUBY
        end
      end

      context 'and a gem is uncommented but not version restricted' do
        it 'does not register an offense in a simple example' do
          expect_no_offenses(<<-GEM, 'Gemfile')
            gem 'rubocop'
          GEM
        end

        it 'does not register an offense in a more complex example' do
          expect_no_offenses(<<-GEM, 'Gemfile')
            gem 'rubocop', group: development
          GEM
        end
      end

      context 'and a gem is uncommented and version restricted' do
        context 'and has no other paramaters' do
          it 'registers an offense' do
            expect_offense(<<-GEM, 'Gemfile')
              gem 'rubocop', '~> 12.0'
              ^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            GEM
          end
        end

        context 'and has multiple version restrictions' do
          it 'registers an offense' do
            expect_offense(<<-GEM, 'Gemfile')
              gem 'rubocop', '~> 12.0', '>= 11.0'
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            GEM
          end
        end

        context 'and has extra unrelated keyword arguments' do
          it 'registers an offense' do
            expect_offense(<<-GEM, 'Gemfile')
            gem 'rubocop', '~> 12.0', required: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing gem description comment.
            GEM
          end
        end
      end
    end
  end
end
