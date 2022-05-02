# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EnvHome, :config do
  it "registers and corrects an offense when using `ENV['HOME']`" do
    expect_offense(<<~RUBY)
      ENV['HOME']
      ^^^^^^^^^^^ Use `Dir.home` instead.
    RUBY

    expect_correction(<<~RUBY)
      Dir.home
    RUBY
  end

  it "registers and corrects an offense when using `ENV.fetch('HOME')`" do
    expect_offense(<<~RUBY)
      ENV.fetch('HOME')
      ^^^^^^^^^^^^^^^^^ Use `Dir.home` instead.
    RUBY

    expect_correction(<<~RUBY)
      Dir.home
    RUBY
  end

  it "registers and corrects an offense when using `ENV.fetch('HOME', nil)`" do
    expect_offense(<<~RUBY)
      ENV.fetch('HOME', nil)
      ^^^^^^^^^^^^^^^^^^^^^^ Use `Dir.home` instead.
    RUBY

    expect_correction(<<~RUBY)
      Dir.home
    RUBY
  end

  it "registers and corrects an offense when using `::ENV['HOME']`" do
    expect_offense(<<~RUBY)
      ::ENV['HOME']
      ^^^^^^^^^^^^^ Use `Dir.home` instead.
    RUBY

    expect_correction(<<~RUBY)
      Dir.home
    RUBY
  end

  it 'does not register an offense when using `Dir.home`' do
    expect_no_offenses(<<~RUBY)
      Dir.home
    RUBY
  end

  it "does not register an offense when using `ENV['HOME'] = '/home/foo'`" do
    expect_no_offenses(<<~RUBY)
      ENV['HOME'] = '/home/foo'
    RUBY
  end

  it "does not register an offense when using `ENV.fetch('HOME', default)`" do
    expect_no_offenses(<<~RUBY)
      ENV.fetch('HOME', default)
    RUBY
  end
end
