# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantRequireStatement, :config do
  it 'registers an offense when using requiring `enumerator`' do
    expect_offense(<<~RUBY)
      require 'enumerator'
      ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
      require 'uri'
    RUBY

    expect_correction(<<~RUBY)
      require 'uri'
    RUBY
  end

  it 'registers an offense when using requiring `enumerator` with modifier form' do
    expect_offense(<<~RUBY)
      require 'enumerator' if condition
      ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
      require 'uri'
    RUBY

    expect_correction(<<~RUBY)
      if condition
      end
      require 'uri'
    RUBY
  end

  it 'registers an offense when using requiring `enumerator` in condition' do
    expect_offense(<<~RUBY)
      if condition
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
      end
      require 'uri'
    RUBY

    expect_correction(<<~RUBY)
      if condition
      end
      require 'uri'
    RUBY
  end

  it 'registers an offense when using requiring `enumerator` as the last statement of a method' do
    expect_offense(<<~RUBY)
      def foo
        bar
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        bar
      end
    RUBY
  end

  it 'registers an offense when using requiring `enumerator` in a block and a `rescue` branch' do
    expect_offense(<<~RUBY)
      foo do
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
      end

      begin
        bar
      rescue LoadError
        require 'enumerator' # comment
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
      end
    RUBY

    expect_correction(<<~RUBY)
      foo do
      end

      begin
        bar
      rescue LoadError
      end
    RUBY
  end

  it 'does not register an offense when the return value of requiring `enumerator` is assigned' do
    expect_no_offenses(<<~RUBY)
      x ||=
        require 'enumerator'
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` is used as an argument' do
    expect_no_offenses(<<~RUBY)
      foo(
        require('enumerator')
      )
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` is used as an array element' do
    expect_no_offenses(<<~RUBY)
      [
        require('enumerator'),
        foo
      ]
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` is used as an operand' do
    expect_no_offenses(<<~RUBY)
      foo &&
        require('enumerator')
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` is used as a ternary branch' do
    expect_no_offenses(<<~RUBY)
      foo ?
        require('enumerator') :
        bar
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` is the body of an endless method', :ruby30 do
    expect_no_offenses(<<~RUBY)
      def foo =
        require('enumerator')
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` is the condition of a modifier `if`' do
    expect_no_offenses(<<~RUBY)
      foo if require('enumerator')
    RUBY
  end

  it 'does not register an offense when requiring `enumerator` shares its line with other code' do
    expect_no_offenses(<<~RUBY)
      foo; require 'enumerator'
      require 'enumerator'; bar
      baz { require 'enumerator' }
      if foo then require 'enumerator' else bar end
      require 'enumerator' rescue nil
    RUBY
  end

  context 'target ruby version <= 2.0', :ruby20, unsupported_on: :prism do
    it 'does not register an offense when using requiring `thread`' do
      expect_no_offenses(<<~RUBY)
        require 'thread'
      RUBY
    end
  end

  context 'target ruby version >= 2.1', :ruby21 do
    it 'registers an offense and corrects when using requiring `thread` or already redundant features' do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'thread'
        ^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end
  end

  context 'target ruby version <= 2.1', :ruby21, unsupported_on: :prism do
    it 'does not register an offense when using requiring `rational`, `complex`' do
      expect_no_offenses(<<~RUBY)
        require 'rational'
        require 'complex'
      RUBY
    end
  end

  context 'target ruby version >= 2.2', :ruby22 do
    it 'registers an offense when using requiring `rational`, `complex`' do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'rational'
        ^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'complex'
        ^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'thread'
        ^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end
  end

  context 'target ruby version >= 2.5', :ruby25 do
    it 'registers an offense and corrects when requiring redundant features' do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'rational'
        ^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'complex'
        ^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'thread'
        ^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end

    it 'registers no offense when requiring "pp"' do
      expect_no_offenses(<<~RUBY)
        require 'pp'

        # Imagine this code to be in a different file than the require.
        foo.pretty_inspect
      RUBY
    end
  end

  context 'target ruby version <= 2.6', :ruby26, unsupported_on: :prism do
    it 'does not register an offense when using requiring `ruby2_keywords`' do
      expect_no_offenses(<<~RUBY)
        require 'ruby2_keywords'
      RUBY
    end
  end

  context 'target ruby version >= 2.7', :ruby27 do
    it 'registers an offense when using requiring `ruby2_keywords` or already redundant features' do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'rational'
        ^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'complex'
        ^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'thread'
        ^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'ruby2_keywords'
        ^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end
  end

  context 'target ruby version < 3.1', :ruby30, unsupported_on: :prism do
    it 'does not register an offense when using requiring `fiber`' do
      expect_no_offenses(<<~RUBY)
        require 'fiber'
      RUBY
    end
  end

  context 'target ruby version >= 3.1', :ruby31 do
    it 'registers an offense and corrects when using requiring `fiber` or already redundant features' do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'rational'
        ^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'complex'
        ^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'thread'
        ^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'ruby2_keywords'
        ^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'fiber'
        ^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end

    context 'target ruby version <= 3.1', :ruby31, unsupported_on: :prism do
      it 'does not register an offense when requiring `set`' do
        expect_no_offenses(<<~RUBY)
          require 'set'
        RUBY
      end
    end

    context 'target ruby version >= 3.2', :ruby32 do
      it 'registers an offense and corrects when using requiring `set`' do
        expect_offense(<<~RUBY)
          require 'set'
          ^^^^^^^^^^^^^ Remove unnecessary `require` statement.
          require 'uri'
        RUBY

        expect_correction(<<~RUBY)
          require 'uri'
        RUBY
      end
    end

    context 'target ruby version <= 3.3', :ruby33 do
      it 'does not register an offense when requiring `pathname`' do
        expect_no_offenses(<<~RUBY)
          require 'pathname'
        RUBY
      end
    end

    context 'target ruby version >= 4.0', :ruby40 do
      it 'registers an offense and corrects when requiring `pathname`' do
        expect_offense(<<~RUBY)
          require 'pathname'
          ^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
          require 'uri'
        RUBY

        expect_correction(<<~RUBY)
          require 'uri'
        RUBY
      end
    end
  end
end
