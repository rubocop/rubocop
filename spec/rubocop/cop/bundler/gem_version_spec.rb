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

  context 'when EnforcedStyle is set to exact' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'exact',
        'AllowedGems' => ['rspec']
      }
    end

    context 'without a lockfile' do
      it 'flags gems without a single exact version' do
        expect_offense(<<~RUBY)
          gem 'rubocop'
          ^^^^^^^^^^^^^ Gem version specification must be a single exact version.
          gem 'rubocop', '~> 1.12', require: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be a single exact version.
          gem 'rubocop', '>= 1.5.0', '< 1.10.0'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be a single exact version.
          gem 'rubocop', '1.17.0', '!= 1.16.0'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be a single exact version.
          gem 'rubocop', branch: 'feature-branch'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be a single exact version.
        RUBY

        expect_no_corrections
      end

      it 'does not flag gems with an exact version or an exact commit reference' do
        expect_no_offenses(<<~RUBY)
          gem 'rubocop', '1.17.0'
          gem 'rubocop', '= 1.17.0', require: false
          gem 'rubocop', '1.17.0.rc1'
          gem 'rubocop', ref: 'b3f37bc7f'
          gem 'rubocop', tag: 'v1'
        RUBY
      end

      it 'does not flag gems included in AllowedGems metadata' do
        expect_no_offenses(<<~RUBY)
          gem 'rspec', '~> 3.10'
        RUBY
      end
    end

    context 'with a lockfile' do
      let(:gem_versions) { { 'rubocop' => '1.17.0', 'puma' => '6.4.2' } }

      it 'flags and corrects a gem without a version' do
        expect_offense(<<~RUBY)
          gem 'rubocop', require: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be the locked version `1.17.0`.
          gem "puma"
          ^^^^^^^^^^ Gem version specification must be the locked version `6.4.2`.
        RUBY

        expect_correction(<<~RUBY)
          gem 'rubocop', '1.17.0', require: false
          gem "puma", "6.4.2"
        RUBY
      end

      it 'flags and corrects a gem with a version range' do
        expect_offense(<<~RUBY)
          gem 'rubocop', '~> 1.12'
          ^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be the locked version `1.17.0`.
          gem 'puma', '>= 6.0', '< 7', require: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be the locked version `6.4.2`.
        RUBY

        expect_correction(<<~RUBY)
          gem 'rubocop', '1.17.0'
          gem 'puma', '6.4.2', require: false
        RUBY
      end

      it 'flags and corrects an exact version that does not match the lockfile' do
        expect_offense(<<~RUBY)
          gem 'rubocop', '1.16.0'
          ^^^^^^^^^^^^^^^^^^^^^^^ Gem version `1.16.0` does not match the locked version `1.17.0`.
        RUBY

        expect_correction(<<~RUBY)
          gem 'rubocop', '1.17.0'
        RUBY
      end

      it 'does not flag an exact version that matches the lockfile' do
        expect_no_offenses(<<~RUBY)
          gem 'rubocop', '1.17.0'
          gem 'puma', '= 6.4.2'
        RUBY
      end

      it 'does not correct a gem with a branch' do
        expect_offense(<<~RUBY)
          gem 'rubocop', branch: 'feature-branch'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be the locked version `1.17.0`.
        RUBY

        expect_no_corrections
      end

      it 'flags a gem that is not in the lockfile without correcting it' do
        expect_offense(<<~RUBY)
          gem 'rails', '~> 7.1'
          ^^^^^^^^^^^^^^^^^^^^^ Gem version specification must be a single exact version.
        RUBY

        expect_no_corrections
      end

      it 'ignores the lockfile in *.gemfile files' do
        expect_offense(<<~RUBY, 'gemfiles/rails_7.gemfile')
          gem 'rubocop', '1.16.0'
          gem 'puma', '~> 6.0'
          ^^^^^^^^^^^^^^^^^^^^ Gem version specification must be a single exact version.
        RUBY

        expect_no_corrections
      end

      it 'compares Gemfile and gems.rb to the lockfile' do
        expect_offense(<<~RUBY, 'gems.rb')
          gem 'rubocop', '1.16.0'
          ^^^^^^^^^^^^^^^^^^^^^^^ Gem version `1.16.0` does not match the locked version `1.17.0`.
        RUBY

        expect_correction(<<~RUBY)
          gem 'rubocop', '1.17.0'
        RUBY
      end
    end
  end
end
