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
