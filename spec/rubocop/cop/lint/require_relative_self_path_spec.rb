# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RequireRelativeSelfPath, :config do
  it 'registers an offense when using `require_relative` with self file path argument' do
    expect_offense(<<~RUBY, 'foo.rb')
      require_relative 'foo'
      ^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      require_relative 'bar'
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'bar'
    RUBY
  end

  it 'registers an offense when using `require_relative` with self file path argument (with ext)' do
    expect_offense(<<~RUBY, 'foo.rb')
      require_relative 'foo.rb'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Remove the `require_relative` that requires itself.
      require_relative 'bar'
    RUBY

    expect_correction(<<~RUBY)
      require_relative 'bar'
    RUBY
  end

  it 'does not register an offense when using `require_relative` without self file path argument' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      require_relative 'bar'
    RUBY
  end

  it 'does not register an offense when using `require_relative` without argument' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      require_relative
    RUBY
  end

  it 'does not register an offense when the filename is the same but the extension does not match' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      require_relative 'foo.racc'
    RUBY
  end

  it 'does not register an offense when using a variable as an argument of `require_relative`' do
    expect_no_offenses(<<~RUBY, 'foo.rb')
      Dir['test/**/test_*.rb'].each { |f| require_relative f }
    RUBY
  end
end
