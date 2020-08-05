# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnreachableLoop do
  subject(:cop) { described_class.new }

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
end
