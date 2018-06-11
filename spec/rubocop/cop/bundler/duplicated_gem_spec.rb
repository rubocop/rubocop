# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::DuplicatedGem, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'Include' => ['**/Gemfile'] } }

  context 'when investigating Ruby files' do
    it 'does not register any offenses' do
      expect_no_offenses(<<-RUBY.strip_indent)
        # cop will not read these contents
        gem('rubocop')
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

    context 'and no duplicate gems are present' do
      it 'does not register any offenses' do
        expect_no_offenses(<<-RUBY.strip_indent, 'Gemfile')
          gem 'rubocop'
          gem 'flog'
        RUBY
      end
    end

    context 'and a gem is duplicated in default group' do
      it 'registers an offense' do
        expect_offense(<<-GEM, 'Gemfile')
          source 'https://rubygems.org'
          gem 'rubocop'
          gem 'rubocop'
          ^^^^^^^^^^^^^ Gem `rubocop` requirements already given on line 2 of the Gemfile.
        GEM
      end
    end

    context 'and a duplicated gem is in a git/path/group/platforms block' do
      it 'registers an offense' do
        expect_offense(<<-GEM, 'Gemfile')
          gem 'rubocop'
          group :development do
            gem 'rubocop', path: '/path/to/gem'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem `rubocop` requirements already given on line 1 of the Gemfile.
          end
        GEM
      end
    end
  end
end
