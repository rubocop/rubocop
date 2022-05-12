# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SlicingWithRange, :config do
  context '<= Ruby 2.5', :ruby25 do
    it 'reports no offense for array slicing with -1' do
      expect_no_offenses(<<~RUBY)
        ary[1..-1]
      RUBY
    end
  end

  context '>= Ruby 2.6', :ruby26 do
    it 'reports an offense for slicing to ..-1' do
      expect_offense(<<~RUBY)
        ary[1..-1]
            ^^^^^ Prefer ary[n..] over ary[n..-1].
      RUBY

      expect_correction(<<~RUBY)
        ary[1..]
      RUBY
    end

    it 'reports an offense for slicing from expression to ..-1' do
      expect_offense(<<~RUBY)
        ary[fetch_start(true).first..-1]
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer ary[n..] over ary[n..-1].
      RUBY

      expect_correction(<<~RUBY)
        ary[fetch_start(true).first..]
      RUBY
    end

    it 'reports no offense for excluding end' do
      expect_no_offenses(<<~RUBY)
        ary[1...-1]
      RUBY
    end

    it 'reports no offense for other methods' do
      expect_no_offenses(<<~RUBY)
        ary.push(1..-1)
      RUBY
    end

    it 'reports no offense for array with range inside' do
      expect_no_offenses(<<~RUBY)
        ranges = [1..-1]
      RUBY
    end
  end

  context '>= Ruby 2.7', :ruby27 do
    it 'reports no offense for startless' do
      expect_no_offenses(<<~RUBY)
        ary[..-1]
      RUBY
    end
  end
end
