# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::DeprecatedAttributeAssignment, :config do
  shared_examples 'deprecated attributes' do |attribute, value|
    it 'registers and corrects an offense when using `s.rubygems_version =`' do
      expect_offense(<<~RUBY)
        Gem::Specification.new do |s|
          s.name = 'your_cool_gem_name'
          s.#{attribute} = #{value}
          ^^^^^#{'^' * (attribute.size + value.size)} Do not set `#{attribute}` in gemspec.
          s.bindir = 'exe'
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |s|
          s.name = 'your_cool_gem_name'
          s.bindir = 'exe'
        end
      RUBY
    end

    it 'registers and corrects an offense when using `spec.rubygems_version =`' do
      expect_offense(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.name = 'your_cool_gem_name'
          spec.#{attribute} = #{value}
          ^^^^^^^^#{'^' * (attribute.size + value.size)} Do not set `#{attribute}` in gemspec.
          spec.bindir = 'exe'
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.name = 'your_cool_gem_name'
          spec.bindir = 'exe'
        end
      RUBY
    end

    it 'does not register an offense when using `s.rubygems_version =` outside `Gem::Specification.new`' do
      expect_no_offenses(<<~RUBY)
        s.#{attribute} = #{value}
      RUBY
    end

    it 'does not register an offense when using `rubygems_version =` and receiver is not `Gem::Specification.new` block variable' do
      expect_no_offenses(<<~RUBY)
        Gem::Specification.new do |spec|
          s.#{attribute} = #{value}
        end
      RUBY
    end
  end

  shared_examples 'deprecated attributes with addition' do |attribute, value|
    it 'registers and corrects an offense when using `s.rubygems_version +=`' do
      expect_offense(<<~RUBY)
        Gem::Specification.new do |s|
          s.name = 'your_cool_gem_name'
          s.#{attribute} += #{value}
          ^^^^^^#{'^' * (attribute.size + value.size)} Do not set `#{attribute}` in gemspec.
          s.bindir = 'exe'
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |s|
          s.name = 'your_cool_gem_name'
          s.bindir = 'exe'
        end
      RUBY
    end

    it 'registers and corrects an offense when using `spec.rubygems_version +=`' do
      expect_offense(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.name = 'your_cool_gem_name'
          spec.#{attribute} += #{value}
          ^^^^^^^^^#{'^' * (attribute.size + value.size)} Do not set `#{attribute}` in gemspec.
          spec.bindir = 'exe'
        end
      RUBY

      expect_correction(<<~RUBY)
        Gem::Specification.new do |spec|
          spec.name = 'your_cool_gem_name'
          spec.bindir = 'exe'
        end
      RUBY
    end
  end

  it_behaves_like 'deprecated attributes', 'date', "Time.now.strftime('%Y-%m-%d')"
  it_behaves_like 'deprecated attributes', 'rubygems_version', '2.5'
  it_behaves_like 'deprecated attributes', 'specification_version', '2.5'
  it_behaves_like 'deprecated attributes', 'test_files', "Dir.glob('test/**/*')"
  it_behaves_like 'deprecated attributes with addition', 'test_files', "Dir.glob('test/**/*')"
end
