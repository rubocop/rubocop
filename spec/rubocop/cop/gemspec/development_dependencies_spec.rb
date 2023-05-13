# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::DevelopmentDependencies, :config do
  let(:cop_config) do
    {
      'Enabled' => true,
      'EnforcedStyle' => enforced_style,
      'AllowedGems' => [
        'allowed'
      ]
    }
  end

  shared_examples 'prefer gem file' do
    it 'registers an offense when using `#add_development_dependency` in a gemspec' do
      expect_offense(<<~RUBY, 'example.gemspec', preferred_file: enforced_style)
        Gem::Specification.new do |spec|
          spec.name = 'example'
          spec.add_development_dependency 'foo'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify development dependencies in %{preferred_file}.
          spec.add_development_dependency 'allowed'
        end
      RUBY
    end

    it 'registers an offense when using `#add_development_dependency` in a gemspec a single version argument' do
      expect_offense(<<~RUBY, 'example.gemspec', preferred_file: enforced_style)
        Gem::Specification.new do |spec|
          spec.name = 'example'
          spec.add_development_dependency 'foo', '>= 1.0'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify development dependencies in %{preferred_file}.
          spec.add_development_dependency 'allowed', '>= 1.0'
        end
      RUBY
    end

    it 'registers an offense when using `#add_development_dependency` in a gemspec with two version' do
      expect_offense(<<~RUBY, 'example.gemspec', preferred_file: enforced_style)
        Gem::Specification.new do |spec|
          spec.name = 'example'
          spec.add_development_dependency 'foo', '>= 1.0', '< 2.0'
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Specify development dependencies in %{preferred_file}.
          spec.add_development_dependency 'allowed', '>= 1.0', '< 2.0'
        end
      RUBY
    end

    it 'registers no offenses when specifying dependencies in Gemfile' do
      expect_no_offenses(<<~RUBY, 'Gemfile')
        gem 'example'
      RUBY
    end

    it 'registers no offenses when specifying dependencies in gems.rb' do
      expect_no_offenses(<<~RUBY, 'gems.rb')
        gem 'example'
      RUBY
    end
  end

  context 'with `EnforcedStyle: Gemfile`' do
    let(:enforced_style) { 'Gemfile' }

    include_examples 'prefer gem file'
  end

  context 'with `EnforcedStyle: gems.rb`' do
    let(:enforced_style) { 'gems.rb' }

    include_examples 'prefer gem file'
  end

  context 'with `EnforcedStyle: gemspec`' do
    let(:enforced_style) { 'gemspec' }

    it 'registers no offenses when using `#add_development_dependency`' do
      expect_no_offenses(<<~RUBY, 'example.gemspec')
        Gem::Specification.new do |spec|
          spec.name = 'example'
          spec.add_development_dependency 'foo'
        end
      RUBY
    end

    it 'registers an offense when specifying dependencies in Gemfile' do
      expect_offense(<<~RUBY, 'Gemfile')
        gem 'example'
        ^^^^^^^^^^^^^ Specify development dependencies in gemspec.
        gem 'allowed'
      RUBY
    end

    it 'registers an offense when specifying dependencies in gems.rb' do
      expect_offense(<<~RUBY, 'gems.rb')
        gem 'example'
        ^^^^^^^^^^^^^ Specify development dependencies in gemspec.
        gem 'allowed'
      RUBY
    end
  end
end
