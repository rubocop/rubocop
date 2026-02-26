# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Gemspec::DateAssignment, :config do
  it 'registers and corrects an offense when using `s.date =`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |s|
        s.name = 'your_cool_gem_name'
        s.date = Time.now.strftime('%Y-%m-%d')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `date =` in gemspec, it is set automatically when the gem is packaged.
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

  it 'registers and corrects an offense when using `spec.date =`' do
    expect_offense(<<~RUBY)
      Gem::Specification.new do |spec|
        spec.name = 'your_cool_gem_name'
        spec.date = Time.now.strftime('%Y-%m-%d')
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `date =` in gemspec, it is set automatically when the gem is packaged.
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

  it 'does not register an offense when using `s.date =` outside `Gem::Specification.new`' do
    expect_no_offenses(<<~RUBY)
      s.date = Time.now.strftime('%Y-%m-%d')
    RUBY
  end

  it 'does not register an offense when using `date =` and receiver is not `Gem::Specification.new` block variable' do
    expect_no_offenses(<<~RUBY)
      Gem::Specification.new do |spec|
        s.date = Time.now.strftime('%Y-%m-%d')
      end
    RUBY
  end
end
