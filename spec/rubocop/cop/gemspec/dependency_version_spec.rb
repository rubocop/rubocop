# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::DependencyVersion, :config do
  let(:cop_config) do
    {
      'Enabled' => true,
      'EnforcedStyle' => enforced_style,
      'AllowedGems' => allowed_gems
    }
  end
  let(:allowed_gems) { [] }
  let(:config) do
    base = RuboCop::ConfigLoader
           .default_configuration['Gemspec/DependencyVersion']
           .merge(cop_config)
    RuboCop::Config.new('Gemspec/DependencyVersion' => base)
  end

  context 'with `EnforcedStyle: required`' do
    let(:enforced_style) { 'required' }

    context 'using add_dependency' do
      it 'registers an offense when adding dependency without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'parser'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('parser')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding dependency without version specification and method called on gem name argument' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('parser'.freeze)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding dependency using git option without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding dependency using git option by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'does not register an offense when adding dependency with version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'parser', '~> 3.1', '>= 3.1.1.0'
          end
        RUBY
      end

      it 'does not register an offense when adding dependency by parenthesized call with version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('parser', '>= 3.1.1.0')
          end
        RUBY
      end

      it 'does not register an offense when adding dependency with commit ref specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228'
          end
        RUBY
      end

      it 'does not register an offense when adding dependency by parenthesized call with commit ref specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228')
          end
        RUBY
      end

      it 'does not register an offense when adding dependency with tag specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0'
          end
        RUBY
      end

      it 'does not register an offense when adding dependency by parenthesized call with tag specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0')
          end
        RUBY
      end

      it 'does not register an offense when adding dependency with branch specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main'
          end
        RUBY
      end

      it 'does not register an offense when adding dependency by parenthesized call with branch specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main')
          end
        RUBY
      end
    end

    context 'using add_development_dependency' do
      it 'registers an offense when adding development dependency without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'parser'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('parser')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency using git option without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency using git option by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency with version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'parser', '~> 3.1', '>= 3.1.1.0'
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency by parenthesized call with version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('parser', '>= 3.1.1.0')
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency with commit ref specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228'
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency by parenthesized call with commit ref specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228')
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency with tag specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0'
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency by parenthesized call with tag specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0')
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency with branch specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main'
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency by parenthesized call with branch specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main')
          end
        RUBY
      end
    end

    context 'using add_runtime_dependency' do
      it 'registers an offense when adding runtime dependency without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'parser'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('parser')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency using git option without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency using git option by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency with version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'parser', '~> 3.1', '>= 3.1.1.0'
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency by parenthesized call with version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('parser', '>= 3.1.1.0')
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency with commit ref specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228'
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency by parenthesized call with commit ref specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228')
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency with tag specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0'
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency by parenthesized call with tag specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0')
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency with branch specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main'
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency by parenthesized call with branch specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main')
          end
        RUBY
      end
    end

    context 'with `AllowedGems`' do
      let(:allowed_gems) { ['rubocop'] }

      it 'registers an offense when adding dependency without version specification excepts allowed gems' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop'
            spec.add_development_dependency 'rubocop-ast', '~> 0.1'

            spec.add_dependency 'parser'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call without version specification excepts allowed gems' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop')
            spec.add_development_dependency('rubocop-ast', '~> 0.1')

            spec.add_dependency('parser')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is required.
          end
        RUBY
      end
    end
  end

  context 'with `EnforcedStyle: forbidden`' do
    let(:enforced_style) { 'forbidden' }

    context 'using add_dependency' do
      it 'does not register an offense when adding dependency without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'parser'
          end
        RUBY
      end

      it 'does not register an offense when adding dependency by parenthesized call without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('parser')
          end
        RUBY
      end

      it 'does not register an offense when adding dependency using git option without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop'
          end
        RUBY
      end

      it 'does not register an offense when adding dependency using git option by parenthesized call without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop')
          end
        RUBY
      end

      it 'registers an offense when adding dependency with version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'parser', '~> 3.1', '>= 3.1.1.0'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call with version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('parser', '>= 3.1.1.0')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency with commit ref specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call with commit ref specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency with tag specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call with tag specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency with branch specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call with branch specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end
    end

    context 'using add_development_dependency' do
      it 'does not register an offense when adding development dependency without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'parser'
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency by parenthesized call without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('parser')
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency using git option without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop'
          end
        RUBY
      end

      it 'does not register an offense when adding development dependency using git option by parenthesized call without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop')
          end
        RUBY
      end

      it 'registers an offense when adding development dependency with version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'parser', '~> 3.1', '>= 3.1.1.0'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency by parenthesized call with version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('parser', '>= 3.1.1.0')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency with commit ref specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency by parenthesized call with commit ref specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency with tag specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency by parenthesized call with tag specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency with branch specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding development dependency by parenthesized call with branch specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_development_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end
    end

    context 'using add_runtime_dependency' do
      it 'does not register an offense when adding runtime dependency without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'parser'
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency by parenthesized call without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('parser')
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency using git option without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop'
          end
        RUBY
      end

      it 'does not register an offense when adding runtime dependency using git option by parenthesized call without version specification' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop')
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency with version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'parser', '~> 3.1', '>= 3.1.1.0'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency by parenthesized call with version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('parser', '>= 3.1.1.0')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency with commit ref specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency by parenthesized call with commit ref specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', ref: '54f4c8228')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency with tag specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency by parenthesized call with tag specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', tag: 'v1.28.0')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency with branch specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency 'rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding runtime dependency by parenthesized call with branch specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_runtime_dependency('rubocop', git: 'https://github.com/rubocop/rubocop', branch: 'main')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end
    end

    context 'with `AllowedGems`' do
      let(:allowed_gems) { ['rubocop'] }

      it 'registers an offense when adding dependency without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency 'parser'
            spec.add_dependency 'rubocop', '~> 1.28'
            spec.add_development_dependency 'rubocop-ast', '~> 0.1'
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end

      it 'registers an offense when adding dependency by parenthesized call without version specification' do
        expect_offense(<<~RUBY)
          Gem::Specification.new do |spec|
            spec.add_dependency('rubocop')
            spec.add_dependency('parser')
            spec.add_development_dependency('rubocop-ast', '~> 0.1')
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Dependency version specification is forbidden.
          end
        RUBY
      end
    end
  end
end
