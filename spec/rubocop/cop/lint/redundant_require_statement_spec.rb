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

  context 'target ruby version <= 2.0', :ruby20 do
    it 'does not register an offense when using requiring `thread`' do
      expect_no_offenses(<<~RUBY)
        require 'thread'
      RUBY
    end
  end

  context 'target ruby version >= 2.1', :ruby21 do
    it 'register an offense and corrects when using requiring `thread` or already redundant features' do
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

  context 'target ruby version <= 2.1', :ruby21 do
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

  context 'target ruby version <= 2.4', :ruby24 do
    it 'does not register an offense when using requiring `pp`' do
      expect_no_offenses(<<~RUBY)
        require 'pp'

        pp foo
      RUBY
    end
  end

  context 'target ruby version >= 2.5', :ruby25 do
    it 'register an offense and corrects when using requiring `pp` or already redundant features' do
      expect_offense(<<~RUBY)
        require 'enumerator'
        ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'rational'
        ^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'complex'
        ^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'thread'
        ^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'pp'
        ^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end

    context 'when requiring `pp`' do
      it 'does not register an offense and corrects when using `pretty_inspect`' do
        expect_no_offenses(<<~RUBY)
          require 'pp'

          foo.pretty_inspect
        RUBY
      end

      it 'does not register an offense and corrects when using `pretty_print`' do
        expect_no_offenses(<<~RUBY)
          require 'pp'

          foo.pretty_print(pp_instance)
        RUBY
      end

      it 'does not register an offense and corrects when using `pretty_print_cycle`' do
        expect_no_offenses(<<~RUBY)
          require 'pp'

          foo.pretty_print_cycle(pp_instance)
        RUBY
      end

      it 'does not register an offense and corrects when using `pretty_print_inspect`' do
        expect_no_offenses(<<~RUBY)
          require 'pp'

          foo.pretty_print_inspect
        RUBY
      end

      it 'does not register an offense and corrects when using `pretty_print_instance_variables`' do
        expect_no_offenses(<<~RUBY)
          require 'pp'

          foo.pretty_print_instance_variables
        RUBY
      end
    end
  end

  context 'target ruby version <= 2.6', :ruby26 do
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
        require 'pp'
        ^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'ruby2_keywords'
        ^^^^^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
        require 'uri'
      RUBY

      expect_correction(<<~RUBY)
        require 'uri'
      RUBY
    end
  end

  context 'target ruby version < 3.1', :ruby30 do
    it 'does not register an offense and corrects when using requiring `fiber`' do
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
        require 'pp'
        ^^^^^^^^^^^^ Remove unnecessary `require` statement.
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
  end
end
