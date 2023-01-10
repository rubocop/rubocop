# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::DuplicatedGem, :config do
  let(:cop_config) { { 'Include' => ['**/Gemfile'] } }

  context 'when investigating Ruby files' do
    it 'does not register any offenses' do
      expect_no_offenses(<<~RUBY, '/foo.rb')
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
        expect_no_offenses(<<~RUBY, 'Gemfile')
          gem 'rubocop'
          gem 'flog'
        RUBY
      end
    end

    context 'and a gem is duplicated in default group' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'Gemfile')
          source 'https://rubygems.org'
          gem 'rubocop'
          gem 'rubocop'
          ^^^^^^^^^^^^^ Gem `rubocop` requirements already given on line 2 of the Gemfile.
        RUBY
      end
    end

    context 'and a duplicated gem is in a git/path/group/platforms block' do
      it 'registers an offense' do
        expect_offense(<<-RUBY, 'Gemfile')
          gem 'rubocop'
          group :development do
            gem 'rubocop', path: '/path/to/gem'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem `rubocop` requirements already given on line 1 of the Gemfile.
          end
        RUBY
      end
    end

    it 'registers an offense when gem from default group is conditionally duplicated' do
      expect_offense(<<-RUBY, 'Gemfile')
        gem 'rubocop'
        if Dir.exist? local
          gem 'rubocop', path: local
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem `rubocop` requirements already given on line 1 of the Gemfile.
        else
          gem 'rubocop', '~> 0.90.0'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem `rubocop` requirements already given on line 1 of the Gemfile.
        end
      RUBY
    end

    it 'does not register an offense when gem is duplicated within `if-else` statement' do
      expect_no_offenses(<<-RUBY, 'Gemfile')
        if Dir.exist?(local)
          gem 'rubocop', path: local
          gem 'flog', path: local
        else
          gem 'rubocop', '~> 0.90.0'
        end
      RUBY
    end

    it 'does not register an offense when gem is duplicated within `if-elsif` statement' do
      expect_no_offenses(<<-RUBY, 'Gemfile')
        if Dir.exist?(local)
          gem 'rubocop', path: local
        elsif ENV['RUBOCOP_VERSION'] == 'master'
          gem 'rubocop', git: 'https://github.com/rubocop/rubocop.git'
        elsif (version = ENV['RUBOCOP_VERSION'])
          gem 'rubocop', version
        else
          gem 'rubocop', '~> 0.90.0'
        end
      RUBY
    end

    it 'does not register an offense when gem is duplicated within `case` statement' do
      expect_no_offenses(<<-RUBY, 'Gemfile')
        case
        when Dir.exist?(local)
          gem 'rubocop', path: local
        when ENV['RUBOCOP_VERSION'] == 'master'
          gem 'rubocop', git: 'https://github.com/rubocop/rubocop.git'
        else
          gem 'rubocop', '~> 0.90.0'
        end
      RUBY
    end
  end
end
