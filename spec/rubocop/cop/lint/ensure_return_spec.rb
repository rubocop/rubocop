# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EnsureReturn, :config do
  it 'registers an offense and corrects for return in ensure' do
    expect_offense(<<~RUBY)
      begin
        something
      ensure
        file.close
        return
        ^^^^^^ Do not return from an `ensure` block.
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense and corrects for return with argument in ensure' do
    expect_offense(<<~RUBY)
      begin
        foo
      ensure
        return baz
        ^^^^^^^^^^ Do not return from an `ensure` block.
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense when returning multiple values in `ensure`' do
    expect_offense(<<~RUBY)
      begin
        something
      ensure
        do_something
        return foo, bar
        ^^^^^^^^^^^^^^^ Do not return from an `ensure` block.
      end
    RUBY

    expect_no_corrections
  end

  it 'does not register an offense for return outside ensure' do
    expect_no_offenses(<<~RUBY)
      begin
        something
        return
      ensure
        file.close
      end
    RUBY
  end

  it 'does not check when ensure block has no body' do
    expect_no_offenses(<<~RUBY)
      begin
        something
      ensure
      end
    RUBY
  end
end
