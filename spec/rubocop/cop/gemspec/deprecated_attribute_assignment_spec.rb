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

  it 'keeps another field following a deprecated assignment on the same line' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.test_files = []; s.name = 'example'
        ^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
      end
    RUBY

    expect_correction(<<~RUBY)
      Gem::Specification.new do |s|
        ; s.name = 'example'
      end
    RUBY
  end

  it 'keeps the preceding field and a trailing comment' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.name = 'example'; s.test_files += [] # keep
                            ^^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
      end
    RUBY

    expect_correction(<<~RUBY)
      Gem::Specification.new do |s|
        s.name = 'example'; # keep
      end
    RUBY
  end

  it 'keeps the delimiters of a one-line gem specification' do
    expect_offense(<<~RUBY)
      Gem::Specification.new { |s| s.test_files = [] }
                                   ^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
    RUBY

    expect_correction(<<~RUBY)
      Gem::Specification.new { |s| }
    RUBY
  end

  it 'leaves an assignment used as an argument but still corrects the next statement' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        log(s.test_files = [])
            ^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
        s.date = '2020-01-01'
        ^^^^^^^^^^^^^^^^^^^^^ Do not set `date` in gemspec.
      end
    RUBY

    expect_correction(<<~RUBY)
      Gem::Specification.new do |s|
        log(s.test_files = [])
      end
    RUBY
  end

  it 'does not leave a heredoc body behind' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.test_files = [<<~TEXT]; s.name = 'example'
        ^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
          test.rb
        TEXT
      end
    RUBY

    expect_no_corrections
  end

  it_behaves_like 'deprecated attributes', 'date', "Time.now.strftime('%Y-%m-%d')"
  it_behaves_like 'deprecated attributes', 'rubygems_version', '2.5'
  it_behaves_like 'deprecated attributes', 'specification_version', '2.5'
  it_behaves_like 'deprecated attributes', 'test_files', "Dir.glob('test/**/*')"
  it_behaves_like 'deprecated attributes with addition', 'test_files', "Dir.glob('test/**/*')"
end
