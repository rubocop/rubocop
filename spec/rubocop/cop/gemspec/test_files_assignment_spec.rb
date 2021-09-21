# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::TestFilesAssignment, :config do
  it 'registers and corrects an offense when using `s.test_files =`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.name = 'your_cool_gem_name'
        s.test_files = Dir.glob('test/**/*')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
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

  it 'registers and corrects an offense when using `s.test_files +=`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.name = 'your_cool_gem_name'
        s.test_files += Dir.glob('test/**/*')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
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

  it 'registers and corrects an offense when using `spec.test_files =`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.name = 'your_cool_gem_name'
        spec.test_files = Dir.glob('test/**/*')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
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

  it 'registers and corrects an offense when using `spec.test_files +=`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.name = 'your_cool_gem_name'
        spec.test_files += Dir.glob('test/**/*')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not set `test_files` in gemspec.
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

  it 'does not register an offense when using `s.test_files =` outside `Gem::Specification.new`' do
    expect_no_offenses(<<~RUBY)
      s.test_files = Dir.glob('test/**/*')
    RUBY
  end

  it 'does not register an offense when using `test_files =` and receiver is not `Gem::Specification.new` block variable' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        s.test_files = Dir.glob('test/**/*')
      end
    RUBY
  end
end
