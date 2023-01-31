# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLineAfterGuardClause, :config do
  it 'does not register an offense when the clause is not followed by other code' do
    expect_no_offenses(<<~RUBY)
      return unless item.positive?
    RUBY
  end

  it 'registers an offense and corrects a guard clause not followed by empty line' do
    expect_offense(<<~RUBY)
      def foo
        return if need_return?
        ^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        foobar
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        return if need_return?

        foobar
      end
    RUBY
  end

  it 'registers an offense and corrects `next` guard clause not followed by empty line' do
    expect_offense(<<~RUBY)
      def foo
        next unless need_next? # comment
        ^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        foobar
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        next unless need_next? # comment

        foobar
      end
    RUBY
  end

  it 'registers an offense and corrects a guard clause is before `begin`' do
    expect_offense(<<~RUBY)
      def foo
        return another_object if something_different?
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        begin
          bar
        rescue SomeException
          baz
        end
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        return another_object if something_different?

        begin
          bar
        rescue SomeException
          baz
        end
      end
    RUBY
  end

  it 'registers an offense and corrects a `raise` guard clause not followed ' \
     'by empty line when `unless` condition is after heredoc' do
    expect_offense(<<~RUBY)
      def foo
        raise ArgumentError, <<-MSG unless path
          Must be called with mount point
        MSG
      ^^^^^ Add empty line after guard clause.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        raise ArgumentError, <<-MSG unless path
          Must be called with mount point
        MSG

        bar
      end
    RUBY
  end

  it 'registers an offense and corrects a `raise` guard clause not followed ' \
     'by empty line when `if` condition is after heredoc' do
    expect_offense(<<~RUBY)
      def foo
        raise ArgumentError, <<-MSG if path
          Must be called with mount point
        MSG
      ^^^^^ Add empty line after guard clause.
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        raise ArgumentError, <<-MSG if path
          Must be called with mount point
        MSG

        bar
      end
    RUBY
  end

  it 'registers an offense and corrects a next guard clause not followed by ' \
     'empty line when guard clause is after heredoc ' \
     'including string interpolation' do
    expect_offense(<<~'RUBY')
      raise(<<-FAIL) unless true
        #{1 + 1}
      FAIL
      ^^^^ Add empty line after guard clause.
      1
    RUBY

    expect_correction(<<~'RUBY')
      raise(<<-FAIL) unless true
        #{1 + 1}
      FAIL

      1
    RUBY
  end

  it 'accepts a `raise` guard clause not followed by empty line when guard ' \
     'clause is after condition without method invocation' do
    expect_no_offenses(<<~RUBY)
      def foo
        raise unless $1 == o

        bar
      end
    RUBY
  end

  it 'registers an offense and corrects a `raise` guard clause not followed ' \
     'by empty line when guard clause is after method call with argument' do
    expect_offense(<<~'RUBY')
      def foo
        raise SerializationError.new("Unsupported argument type: #{argument.class.name}") unless serializer
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        serializer.serialize(argument)
      end
    RUBY

    expect_correction(<<~'RUBY')
      def foo
        raise SerializationError.new("Unsupported argument type: #{argument.class.name}") unless serializer

        serializer.serialize(argument)
      end
    RUBY
  end

  it 'registers an offense and corrects when using `and return` before guard condition' do
    expect_offense(<<~RUBY)
      def foo
        render :foo and return if condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        render :foo and return if condition

        do_something
      end
    RUBY
  end

  it 'registers an offense and corrects when using `or return` before guard condition' do
    expect_offense(<<~RUBY)
      def foo
        render :foo or return if condition
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        do_something
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        render :foo or return if condition

        do_something
      end
    RUBY
  end

  it 'registers and corrects when using guard clause is after `rubocop:disable` comment' do
    expect_offense(<<~RUBY)
      def foo
        return if condition
        ^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        # rubocop:disable Department/Cop
        bar
        # rubocop:enable Department/Cop
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        return if condition

        # rubocop:disable Department/Cop
        bar
        # rubocop:enable Department/Cop
      end
    RUBY
  end

  it 'registers and corrects when using guard clause is after `rubocop:enable` comment' do
    expect_offense(<<~RUBY)
      def foo
        # rubocop:disable Department/Cop
        return if condition
        ^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        # rubocop:enable Department/Cop
        bar
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        # rubocop:disable Department/Cop
        return if condition
        # rubocop:enable Department/Cop

        bar
      end
    RUBY
  end

  it 'accepts modifier if' do
    expect_no_offenses(<<~RUBY)
      def foo
        foo += 1 if need_add?
        foobar
      end
    RUBY
  end

  it 'accepts a guard clause followed by empty line when guard clause including heredoc' do
    expect_no_offenses(<<~RUBY)
      def method
        if truthy
          raise <<-MSG
            This is an error.
          MSG
        end

        value
      end
    RUBY
  end

  it 'registers an offense and corrects a guard clause not followed by ' \
     'empty line when guard clause including heredoc' do
    expect_offense(<<~RUBY)
      def method
        if truthy
          raise <<-MSG
            This is an error.
          MSG
        end
        ^^^ Add empty line after guard clause.
        value
      end
    RUBY

    expect_correction(<<~RUBY)
      def method
        if truthy
          raise <<-MSG
            This is an error.
          MSG
        end

        value
      end
    RUBY
  end

  it 'accepts a guard clause followed by end' do
    expect_no_offenses(<<~RUBY)
      def foo
        if something?
          return
        end
      end
    RUBY
  end

  it 'accepts using guard clause is after `raise`' do
    expect_no_offenses(<<~RUBY)
      def foo
        raise ArgumentError, 'HTTP redirect too deep' if limit.zero?

        foobar
      end
    RUBY
  end

  it 'accepts using guard clause is after `rubocop:enable` comment' do
    expect_no_offenses(<<~RUBY)
      def foo
        # rubocop:disable Department/Cop
        return if condition
        # rubocop:enable Department/Cop

        bar
      end
    RUBY
  end

  it 'accepts a guard clause inside oneliner block' do
    expect_no_offenses(<<~RUBY)
      def foo
        object.tap { |obj| return another_object if something? }
        foobar
      end
    RUBY
  end

  it 'accepts multiple guard clauses' do
    expect_no_offenses(<<~RUBY)
      def foo
        return another_object if something?
        return another_object if something_else?
        return another_object if something_different?

        foobar
      end
    RUBY
  end

  it 'accepts a modifier if when the next line is `end`' do
    expect_no_offenses(<<~RUBY)
      def foo
        return another_object if something_different?
      end
    RUBY
  end

  it 'accepts a guard clause when the next line is `rescue`' do
    expect_no_offenses(<<~RUBY)
      def foo
        begin
          return another_object if something_different?
        rescue SomeException
          bar
        end
      end
    RUBY
  end

  it 'accepts a guard clause when the next line is `ensure`' do
    expect_no_offenses(<<~RUBY)
      def foo
        begin
          return another_object if something_different?
        ensure
          bar
        end
      end
    RUBY
  end

  it 'accepts a guard clause when the next line is `rescue`-`else`' do
    expect_no_offenses(<<~RUBY)
      def foo
        begin
          bar
        rescue SomeException
          return another_object if something_different?
        else
          bar
        end
      end
    RUBY
  end

  it 'accepts a guard clause when the next line is `else`' do
    expect_no_offenses(<<~RUBY)
      def foo
        if cond
          return another_object if something_different?
        else
          bar
        end
      end
    RUBY
  end

  it 'accepts a guard clause when the next line is `elsif`' do
    expect_no_offenses(<<~RUBY)
      def foo
        if cond
          return another_object if something_different?
        elsif
          bar
        end
      end
    RUBY
  end

  it 'accepts a guard clause after a single line heredoc' do
    expect_no_offenses(<<~RUBY)
      def foo
        raise ArgumentError, <<-MSG unless path
          Must be called with mount point
        MSG

        bar
      end
    RUBY
  end

  it 'accepts a guard clause that is after multiline heredoc' do
    expect_no_offenses(<<~RUBY)
      def foo
        raise ArgumentError, <<-MSG unless path
          foo
          bar
          baz
        MSG

        bar
      end
    RUBY
  end

  it 'accepts a guard clause that is after a multiline heredoc with chained calls' do
    expect_no_offenses(<<~RUBY)
      def foo
        raise ArgumentError, <<~END.squish.it.good unless guard
          A multiline message
          that will be squished.
        END

        return_value
      end
    RUBY
  end

  it 'accepts a guard clause that is after a multiline heredoc nested argument call' do
    expect_no_offenses(<<~RUBY)
      def foo
        raise ArgumentError, call(<<~END.squish) unless guard
          A multiline message
          that will be squished.
        END

        return_value
      end
    RUBY
  end

  it 'registers an offense and corrects a guard clause that is a ternary operator' do
    expect_offense(<<~RUBY)
      def foo
        puts 'some action happens here'
      rescue => e
        a_check ? raise(e) : other_thing
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        true
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        puts 'some action happens here'
      rescue => e
        a_check ? raise(e) : other_thing

        true
      end
    RUBY
  end

  it 'registers an offense and corrects a method starting with end_' do
    expect_offense(<<~RUBY)
      def foo
        next unless need_next?
        ^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        end_this!
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        next unless need_next?

        end_this!
      end
    RUBY
  end

  it 'registers an offense and corrects only the last guard clause' do
    expect_offense(<<~RUBY)
      def foo
        next if foo?
        next if bar?
        ^^^^^^^^^^^^ Add empty line after guard clause.
        foobar
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        next if foo?
        next if bar?

        foobar
      end
    RUBY
  end

  it 'registers no offenses using heredoc with `and return` before guard condition with empty line' do
    expect_no_offenses(<<~RUBY)
      def foo
        puts(<<~MSG) and return if bar
          A multiline
          message
        MSG

        baz
      end
    RUBY
  end

  it 'registers an offense and corrects using heredoc with `and return` before guard condition' do
    expect_offense(<<~RUBY)
      def foo
        puts(<<~MSG) and return if bar
          A multiline
          message
        MSG
      ^^^^^ Add empty line after guard clause.
        baz
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        puts(<<~MSG) and return if bar
          A multiline
          message
        MSG

        baz
      end
    RUBY
  end

  it 'does not register an offense when there are multiple clauses on the same line' do
    expect_no_offenses(<<~RUBY)
      def foo(item)
        return unless item.positive?; item * 2
      end
    RUBY
  end

  it 'registers an offense when the clause ends with a semicolon but the next clause is on the next line' do
    expect_offense(<<~RUBY)
      def foo(item)
        return unless item.positive?;
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Add empty line after guard clause.
        item * 2
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo(item)
        return unless item.positive?;

        item * 2
      end
    RUBY
  end

  it 'does not register an offense when the clause ends with a semicolon but is followed by a newline' do
    expect_no_offenses(<<~RUBY)
      def foo(item)
        return unless item.positive?;

        item * 2
      end
    RUBY
  end
end
