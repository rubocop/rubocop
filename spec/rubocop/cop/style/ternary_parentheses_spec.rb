# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::TernaryParentheses, :config do
  shared_examples 'safe assignment disabled' do |style, message|
    let(:cop_config) { { 'EnforcedStyle' => style, 'AllowSafeAssignment' => false } }

    it 'registers an offense for parens around assignment' do
      expect_offense(<<~RUBY)
        foo = (bar = find_bar) ? a : b
              ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for parens around inner assignment' do
      expect_offense(<<~RUBY)
        foo = bar = (baz = find_baz) ? a : b
                    ^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_no_corrections
    end

    it 'registers an offense for parens around outer assignment' do
      expect_offense(<<~RUBY)
        foo = (bar = baz = find_baz) ? a : b
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_no_corrections
    end
  end

  context 'when configured to enforce parentheses inclusion' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses' } }

    context 'with a simple condition' do
      it 'registers an offense for query method in condition' do
        expect_offense(<<~RUBY)
          foo = bar? ? a : b
                ^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar?) ? a : b
        RUBY
      end

      it 'registers an offense for yield in condition' do
        expect_offense(<<~RUBY)
          foo = yield ? a : b
                ^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (yield) ? a : b
        RUBY
      end

      it 'registers an offense for accessor in condition' do
        expect_offense(<<~RUBY)
          foo = bar[:baz] ? a : b
                ^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar[:baz]) ? a : b
        RUBY
      end
    end

    context 'with a complex condition' do
      it 'registers an offense for arithmetic condition' do
        expect_offense(<<~RUBY)
          foo = 1 + 1 == 2 ? a : b
                ^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (1 + 1 == 2) ? a : b
        RUBY
      end

      it 'registers an offense for boolean expression' do
        expect_offense(<<~RUBY)
          foo = bar && baz ? a : b
                ^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar && baz) ? a : b
        RUBY
      end

      it 'registers an offense for equality check' do
        expect_offense(<<~RUBY)
          foo = foo1 == foo2 ? a : b
                ^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (foo1 == foo2) ? a : b
        RUBY
      end

      it 'registers an offense when calling method on a receiver' do
        expect_offense(<<~RUBY)
          foo = bar.baz? ? a : b
                ^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar.baz?) ? a : b
        RUBY
      end

      it 'registers an offense for boolean expression containing parens' do
        expect_offense(<<~RUBY)
          foo = bar && (baz || bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar && (baz || bar)) ? a : b
        RUBY
      end

      it 'registers an offense for boolean expression using keyword' do
        expect_offense(<<~RUBY)
          foo = bar or baz ? a : b
                       ^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar or (baz) ? a : b
        RUBY
      end

      it 'registers an offense for negated condition' do
        expect_offense(<<~RUBY)
          not bar ? a : b
              ^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          not (bar) ? a : b
        RUBY
      end

      it 'registers an offense for defined? with variable in condition' do
        expect_offense(<<~RUBY)
          foo = defined?(bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (defined?(bar)) ? a : b
        RUBY
      end

      it 'registers an offense for defined? with method chain in condition' do
        expect_offense(<<~RUBY)
          foo = defined?(bar.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (defined?(bar.baz)) ? a : b
        RUBY
      end

      it 'registers an offense for defined? with class method in condition' do
        expect_offense(<<~RUBY)
          foo = defined?(Bar.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (defined?(Bar.baz)) ? a : b
        RUBY
      end

      it 'registers an offense for defined? with nested constant in condition' do
        expect_offense(<<~RUBY)
          foo = defined?(Bar::BAZ) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (defined?(Bar::BAZ)) ? a : b
        RUBY
      end
    end

    context 'with an assignment condition' do
      it 'registers an offense for double assignment' do
        expect_offense(<<~RUBY)
          foo = bar = baz ? a : b
                      ^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar = (baz) ? a : b
        RUBY
      end

      it 'registers an offense for triple assignment' do
        expect_offense(<<~RUBY)
          foo = bar = baz = find_baz ? a : b
                            ^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar = baz = (find_baz) ? a : b
        RUBY
      end

      it 'registers an offense for double assignment with equality check in condition' do
        expect_offense(<<~RUBY)
          foo = bar = baz == 1 ? a : b
                      ^^^^^^^^^^^^^^^^ Use parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar = (baz == 1) ? a : b
        RUBY
      end

      it 'accepts safe assignment in condition' do
        expect_no_offenses('foo = (bar = baz = find_baz) ? a : b')
      end
    end
  end

  context 'when configured to enforce parentheses omission' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_no_parentheses' } }

    context 'with a simple condition' do
      it 'registers an offense for query method in condition' do
        expect_offense(<<~RUBY)
          foo = (bar?) ? a : b
                ^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar? ? a : b
        RUBY
      end

      it 'registers an offense for yield in condition' do
        expect_offense(<<~RUBY)
          foo = (yield) ? a : b
                ^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = yield ? a : b
        RUBY
      end

      it 'registers an offense for accessor in condition' do
        expect_offense(<<~RUBY)
          foo = (bar[:baz]) ? a : b
                ^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar[:baz] ? a : b
        RUBY
      end

      it 'registers an offense for multi-line boolean expression' do
        expect_offense(<<~RUBY)
          (foo ||
          ^^^^^^^ Omit parentheses for ternary conditions.
            bar) ? a : b
        RUBY

        expect_correction(<<~RUBY)
          foo ||
            bar ? a : b
        RUBY
      end

      it 'accepts multi-line boolean expression starting on following line' do
        expect_no_offenses(<<~RUBY)
          (
            foo || bar
          ) ? a : b
        RUBY
      end
    end

    context 'with a complex condition' do
      it 'registers an offense for arithmetic expression' do
        expect_offense(<<~RUBY)
          foo = (1 + 1 == 2) ? a : b
                ^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = 1 + 1 == 2 ? a : b
        RUBY
      end

      it 'registers an offense for equality check' do
        expect_offense(<<~RUBY)
          foo = (foo1 == foo2) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = foo1 == foo2 ? a : b
        RUBY
      end

      it 'registers an offense for boolean expression' do
        expect_offense(<<~RUBY)
          foo = (bar && baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar && baz ? a : b
        RUBY
      end

      it 'registers an offense for query method on object' do
        expect_offense(<<~RUBY)
          foo = (bar.baz?) ? a : b
                ^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar.baz? ? a : b
        RUBY
      end

      it 'accepts parens around inner boolean expression' do
        expect_no_offenses('foo = bar && (baz || bar) ? a : b')
      end

      it 'registers an offense for boolean expression using keyword' do
        expect_offense(<<~RUBY)
          foo = (foo or bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for negated condition' do
        expect_offense(<<~RUBY)
          foo = (not bar) ? a : b
                ^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with variable in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with method chain in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? bar.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with class method in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? Bar.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with nested constant in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? Bar::BAZ) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end
    end

    # In Ruby 2.7, `match-pattern` node represents one line pattern matching.
    #
    # $ ruby-parse --27 -e 'foo in bar'
    # (match-pattern (send nil :foo) (match-var :bar))
    #
    context 'with one line pattern matching', :ruby27 do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          (foo in bar) ? a : b
        RUBY
      end
    end

    # In Ruby 3.0, `match-pattern-p` node represents one line pattern matching.
    #
    # $ ruby-parse --30 -e 'foo in bar'
    # (match-pattern-p (send nil :foo) (match-var :bar))
    #
    context 'with one line pattern matching', :ruby30 do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          (foo in bar) ? a : b
        RUBY
      end
    end

    context 'with an assignment condition' do
      it 'accepts safe assignment' do
        expect_no_offenses('foo = (bar = find_bar) ? a : b')
      end

      it 'accepts safe assignment as part of multiple assignment' do
        expect_no_offenses('foo = bar = (baz = find_baz) ? a : b')
      end

      it 'registers an offense for equality check' do
        expect_offense(<<~RUBY)
          foo = bar = (baz == 1) ? a : b
                      ^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar = baz == 1 ? a : b
        RUBY
      end

      it 'accepts double safe assignment' do
        expect_no_offenses('foo = (bar = baz = find_baz) ? a : b')
      end

      it_behaves_like 'safe assignment disabled',
                      'require_no_parentheses',
                      'Omit parentheses for ternary conditions.'
    end

    context 'with an unparenthesized method call condition' do
      it 'registers an offense for defined check' do
        expect_offense(<<~RUBY)
          foo = (defined? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense when calling method with a parameter' do
        expect_offense(<<~RUBY)
          foo = (baz? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_no_corrections
      end

      context 'when calling method on a receiver' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            foo = (baz.foo? bar) ? a : b
                  ^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
          RUBY

          expect_no_corrections
        end
      end

      context 'when calling method on a literal receiver' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            foo = ("bar".foo? bar) ? a : b
                  ^^^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
          RUBY

          expect_no_corrections
        end
      end

      context 'when calling method on a constant receiver' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            foo = (Bar.foo? bar) ? a : b
                  ^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
          RUBY

          expect_no_corrections
        end
      end

      context 'when calling method with multiple arguments' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            foo = (baz.foo? bar, baz) ? a : b
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Omit parentheses for ternary conditions.
          RUBY

          expect_no_corrections
        end
      end
    end

    it 'accepts condition including a range' do
      expect_no_offenses('(foo..bar).include?(baz) ? a : b')
    end

    context 'with no space between the parentheses and question mark' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          (foo)? a : b
          ^^^^^^^^^^^^ Omit parentheses for ternary conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo ? a : b
        RUBY
      end
    end
  end

  context 'configured for parentheses on complex and there are parens' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses_when_complex' } }

    context 'with a simple condition' do
      it 'registers an offense for query method in condition' do
        expect_offense(<<~RUBY)
          foo = (bar?) ? a : b
                ^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar? ? a : b
        RUBY
      end

      it 'registers an offense for yield in condition' do
        expect_offense(<<~RUBY)
          foo = (yield) ? a : b
                ^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = yield ? a : b
        RUBY
      end

      it 'registers an offense for accessor in condition' do
        expect_offense(<<~RUBY)
          foo = (bar[:baz]) ? a : b
                ^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar[:baz] ? a : b
        RUBY
      end

      it 'registers an offense with preceding boolean keyword expression' do
        expect_offense(<<~RUBY)
          foo = bar or (baz) ? a : b
                       ^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar or baz ? a : b
        RUBY
      end

      it 'registers an offense for save navigation' do
        expect_offense(<<~RUBY)
          foo = (bar&.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar&.baz ? a : b
        RUBY
      end
    end

    context 'with a complex condition' do
      it 'registers an offense when calling method on a receiver' do
        expect_offense(<<~RUBY)
          foo = (bar.baz?) ? a : b
                ^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar.baz? ? a : b
        RUBY
      end

      it 'accepts boolean expression using keywords' do
        expect_no_offenses('foo = (baz or bar) ? a : b')
      end

      it 'accepts boolean expression' do
        expect_no_offenses('foo = (bar && (baz || bar)) ? a : b')
      end

      it 'registers an offense for defined with variable in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with method chain in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? bar.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with class method in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? Bar.baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense for defined with nested constant in condition' do
        expect_offense(<<~RUBY)
          foo = (defined? Bar::BAZ) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end
    end

    context 'with an assignment condition' do
      it 'accepts safe assignment' do
        expect_no_offenses('foo = (bar = find_bar) ? a : b')
      end

      it 'accepts safe assignment as part of multiple assignment' do
        expect_no_offenses('foo = baz = (bar = find_bar) ? a : b')
      end

      it 'accepts equality check' do
        expect_no_offenses('foo = bar = (bar == 1) ? a : b')
      end

      it 'accepts accepts safe multiple assignment' do
        expect_no_offenses('foo = (bar = baz = find_bar) ? a : b')
      end

      it_behaves_like 'safe assignment disabled',
                      'require_parentheses_when_complex',
                      'Only use parentheses for ternary expressions with complex conditions.'
    end

    context 'with method call condition' do
      it 'registers an offense for defined check' do
        expect_offense(<<~RUBY)
          foo = (defined? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end

      context 'with accessor in method call parameters' do
        it 'registers an offense for array include? without parens' do
          expect_offense(<<~RUBY)
            (%w(a b).include? params[:t]) ? "ab" : "c"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
          RUBY

          expect_no_corrections
        end

        it 'registers an offense for array include? with multiple parameters without parens' do
          expect_offense(<<~RUBY)
            (%w(a b).include? params[:t], 3) ? "ab" : "c"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
          RUBY

          expect_no_corrections
        end

        it 'registers an offense for array include? with multiple parameters with parens' do
          expect_offense(<<~RUBY)
            (%w(a b).include?(params[:t], x)) ? "ab" : "c"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
          RUBY

          expect_correction(<<~RUBY)
            %w(a b).include?(params[:t], x) ? "ab" : "c"
          RUBY
        end
      end

      context 'without accessor in method call parameters' do
        it 'registers an offense for array include? without parens' do
          expect_offense(<<~RUBY)
            (%w(a b).include? "a") ? "ab" : "c"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
          RUBY

          expect_no_corrections
        end

        it 'registers an offense for array include? with parens' do
          expect_offense(<<~RUBY)
            (%w(a b).include?("a")) ? "ab" : "c"
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
          RUBY

          expect_correction(<<~RUBY)
            %w(a b).include?("a") ? "ab" : "c"
          RUBY
        end
      end

      it 'registers an offense when calling method with a parameter' do
        expect_offense(<<~RUBY)
          foo = (baz? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end

      it 'registers an offense when calling method on a receiver' do
        expect_offense(<<~RUBY)
          foo = (baz.foo? bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Only use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_no_corrections
      end
    end

    it 'accepts condition including a range' do
      expect_no_offenses('(foo..bar).include?(baz) ? a : b')
    end
  end

  context 'configured for parentheses on complex and there are no parens' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_parentheses_when_complex' } }

    context 'with complex condition' do
      it 'registers an offense for arithmetic and equality check' do
        expect_offense(<<~RUBY)
          foo = 1 + 1 == 2 ? a : b
                ^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (1 + 1 == 2) ? a : b
        RUBY
      end

      it 'registers an offense for boolean expression' do
        expect_offense(<<~RUBY)
          foo = bar && baz ? a : b
                ^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar && baz) ? a : b
        RUBY
      end

      it 'registers an offense for compound boolean expression' do
        expect_offense(<<~RUBY)
          foo = bar && baz || bar ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar && baz || bar) ? a : b
        RUBY
      end

      it 'registers an offense for boolean expression with inner parens' do
        expect_offense(<<~RUBY)
          foo = bar && (baz != bar) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar && (baz != bar)) ? a : b
        RUBY
      end

      it 'registers an offense for comparison with method call on receiver' do
        expect_offense(<<~RUBY)
          foo = 1 < (bar.baz?) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (1 < (bar.baz?)) ? a : b
        RUBY
      end

      it 'registers an offense comparison with exponentiation' do
        expect_offense(<<~RUBY)
          foo = 1 <= (bar ** baz) ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (1 <= (bar ** baz)) ? a : b
        RUBY
      end

      it 'registers an offense for comparison with multiplication' do
        expect_offense(<<~RUBY)
          foo = 1 >= bar * baz ? a : b
                ^^^^^^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (1 >= bar * baz) ? a : b
        RUBY
      end

      it 'registers an offense for addition expression' do
        expect_offense(<<~RUBY)
          foo = bar + baz ? a : b
                ^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar + baz) ? a : b
        RUBY
      end

      it 'registers an offense for subtraction expression' do
        expect_offense(<<~RUBY)
          foo = bar - baz ? a : b
                ^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar - baz) ? a : b
        RUBY
      end

      it 'registers an offense for comparison' do
        expect_offense(<<~RUBY)
          foo = bar < baz ? a : b
                ^^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = (bar < baz) ? a : b
        RUBY
      end
    end

    context 'with an assignment condition' do
      it 'registers an offense for equality check' do
        expect_offense(<<~RUBY)
          foo = bar = baz == 1 ? a : b
                      ^^^^^^^^^^^^^^^^ Use parentheses for ternary expressions with complex conditions.
        RUBY

        expect_correction(<<~RUBY)
          foo = bar = (baz == 1) ? a : b
        RUBY
      end

      it 'accepts safe assignment' do
        expect_no_offenses('foo = (bar = baz == 1) ? a : b')
      end
    end
  end
end
