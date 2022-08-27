# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnreachableLoop, :config do
  context 'without preceding continue statements' do
    it 'registers an offense when using `break`' do
      expect_offense(<<~RUBY)
        while x > 0
        ^^^^^^^^^^^ This loop will have at most one iteration.
          x += 1
          break
        end
      RUBY
    end

    it 'registers an offense when using `if-else` with all break branches' do
      expect_offense(<<~RUBY)
        while x > 0
        ^^^^^^^^^^^ This loop will have at most one iteration.
          if condition
            break
          else
            raise MyError
          end
        end
      RUBY
    end

    it 'does not register an offense when using `if` without `else`' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          if condition
            break
          elsif other_condition
            raise MyError
          end
        end
      RUBY
    end

    it 'does not register an offense when using `if-elsif-else` and not all branches are breaking' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          if condition
            break
          elsif other_condition
            do_something
          else
            raise MyError
          end
        end
      RUBY
    end

    it 'registers an offense when using `case-when-else` with all break branches' do
      expect_offense(<<~RUBY)
        while x > 0
        ^^^^^^^^^^^ This loop will have at most one iteration.
          case x
          when 1
            break
          else
            raise MyError
          end
        end
      RUBY
    end

    it 'does not register an offense when using `case` without `else`' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          case x
          when 1
            break
          end
        end
      RUBY
    end

    it 'does not register an offense when using `case-when-else` and not all branches are breaking' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          case x
          when 1
            break
          when 2
            do_something
          else
            raise MyError
          end
        end
      RUBY
    end
  end

  context 'with preceding continue statements' do
    it 'does not register an offense when using `break`' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          next if x.odd?
          x += 1
          break
        end
      RUBY
    end

    it 'does not register an offense when using `if-else` with all break branches' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          next if x.odd?
          if condition
            break
          else
            raise MyError
          end
        end
      RUBY
    end

    it 'does not register an offense when using `case-when-else` with all break branches' do
      expect_no_offenses(<<~RUBY)
        while x > 0
          redo if x.odd?

          case x
          when 1
            break
          else
            raise MyError
          end
        end
      RUBY
    end
  end

  context 'with an enumerator method' do
    context 'as the last item in a method chain' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          string.split('-').map { raise StandardError }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This loop will have at most one iteration.
        RUBY
      end
    end

    context 'not chained' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          string.map { raise StandardError }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This loop will have at most one iteration.
        RUBY
      end
    end

    context 'in the middle of a method chain' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          exactly(2).times.with(x) { raise StandardError }
        RUBY
      end
    end
  end

  context 'with AllowedPatterns' do
    let(:cop_config) { { 'AllowedPatterns' => [/exactly\(\d+\)\.times/] } }

    context 'with a ignored method call' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          exactly(2).times { raise StandardError }
        RUBY
      end
    end

    context 'with a non ignored method call' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          2.times { raise StandardError }
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This loop will have at most one iteration.
        RUBY
      end

      context 'Ruby 2.7', :ruby27 do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            2.times { raise _1 }
            ^^^^^^^^^^^^^^^^^^^^ This loop will have at most one iteration.
          RUBY
        end
      end
    end
  end

  it 'handles inner loops' do
    expect_offense(<<~RUBY)
      until x > 0
      ^^^^^^^^^^^ This loop will have at most one iteration.

        items.each do |item|
          next if item.odd?
          break
        end

        if x > 0
          break some_value
        else
          raise MyError
        end

        loop do
        ^^^^^^^ This loop will have at most one iteration.

          case y
          when 1
            return something
          when 2
            break
          else
            throw :exit
          end
        end
      end
    RUBY
  end

  it 'does not register an offense when branch includes continue statement preceding break statement' do
    expect_no_offenses(<<~RUBY)
      while x > 0
        if y
          next if something
          break
        else
          break
        end
      end
    RUBY
  end

  it 'does not register an offense when using `return do_something(value) || next` in a loop' do
    expect_no_offenses(<<~RUBY)
      [nil, nil, 42].each do |value|
        return do_something(value) || next
      end
    RUBY
  end

  it 'does not register an offense when using `return do_something(value) || redo` in a loop' do
    expect_no_offenses(<<~RUBY)
      [nil, nil, 42].each do |value|
        return do_something(value) || redo
      end
    RUBY
  end

  it 'registers an offense when using `return do_something(value) || break` in a loop' do
    expect_offense(<<~RUBY)
      [nil, nil, 42].each do |value|
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ This loop will have at most one iteration.
        return do_something(value) || break
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense when using `return do_something(value) || break` in a loop' do
      expect_offense(<<~RUBY)
        [1, 2, 3].each do
        ^^^^^^^^^^^^^^^^^ This loop will have at most one iteration.
          return _1.odd? || break
        end
      RUBY
    end
  end
end
