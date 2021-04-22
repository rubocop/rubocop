# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::GemVersionDeclaration, :config do
  context 'when EnforcedStyle is set to required (default)' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'required',
        'IgnoredGems' => ['rspec']
      }
    end

    it 'flags gems without a version declaration' do
      expect_offense(<<~RUBY)
        gem 'rubocop'
        ^^^^^^^^^^^^^ Gem version declaration is required.
        gem 'rubocop', require: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version declaration is required.
      RUBY
    end

    it 'ignores gems with a declared version' do
      expect_no_offenses(<<~RUBY)
        gem 'rubocop', '>=1.10.0'
        gem 'rubocop', '~> 1'
        gem 'rubocop', '~> 1.12', require: false
        gem 'rubocop', '>= 1.5.0', '< 1.10.0', git: 'https://github.com/rubocop/rubocop'
      RUBY
    end

    it 'ignores gems included in IgnoredGems metadata' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec'
      RUBY
    end
  end

  context 'when EnforcedStyle is set to prohibited' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'prohibited',
        'IgnoredGems' => ['rspec']
      }
    end

    it 'flags gems with a version declaration' do
      expect_offense(<<~RUBY)
        gem 'rubocop', '~> 1'
        ^^^^^^^^^^^^^^^^^^^^^ Gem version declaration is prohibited.
        gem 'rubocop', '>=1.10.0'
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version declaration is prohibited.
        gem 'rubocop', '~> 1.12', require: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version declaration is prohibited.
        gem 'rubocop', '>= 1.5.0', '< 1.10.0', git: 'https://github.com/rubocop/rubocop'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version declaration is prohibited.
      RUBY
    end

    it 'ignores gems without a declared version' do
      expect_no_offenses(<<~RUBY)
        gem 'rubocop'
        gem 'rubocop', require: false
      RUBY
    end

    it 'ignores gems included in IgnoredGems metadata' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec', '~> 3.10'
      RUBY
    end
  end
end
