# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ItAssignment, :config do
  it 'registers an offense when assigning a local `it` variable inside a block' do
    expect_offense(<<~RUBY)
      foo { it = 5 }
            ^^ `it` is the default block parameter; consider another name.
    RUBY
  end

  it 'registers an offense when assigning a local `it` variable inside a multiline block' do
    expect_offense(<<~RUBY)
      foo do
        it = 5
        ^^ `it` is the default block parameter; consider another name.
        bar(it)
      end
    RUBY
  end

  it 'registers an offense when assigning a local `it` variable inside a block with parameters' do
    expect_offense(<<~RUBY)
      foo { |x| it = x }
                ^^ `it` is the default block parameter; consider another name.
    RUBY
  end

  it 'registers an offense when assigning a local `it` variable inside a numblock' do
    expect_offense(<<~RUBY)
      foo { it = _2 }
            ^^ `it` is the default block parameter; consider another name.
    RUBY
  end

  it 'registers an offense inside a lambda' do
    expect_offense(<<~RUBY)
      -> { it = 5 }
           ^^ `it` is the default block parameter; consider another name.
    RUBY
  end

  it 'does not register an offense when assigning `self.it` inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { self.it = 5 }
    RUBY
  end

  it 'does not register an offense when assigning `@it` inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { @it = 5 }
    RUBY
  end

  it 'does not register an offense when assigning `$it` inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { $it = 5 }
    RUBY
  end

  it 'does not register an offense when assigning a local `it` variable outside a block' do
    expect_no_offenses(<<~RUBY)
      it = 5
    RUBY
  end
end
