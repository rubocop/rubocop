# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ItAssignment, :config do
  it 'registers an offense when assigning a local `it` variable' do
    expect_offense(<<~RUBY)
      it = 5
      ^^ `it` is the default block parameter; consider another name.
    RUBY
  end

  it 'registers an offense when naming a method parameter `it`' do
    expect_offense(<<~RUBY)
      def foo(it)
              ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

  it 'registers an offense when naming a kwarg `it`' do
    expect_offense(<<~RUBY)
      def foo(it:)
              ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

  it 'registers an offense when naming a method parameter `it` with a default value' do
    expect_offense(<<~RUBY)
      def foo(it = 5)
              ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

  it 'registers an offense when naming a kwarg `it` with a default value' do
    expect_offense(<<~RUBY)
      def foo(it: 5)
              ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

  it 'registers an offense when naming a method parameter `*it`' do
    expect_offense(<<~RUBY)
      def foo(*it)
               ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

  it 'registers an offense when naming a kwarg splat `**it`' do
    expect_offense(<<~RUBY)
      def foo(**it)
                ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

  it 'registers an offense when naming a block argument `&it`' do
    expect_offense(<<~RUBY)
      def foo(&it)
               ^^ `it` is the default block parameter; consider another name.
      end
    RUBY
  end

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

  it 'does not register an offense when assigning `self.it`' do
    expect_no_offenses(<<~RUBY)
      self.it = 5
    RUBY
  end

  it 'does not register an offense when assigning `self.it` inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { self.it = 5 }
    RUBY
  end

  it 'does not register an offense when assigning `@it`' do
    expect_no_offenses(<<~RUBY)
      @it = 5
    RUBY
  end

  it 'does not register an offense when assigning `@it` inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { @it = 5 }
    RUBY
  end

  it 'does not register an offense when assigning `$it`' do
    expect_no_offenses(<<~RUBY)
      $it = 5
    RUBY
  end

  it 'does not register an offense when assigning `$it` inside a block' do
    expect_no_offenses(<<~RUBY)
      foo { $it = 5 }
    RUBY
  end

  it 'does not register an offense when assigning a constant `IT`' do
    expect_no_offenses(<<~RUBY)
      IT = 5
    RUBY
  end

  it 'does not register an offense when naming a method `it`' do
    expect_no_offenses(<<~RUBY)
      def it
      end
    RUBY
  end

  context 'Ruby < 3.4', :ruby33 do
    it 'does not register an offense when calling `it` in a block' do
      expect_no_offenses(<<~RUBY)
        foo { puts it }
      RUBY
    end
  end

  context 'Ruby >= 3.4', :ruby34 do
    it 'does not register an offense when calling `it` in a block' do
      expect_no_offenses(<<~RUBY)
        foo { puts it }
      RUBY
    end
  end
end
