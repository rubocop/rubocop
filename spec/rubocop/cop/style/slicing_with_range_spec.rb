# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SlicingWithRange, :config do
  context '<= Ruby 2.5', :ruby25, unsupported_on: :prism do
    it 'reports no offense for array slicing end with `-1`' do
      expect_no_offenses(<<~RUBY)
        ary[1..-1]
      RUBY
    end
  end

  context '>= Ruby 2.6', :ruby26 do
    it 'reports an offense for slicing with `[0..-1]`' do
      expect_offense(<<~RUBY)
        ary[0..-1]
           ^^^^^^^ Remove the useless `[0..-1]`.
      RUBY

      expect_correction(<<~RUBY)
        ary
      RUBY
    end

    it 'does not register an offense for slicing with `[0...-1]`' do
      expect_no_offenses(<<~RUBY)
        ary[0...-1]
      RUBY
    end

    it 'reports an offense for slicing with `[0..nil]`' do
      expect_offense(<<~RUBY)
        ary[0..nil]
           ^^^^^^^^ Remove the useless `[0..nil]`.
      RUBY

      expect_correction(<<~RUBY)
        ary
      RUBY
    end

    it 'reports an offense for slicing with `[0...nil]`' do
      expect_offense(<<~RUBY)
        ary[0...nil]
           ^^^^^^^^^ Remove the useless `[0...nil]`.
      RUBY

      expect_correction(<<~RUBY)
        ary
      RUBY
    end

    it 'reports an offense for slicing to `..-1`' do
      expect_offense(<<~RUBY)
        ary[1..-1]
           ^^^^^^^ Prefer `[1..]` over `[1..-1]`.
      RUBY

      expect_correction(<<~RUBY)
        ary[1..]
      RUBY
    end

    it 'reports an offense for slicing to `..nil`' do
      expect_offense(<<~RUBY)
        ary[1..nil]
           ^^^^^^^^ Prefer `[1..]` over `[1..nil]`.
      RUBY

      expect_correction(<<~RUBY)
        ary[1..]
      RUBY
    end

    it 'reports an offense for slicing to `...nil`' do
      expect_offense(<<~RUBY)
        ary[1...nil]
           ^^^^^^^^^ Prefer `[1...]` over `[1...nil]`.
      RUBY

      expect_correction(<<~RUBY)
        ary[1...]
      RUBY
    end

    it 'reports an offense for slicing from expression to `..-1`' do
      expect_offense(<<~RUBY)
        ary[fetch_start(true).first..-1]
           ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer `[fetch_start(true).first..]` over `[fetch_start(true).first..-1]`.
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

    it 'reports no offense for array slicing start with 0' do
      expect_no_offenses(<<~RUBY)
        ary[0..42]
      RUBY
    end
  end

  context '>= Ruby 2.7', :ruby27 do
    it 'reports an offense for slicing with `[nil..42]`' do
      expect_offense(<<~RUBY)
        ary[nil..42]
           ^^^^^^^^^ Prefer `[..42]` over `[nil..42]`.
      RUBY

      expect_correction(<<~RUBY)
        ary[..42]
      RUBY
    end

    it 'does not register an offense for slicing with `[0..42]`' do
      expect_no_offenses(<<~RUBY)
        ary[0..42]
      RUBY
    end

    it 'reports no offense for startless' do
      expect_no_offenses(<<~RUBY)
        ary[..-1]
      RUBY
    end
  end
end
