# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Bundler::GemVersion, :config do
  context 'when EnforcedStyle is set to required (default)' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'required',
        'AllowedGems' => ['rspec']
      }
    end

    it 'flags gems that do not specify a version' do
      expect_offense(<<~RUBY)
        gem 'rubocop'
        ^^^^^^^^^^^^^ Gem version specification is required.
        gem 'rubocop', require: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is required.
      RUBY
    end

    it 'does not flag gems with a specified version' do
      expect_no_offenses(<<~RUBY)
        gem 'rubocop', '>=1.10.0'
        gem 'rubocop', '~> 1'
        gem 'rubocop', '~> 1.12', require: false
        gem 'rubocop', '>= 1.5.0', '< 1.10.0', git: 'https://github.com/rubocop/rubocop'
        gem 'rubocop', branch: 'feature-branch'
        gem 'rubocop', ref: 'b3f37bc7f'
        gem 'rubocop', tag: 'v1'
      RUBY
    end

    it 'does not flag gems included in AllowedGems metadata' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec'
      RUBY
    end
  end

  context 'when EnforcedStyle is set to forbidden' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'forbidden',
        'AllowedGems' => ['rspec']
      }
    end

    it 'flags gems that specify a gem version' do
      expect_offense(<<~RUBY)
        gem 'rubocop', '~> 1'
        ^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
        gem 'rubocop', '>=1.10.0'
        ^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
        gem 'rubocop', '~> 1.12', require: false
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
        gem 'rubocop', '>= 1.5.0', '< 1.10.0', git: 'https://github.com/rubocop/rubocop'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
        gem 'rubocop', branch: 'feature-branch'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
        gem 'rubocop', ref: 'b3f37bc7f'
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
        gem 'rubocop', tag: 'v1'
        ^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification is forbidden.
      RUBY
    end

    it 'does not flag gems without a specified version' do
      expect_no_offenses(<<~RUBY)
        gem 'rubocop'
        gem 'rubocop', require: false
      RUBY
    end

    it 'does not flag gems included in AllowedGems metadata' do
      expect_no_offenses(<<~RUBY)
        gem 'rspec', '~> 3.10'
      RUBY
    end
  end
end
