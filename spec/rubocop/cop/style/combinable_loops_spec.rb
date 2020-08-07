# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CombinableLoops do
  subject(:cop) { described_class.new }

  context 'when looping method' do
    it 'registers an offense when looping over the same data as previous loop' do
      expect_offense(<<~RUBY)
        items.each { |item| do_something(item) }
        items.each { |item| do_something_else(item, arg) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine this loop with the previous loop.

        items.each_with_index { |item| do_something(item) }
        items.each_with_index { |item| do_something_else(item, arg) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine this loop with the previous loop.

        items.reverse_each { |item| do_something(item) }
        items.reverse_each { |item| do_something_else(item, arg) }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine this loop with the previous loop.
      RUBY
    end

    it 'does not register an offense when the same loops are interleaved with some code' do
      expect_no_offenses(<<~RUBY)
        items.each { |item| do_something(item) }

        some_code

        items.each { |item| do_something_else(item, arg) }
      RUBY
    end

    it 'does not register an offense when the same loop method is used over different collections' do
      expect_no_offenses(<<~RUBY)
        items.each { |item| do_something(item) }
        bars.each { |bar| do_something(bar) }
      RUBY
    end

    it 'does not register an offense when different loop methods are used over the same collection' do
      expect_no_offenses(<<~RUBY)
        items.reverse_each { |item| do_something(item) }
        items.each { |item| do_something(item) }
      RUBY
    end

    it 'does not register an offense when each branch contains the same single loop over the same collection' do
      expect_no_offenses(<<~RUBY)
        if condition
          items.each { |item| do_something(item) }
        else
          items.each { |item| do_something_else(item, arg) }
        end
      RUBY
    end
  end

  context 'when for loop' do
    it 'registers an offense when looping over the same data as previous loop' do
      expect_offense(<<~RUBY)
        for item in items do do_something(item) end
        for item in items do do_something_else(item, arg) end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Combine this loop with the previous loop.
      RUBY
    end

    it 'does not register an offense when the same loops are interleaved with some code' do
      expect_no_offenses(<<~RUBY)
        for item in items do do_something(item) end

        some_code

        for item in items do do_something_else(item, arg) end
      RUBY
    end

    it 'does not register an offense when the same loop method is used over different collections' do
      expect_no_offenses(<<~RUBY)
        for item in items do do_something(item) end
        for foo in foos do do_something(foo) end
      RUBY
    end

    it 'does not register an offense when each branch contains the same single loop over the same collection' do
      expect_no_offenses(<<~RUBY)
        if condition
          for item in items do do_something(item) end
        else
          for item in items do do_something_else(item, arg) end
        end
      RUBY
    end
  end
end
