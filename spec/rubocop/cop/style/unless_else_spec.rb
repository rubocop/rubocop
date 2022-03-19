# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnlessElse, :config do
  context 'unless with else' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless x # negative 1
        ^^^^^^^^^^^^^^^^^^^^^ Do not use `unless` with `else`. Rewrite these with the positive case first.
          a = 1 # negative 2
        else # positive 1
          a = 0 # positive 2
        end
      RUBY

      expect_correction(<<~RUBY)
        if x # positive 1
          a = 0 # positive 2
        else # negative 1
          a = 1 # negative 2
        end
      RUBY
    end

    context 'and nested unless with else' do
      it 'registers offenses for both but corrects only the outer unless/else' do
        expect_offense(<<~RUBY)
          unless abc
          ^^^^^^^^^^ Do not use `unless` with `else`. Rewrite these with the positive case first.
            a
          else
            unless cde
            ^^^^^^^^^^ Do not use `unless` with `else`. Rewrite these with the positive case first.
              b
            else
              c
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          if abc
            unless cde
              b
            else
              c
            end
          else
            a
          end
        RUBY
      end
    end
  end

  context 'unless with nested if-else' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        unless(x)
        ^^^^^^^^^ Do not use `unless` with `else`. Rewrite these with the positive case first.
          if(y == 0)
            a = 0
          elsif(z == 0)
            a = 1
          else
            a = 2
          end
        else
          a = 3
        end
      RUBY

      expect_correction(<<~RUBY)
        if(x)
          a = 3
        else
          if(y == 0)
            a = 0
          elsif(z == 0)
            a = 1
          else
            a = 2
          end
        end
      RUBY
    end
  end

  context 'unless without else' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        unless x
          a = 1
        end
      RUBY
    end
  end
end
