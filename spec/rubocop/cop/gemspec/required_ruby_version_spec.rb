# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::RequiredRubyVersion, :config do
  # rubocop:disable RSpec/RepeatedExampleGroupDescription
  context 'target ruby version > 3.4', :ruby34 do
    # rubocop:enable RSpec/RepeatedExampleGroupDescription
    it 'registers an offense when `required_ruby_version` is specified with >= and is lower than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, '/path/to/foo.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 3.3.0'
                                       ^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is specified with ~> and is lower than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, '/path/to/foo.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '~> 3.3.0'
                                       ^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is specified in array and is lower than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, '/path/to/foo.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = ['>= 3.3.0', '< 4.0.0']
                                       ^^^^^^^^^^^^^^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'recognizes Gem::Requirement and registers offense' do
      expect_offense(<<~RUBY, '/path/to/foo.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = Gem::Requirement.new(">= 3.3.0")
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is specified with `Gem::Requirement.new` and is higher than `TargetRubyVersion`' do
      expect_offense(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = Gem::Requirement.new('< 3.4')
                                       ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'recognizes a Gem::Requirement with multiple requirements and does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = Gem::Requirement.new(">= 3.4.0", "<= 3.8")
        end
      RUBY
    end

    describe 'false negatives' do
      it 'does not register an offense when `required_ruby_version` ' \
         'is assigned as a variable (string literal)' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            version = '>= 3.3.0'
            spec.required_ruby_version = version
          end
        RUBY
      end

      it 'does not register an offense when `required_ruby_version` ' \
         'is assigned as a variable (an array of string literal)' do
        expect_no_offenses(<<~RUBY)
          Gem::Specification.new do |spec|
            lowest_version = '>= 3.3.0'
            highest_version = '< 3.8.0'
            spec.required_ruby_version = [lowest_version, highest_version]
          end
        RUBY
      end
    end
  end

  context 'target ruby version > 3.3', :ruby33 do
    it 'registers an offense when `required_ruby_version` is specified with >= and is higher than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, '/path/to/bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 3.4.0'
                                       ^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.3, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is specified with ~> and is higher than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, '/path/to/bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '~> 3.4.0'
                                       ^^^^^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.3, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end
  end

  # rubocop:disable RSpec/RepeatedExampleGroupDescription
  context 'target ruby version > 3.4', :ruby34 do
    # rubocop:enable RSpec/RepeatedExampleGroupDescription
    it 'does not register an offense when `required_ruby_version` is specified with >= and equals `TargetRubyVersion`' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 3.4.0'
        end
      RUBY
    end

    it 'does not register an offense when `required_ruby_version` is specified with ~> and equals `TargetRubyVersion`' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '~> 3.4.0'
        end
      RUBY
    end

    it 'does not register an offense when `required_ruby_version` is specified with >= without a patch version and ' \
       'equals `TargetRubyVersion`' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 3.4'
        end
      RUBY
    end

    it 'does not register an offense when `required_ruby_version` is specified with ~> without a patch version and ' \
       'equals `TargetRubyVersion`' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '~> 3.4'
        end
      RUBY
    end

    it 'does not register an offense when lowest version of ' \
       '`required_ruby_version` equals `TargetRubyVersion`' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.required_ruby_version = ['>= 3.4.0', '< 4.1.0']
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is specified with >= without a minor version and is lower ' \
       'than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, 'bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '>= 3'
                                       ^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is specified with ~> without a minor version and is lower ' \
       'than `TargetRubyVersion`' do
      expect_offense(<<~RUBY, 'bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = '~> 3'
                                       ^^^^^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is not specified' do
      expect_offense(<<~RUBY, '/path/to/foo.gemspec')
        Gem::Specification.new do |spec|
        ^{} `required_ruby_version` should be specified.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is blank' do
      expect_offense(<<~RUBY, 'bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = ''
                                       ^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end

    it 'registers an offense when `required_ruby_version` is an empty array' do
      expect_offense(<<~RUBY, 'bar.gemspec')
        Gem::Specification.new do |spec|
          spec.required_ruby_version = []
                                       ^^ `required_ruby_version` and `TargetRubyVersion` (3.4, which may be specified in .rubocop.yml) should be equal.
        end
      RUBY
    end
  end

  it 'registers an offense when the file is empty' do
    expect_offense(<<~RUBY, 'bar.gemspec')
      ^{} `required_ruby_version` should be specified.
    RUBY
  end
end
