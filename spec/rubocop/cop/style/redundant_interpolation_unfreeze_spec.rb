# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantInterpolationUnfreeze, :config do
  context 'target_ruby_version >= 3.0', :ruby30 do
    it 'registers an offense for `@+`' do
      expect_offense(<<~'RUBY')
        +"#{foo} bar"
        ^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{foo} bar"
      RUBY
    end

    it 'does not register an offense when a comment follows the opening parenthesis of `String.new`' do
      expect_no_offenses(<<~'RUBY')
        String.new( # comment
          "#{foo} bar"
        )
      RUBY
    end

    it 'does not register an offense when a comment follows the string in `String.new`' do
      expect_no_offenses(<<~'RUBY')
        String.new(
          "#{foo} bar" # comment
        )
      RUBY
    end

    it 'does not register an offense when a comment is between the string and `dup`' do
      expect_no_offenses(<<~'RUBY')
        "#{foo} bar" # comment
          .dup
      RUBY
    end

    it 'registers an offense when a comment is inside the interpolation' do
      expect_offense(<<~'RUBY')
        "#{foo # comment
        } bar".dup
               ^^^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{foo # comment
        } bar"
      RUBY
    end

    it 'registers an offense when a comment follows the unfreezing call' do
      expect_offense(<<~'RUBY')
        String.new("#{foo} bar") # comment
        ^^^^^^^^^^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{foo} bar" # comment
      RUBY
    end

    it 'registers an offense for `@+` as a normal method call' do
      expect_offense(<<~'RUBY')
        "#{foo} bar".+@
                     ^^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{foo} bar"
      RUBY
    end

    it 'registers an offense for `dup`' do
      expect_offense(<<~'RUBY')
        "#{foo} bar".dup
                     ^^^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{foo} bar"
      RUBY
    end

    it 'registers an offense for interpolated heredoc with `@+`' do
      expect_offense(<<~'RUBY')
        foo(+<<~MSG)
            ^ Don't unfreeze interpolated strings as they are already unfrozen.
          foo #{bar}
          baz
        MSG
      RUBY

      expect_correction(<<~'RUBY')
        foo(<<~MSG)
          foo #{bar}
          baz
        MSG
      RUBY
    end

    it 'registers an offense for interpolated strings with global variables' do
      expect_offense(<<~'RUBY')
        +"#$var"
        ^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#$var"
      RUBY
    end

    it 'registers an offense for strings with interpolated instance variables' do
      expect_offense(<<~'RUBY')
        +"#@var"
        ^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#@var"
      RUBY
    end

    it 'registers an offense for strings with interpolated class variables' do
      expect_offense(<<~'RUBY')
        +"#@@var"
        ^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#@@var"
      RUBY
    end

    it 'registers an offense for interpolated heredoc with `dup`' do
      expect_offense(<<~'RUBY')
        foo(<<~MSG.dup)
                   ^^^ Don't unfreeze interpolated strings as they are already unfrozen.
          foo #{bar}
          baz
        MSG
      RUBY

      expect_correction(<<~'RUBY')
        foo(<<~MSG)
          foo #{bar}
          baz
        MSG
      RUBY
    end

    it 'registers an offense for `String.new` with interpolated string' do
      expect_offense(<<~'RUBY')
        String.new("#{1}")
        ^^^^^^^^^^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{1}"
      RUBY
    end

    it 'registers an offense for an unfrozen string interpolated into another one' do
      expect_offense(<<~'RUBY')
        +"#{String.new("#{foo}")} #{"#{bar}".dup}"
        ^ Don't unfreeze interpolated strings as they are already unfrozen.
            ^^^^^^^^^^ Don't unfreeze interpolated strings as they are already unfrozen.
                                             ^^^ Don't unfreeze interpolated strings as they are already unfrozen.
      RUBY

      expect_correction(<<~'RUBY')
        "#{"#{foo}"} #{"#{bar}"}"
      RUBY
    end

    it 'registers no offense for uninterpolated heredoc' do
      expect_no_offenses(<<~'RUBY')
        foo(+<<~'MSG')
          foo #{bar}
          baz
        MSG
      RUBY
    end

    it 'registers no offense for plain string literals' do
      expect_no_offenses(<<~RUBY)
        "foo".dup
      RUBY
    end

    it 'registers no offense for other types' do
      expect_no_offenses(<<~RUBY)
        local.dup
      RUBY
    end

    it 'registers no offense when the method has arguments' do
      expect_no_offenses(<<~'RUBY')
        "#{foo} bar".dup(baz)
      RUBY
    end

    it 'registers no offense for multiline string literals' do
      expect_no_offenses(<<~RUBY)
        +'foo' \
        'bar'
      RUBY
    end

    it 'registers no offense when there is no receiver' do
      expect_no_offenses(<<~RUBY)
        dup
      RUBY
    end

    it 'registers no offense for `String.new` with interpolated string and keyword arguments' do
      expect_no_offenses(<<~'RUBY')
        String.new("#{1}", encoding: Encoding::US_ASCII)
      RUBY
    end
  end

  context 'target_ruby_version < 3.0', :ruby27, unsupported_on: :prism do
    it 'accepts unfreezing an interpolated string' do
      expect_no_offenses('+"#{foo} bar"')
    end
  end
end
