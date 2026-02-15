# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantStructKeywordInit, :config do
  context 'target ruby version < 3.2', :ruby31, unsupported_on: :prism do
    it 'does not register an offense when using keyword_init: true' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:name, :age, keyword_init: true)
      RUBY
    end
  end

  context 'target ruby version >= 3.2', :ruby32 do
    it 'registers an offense when using Struct.new with keyword_init: true' do
      expect_offense(<<~RUBY)
        Struct.new(:name, :age, keyword_init: true)
                                ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:name, :age)
      RUBY
    end

    it 'registers an offense when using Struct.new with single attribute and keyword_init: true' do
      expect_offense(<<~RUBY)
        Struct.new(:name, keyword_init: true)
                          ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:name)
      RUBY
    end

    it 'registers an offense when keyword_init: true is in hash with other options' do
      expect_offense(<<~RUBY)
        Struct.new(:name, :age, keyword_init: true, another_option: value)
                                ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:name, :age, another_option: value)
      RUBY
    end

    it 'registers an offense when keyword_init: true is last in hash with other options' do
      expect_offense(<<~RUBY)
        Struct.new(:name, :age, another_option: value, keyword_init: true)
                                                       ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:name, :age, another_option: value)
      RUBY
    end

    it 'does not register an offense when using Struct.new without keyword_init' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:name, :age)
      RUBY
    end

    it 'does not register an offense when using keyword_init: false' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:name, :age, keyword_init: false)
      RUBY
    end

    it 'does not register an offense when using Struct.new with no arguments' do
      expect_no_offenses(<<~RUBY)
        Struct.new
      RUBY
    end

    it 'does not register an offense when using Struct.new with only keyword_init' do
      expect_no_offenses(<<~RUBY)
        Struct.new(keyword_init: false)
      RUBY
    end

    it 'registers an offense for qualified Struct constant' do
      expect_offense(<<~RUBY)
        ::Struct.new(:name, keyword_init: true)
                            ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
      RUBY

      expect_correction(<<~RUBY)
        ::Struct.new(:name)
      RUBY
    end

    it 'registers an offense when Struct.new is used in assignment' do
      expect_offense(<<~RUBY)
        Person = Struct.new(:name, :age, keyword_init: true)
                                         ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
      RUBY

      expect_correction(<<~RUBY)
        Person = Struct.new(:name, :age)
      RUBY
    end

    it 'registers an offense when Struct.new is used with block' do
      expect_offense(<<~RUBY)
        Struct.new(:name, keyword_init: true) do
                          ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
          def greeting
            "Hello, \#{name}"
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(:name) do
          def greeting
            "Hello, \#{name}"
          end
        end
      RUBY
    end

    it 'registers an offense with multiline Struct.new' do
      expect_offense(<<~RUBY)
        Struct.new(
          :name,
          :age,
          keyword_init: true
          ^^^^^^^^^^^^^^^^^^ Redundant `keyword_init: true` for Struct (default in Ruby 3.2+).
        )
      RUBY

      expect_correction(<<~RUBY)
        Struct.new(
          :name,
          :age
        )
      RUBY
    end

    it 'does not register an offense for non-Struct classes' do
      expect_no_offenses(<<~RUBY)
        CustomClass.new(:name, keyword_init: true)
      RUBY
    end

    it 'does not register an offense when keyword_init value is not a literal true' do
      expect_no_offenses(<<~RUBY)
        Struct.new(:name, keyword_init: some_variable)
      RUBY
    end
  end
end
