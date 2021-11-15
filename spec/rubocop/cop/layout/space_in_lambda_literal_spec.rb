# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInLambdaLiteral, :config do
  context 'when configured to enforce spaces' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_space' } }

    it 'registers an offense and corrects no space between -> and (' do
      expect_offense(<<~RUBY)
        a = ->(b, c) { b + c }
            ^^^^^^^^ Use a space between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = -> (b, c) { b + c }
      RUBY
    end

    it 'does not register an offense for a space between -> and (' do
      expect_no_offenses('a = -> (b, c) { b + c }')
    end

    it 'does not register an offense for multi-line lambdas' do
      expect_no_offenses(<<~RUBY)
        l = lambda do |a, b|
          tmp = a * 7
          tmp * b / 50
        end
      RUBY
    end

    it 'does not register an offense for no space between -> and {' do
      expect_no_offenses('a = ->{ b + c }')
    end

    it 'registers an offense and corrects no space in the inner nested lambda' do
      expect_offense(<<~RUBY)
        a = -> (b = ->(c) {}, d) { b + d }
                    ^^^^^ Use a space between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = -> (b = -> (c) {}, d) { b + d }
      RUBY
    end

    it 'registers an offense and corrects no space in the outer nested lambda' do
      expect_offense(<<~RUBY)
        a = ->(b = -> (c) {}, d) { b + d }
            ^^^^^^^^^^^^^^^^^^^^ Use a space between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = -> (b = -> (c) {}, d) { b + d }
      RUBY
    end

    it 'registers an offense and corrects no space in both lambdas when nested' do
      expect_offense(<<~RUBY)
        a = ->(b = ->(c) {}, d) { b + d }
                   ^^^^^ Use a space between `->` and `(` in lambda literals.
            ^^^^^^^^^^^^^^^^^^^ Use a space between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = -> (b = -> (c) {}, d) { b + d }
      RUBY
    end
  end

  context 'when configured to enforce no space' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_space' } }

    it 'registers an offense and corrects a space between -> and (' do
      expect_offense(<<~RUBY)
        a = -> (b, c) { b + c }
              ^ Do not use spaces between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = ->(b, c) { b + c }
      RUBY
    end

    it 'does not register an offense for no space between -> and (' do
      expect_no_offenses('a = ->(b, c) { b + c }')
    end

    it 'does not register an offense for multi-line lambdas' do
      expect_no_offenses(<<~RUBY)
        l = lambda do |a, b|
          tmp = a * 7
          tmp * b / 50
        end
      RUBY
    end

    it 'does not register an offense for a space between -> and {' do
      expect_no_offenses('a = -> { b + c }')
    end

    it 'registers an offense and corrects spaces between -> and (' do
      expect_offense(<<~RUBY)
        a = ->   (b, c) { b + c }
              ^^^ Do not use spaces between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = ->(b, c) { b + c }
      RUBY
    end

    it 'registers an offense and corrects a space in the inner nested lambda' do
      expect_offense(<<~RUBY)
        a = ->(b = -> (c) {}, d) { b + d }
                     ^ Do not use spaces between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = ->(b = ->(c) {}, d) { b + d }
      RUBY
    end

    it 'registers an offense and corrects a space in the outer nested lambda' do
      expect_offense(<<~RUBY)
        a = -> (b = ->(c) {}, d) { b + d }
              ^ Do not use spaces between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = ->(b = ->(c) {}, d) { b + d }
      RUBY
    end

    it 'register offenses and correct spaces in both lambdas when nested' do
      expect_offense(<<~RUBY)
        a = -> (b = -> (c) {}, d) { b + d }
                      ^ Do not use spaces between `->` and `(` in lambda literals.
              ^ Do not use spaces between `->` and `(` in lambda literals.
      RUBY

      expect_correction(<<~RUBY)
        a = ->(b = ->(c) {}, d) { b + d }
      RUBY
    end
  end
end
