# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::ImplicitStringConcatenation, :config do
  context 'on a single string literal' do
    it 'does not register an offense' do
      expect_no_offenses('abc')
    end
  end

  context 'on adjacent string literals on the same line' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        class A; "abc" "def"; end
                 ^^^^^^^^^^^ Combine "abc" and "def" into a single string literal, rather than using implicit string concatenation.
        class B; 'ghi' 'jkl'; end
                 ^^^^^^^^^^^ Combine 'ghi' and 'jkl' into a single string literal, rather than using implicit string concatenation.
      RUBY
    end
  end

  context 'on adjacent string literals on different lines' do
    it 'does not register an offense' do
      expect_no_offenses(<<~'RUBY')
        array = [
          'abc'\
          'def'
        ]
      RUBY
    end
  end

  context 'when the string literals contain newlines' do
    it 'registers an offense' do
      expect_offense(<<~'RUBY')
        def method
          "ab
          ^^^ Combine "ab\nc" and "de\nf" into a single string literal, [...]
        c" "de
        f"
        end
      RUBY
    end

    it 'does not register an offense for a single string' do
      expect_no_offenses(<<~RUBY)
        'abc
        def'
      RUBY
    end
  end

  context 'on a string with interpolations' do
    it 'does register an offense' do
      expect_no_offenses("array = [\"abc\#{something}def\#{something_else}\"]")
    end
  end

  context 'when inside an array' do
    it 'notes that the strings could be separated by a comma instead' do
      expect_offense(<<~RUBY)
        array = ["abc" "def"]
                 ^^^^^^^^^^^ Combine "abc" and "def" into a single string literal, rather than using implicit string concatenation. Or, if they were intended to be separate array elements, separate them with a comma.
      RUBY
    end
  end

  context "when in a method call's argument list" do
    it 'notes that the strings could be separated by a comma instead' do
      expect_offense(<<~RUBY)
        method("abc" "def")
               ^^^^^^^^^^^ Combine "abc" and "def" into a single string literal, rather than using implicit string concatenation. Or, if they were intended to be separate method arguments, separate them with a comma.
      RUBY
    end
  end
end
