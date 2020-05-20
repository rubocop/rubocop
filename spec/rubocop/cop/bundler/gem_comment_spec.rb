# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::GemComment, :config do
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
  end
end
