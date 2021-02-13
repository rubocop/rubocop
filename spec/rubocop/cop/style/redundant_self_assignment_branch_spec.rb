# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSelfAssignmentBranch, :config do
  it 'registers and corrects an offense when self-assigning redundant else ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? bar : foo
                              ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = bar if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant if ternary branch' do
    expect_offense(<<~RUBY)
      foo = condition ? foo : bar
                        ^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      foo = bar unless condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              bar
            else
              foo
              ^^^ Remove the self-assignment branch.
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = if condition
              bar
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant if branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              foo
              ^^^ Remove the self-assignment branch.
            else
              bar
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = unless condition
              bar
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch and multiline if branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              bar
              baz
            else
              foo
              ^^^ Remove the self-assignment branch.
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = if condition
              bar
              baz
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch and multiline else branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              foo
              ^^^ Remove the self-assignment branch.
            else
              bar
              baz
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = unless condition
              bar
              baz
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch and empty if branch' do
    expect_offense(<<~RUBY)
      foo = if condition
            else
              foo
              ^^^ Remove the self-assignment branch.
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = if condition
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else branch and empty else branch' do
    expect_offense(<<~RUBY)
      foo = if condition
              foo
              ^^^ Remove the self-assignment branch.
            else
            end
    RUBY

    expect_correction(<<~RUBY)
      foo = unless condition
            end
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else ternary branch for ivar' do
    expect_offense(<<~RUBY)
      @foo = condition ? @bar : @foo
                                ^^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      @foo = @bar if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else ternary branch for cvar' do
    expect_offense(<<~RUBY)
      @@foo = condition ? @@bar : @@foo
                                  ^^^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      @@foo = @@bar if condition
    RUBY
  end

  it 'registers and corrects an offense when self-assigning redundant else ternary branch for gvar' do
    expect_offense(<<~RUBY)
      $foo = condition ? $bar : $foo
                                ^^^^ Remove the self-assignment branch.
    RUBY

    expect_correction(<<~RUBY)
      $foo = $bar if condition
    RUBY
  end

  it 'does not register an offense when not self-assigning redundant branches' do
    expect_no_offenses(<<~RUBY)
      foo = condition ? bar : baz
    RUBY
  end

  it 'does not register an offense when using only if branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
            end
    RUBY
  end

  it 'does not register an offense when multi assignment' do
    expect_no_offenses(<<~RUBY)
      foo, bar = baz
    RUBY
  end

  # Ignore method calls as they can have side effects. In other words, it may be unsafe detection.
  it 'does not register an offense when lhs is not variable' do
    expect_no_offenses(<<~RUBY)
      foo.do_something = condition ? foo.do_something : bar.do_something
    RUBY
  end

  it 'registers and corrects an offense when using `elsif` and self-assigning the value of `then` branch' do
    expect_offense(<<~RUBY)
      foo = if condition
        foo
        ^^^ Remove the self-assignment branch.
      elsif another_condtion
        bar
      else
        baz
      end
    RUBY

    expect_correction(<<~RUBY)
      foo = if another_condtion
        bar
      else
        baz
      end
    RUBY
  end

  # It may be possible to extend it to register an offense in future.
  # auto-correction test patterns should be considered and implemented.
  it 'registers and corrects an offense when using `elsif` and self-assigning the value of `elsif` branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
            elsif another_condtion
              foo
            else
              baz
            end
    RUBY
  end

  # It may be possible to extend it to register an offense in future.
  # auto-correction test patterns should be considered and implemented.
  it 'registers and corrects an offense when using `elsif` and self-assigning the value of `else` branch' do
    expect_no_offenses(<<~RUBY)
      foo = if condition
              bar
            elsif another_condtion
              baz
            else
              foo
            end
    RUBY
  end
end
