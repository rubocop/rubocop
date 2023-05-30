# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RequireOrder, :config do
  context 'when `require` is sorted' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'a'
        require 'b'
      RUBY
    end

    it 'registers no offense when single-quoted string and double-quoted string are mixed' do
      expect_no_offenses(<<~RUBY)
        require 'a'
        require "b"
      RUBY
    end
  end

  context 'when only one `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'a'
      RUBY
    end
  end

  context 'when `require` is not sorted in different sections' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'b'
        require 'd'

        require 'a'
        require 'c'
      RUBY
    end
  end

  context 'when `require` is not sorted' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require 'b'
        require 'a'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        require 'a'
        require 'b'
      RUBY
    end
  end

  context 'when unsorted `require` has some inline comments' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require 'b' # comment
        require 'a'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        require 'a'
        require 'b' # comment
      RUBY
    end
  end

  context 'when unsorted `require` has some full-line comments' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require 'b'
        # comment
        require 'a'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        # comment
        require 'a'
        require 'b'
      RUBY
    end
  end

  context 'when `require_relative` is not sorted' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require_relative 'b'
        require_relative 'a'
        ^^^^^^^^^^^^^^^^^^^^ Sort `require_relative` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        require_relative 'a'
        require_relative 'b'
      RUBY
    end
  end

  context 'when multiple `require` are not sorted' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require 'd'
        require 'a'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
        require 'b'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
        require 'c'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        require 'a'
        require 'b'
        require 'c'
        require 'd'
      RUBY
    end
  end

  context 'when both `require` and `require_relative` are in same section' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'b'
        require_relative 'a'
      RUBY
    end
  end

  context 'when `require_relative` is put between unsorted `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'c'
        require_relative 'b'
        require 'a'
      RUBY
    end
  end

  context 'when `require` is a method argument' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        do_something(require)
      RUBY
    end
  end

  context 'when `Bundler.require` is put between unsorted `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'e'
        Bundler.require(:default)
        require 'c'
      RUBY
    end
  end

  context 'when `Bundler.require` with no arguments is put between `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'c'
        Bundler.require
        require 'a'
      RUBY
    end
  end

  context 'when something other than a method call is used between `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'a'
        begin
        end
        require 'b'
      RUBY
    end
  end

  context 'when `if` is used between `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'c'
        if foo
          require 'a'
        end
        require 'b'
      RUBY
    end
  end

  context 'when `unless` is used between `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'c'
        unless foo
          require 'a'
        end
        require 'b'
      RUBY
    end
  end

  context 'when conditional with multiple `require` is used between `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'd'
        if foo
          require 'a'
          require 'b'
        end
        require 'c'
      RUBY
    end
  end

  context 'when conditional with multiple unsorted `require` is used between `require`' do
    it 'registers no offense' do
      expect_offense(<<~RUBY)
        require 'd'
        if foo
          require 'b'
          require 'a'
          ^^^^^^^^^^^ Sort `require` in alphabetical order.
        end
        require 'c'
      RUBY

      expect_correction(<<~RUBY)
        require 'd'
        if foo
          require 'a'
          require 'b'
        end
        require 'c'
      RUBY
    end
  end

  context 'when nested conditionals is used between `require`' do
    it 'registers no offense' do
      expect_no_offenses(<<~RUBY)
        require 'c'
        if foo
          if bar
            require 'a'
          end
        end
        require 'b'
      RUBY
    end
  end

  context 'when modifier conditional `if` is used between `require`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require 'c'
        require 'a' if foo
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
        require 'b'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        require 'a' if foo
        require 'b'
        require 'c'
      RUBY
    end
  end

  context 'when modifier conditional `unless` is used between `require`' do
    it 'registers offense' do
      expect_offense(<<~RUBY)
        require 'c'
        require 'a' unless foo
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
        require 'b'
        ^^^^^^^^^^^ Sort `require` in alphabetical order.
      RUBY

      expect_correction(<<~RUBY)
        require 'a' unless foo
        require 'b'
        require 'c'
      RUBY
    end
  end

  context 'when rescue block' do
    it 'registers offense for multiple unsorted `require`s' do
      expect_offense(<<~RUBY)
        begin
          do_something
        rescue
          require 'b'
          require 'a'
          ^^^^^^^^^^^ Sort `require` in alphabetical order.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
          do_something
        rescue
          require 'a'
          require 'b'
        end
      RUBY
    end

    it 'registers no offense for single `require`' do
      expect_no_offenses(<<~RUBY)
        begin
          do_something
        rescue
          require 'a'
        end
      RUBY
    end
  end
end
