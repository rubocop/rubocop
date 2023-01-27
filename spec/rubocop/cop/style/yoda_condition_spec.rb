# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::YodaCondition, :config do
  context 'enforce not yoda' do
    let(:cop_config) { { 'EnforcedStyle' => 'forbid_for_all_comparison_operators' } }

    it 'accepts method call on receiver on left' do
      expect_no_offenses('b.value == 2')
    end

    it 'accepts safe navigation on left' do
      expect_no_offenses('b&.value == 2')
    end

    it 'accepts instance variable on left' do
      expect_no_offenses('@value == 2')
    end

    it 'accepts class variable on left' do
      expect_no_offenses('@@value == 2')
    end

    it 'accepts variable on left after assign' do
      expect_no_offenses('b = 1; b == 2')
    end

    it 'accepts global variable on left' do
      expect_no_offenses('$var == 5')
    end

    it 'accepts string literal on right' do
      expect_no_offenses('foo == "bar"')
    end

    it 'accepts constant on right' do
      expect_no_offenses('foo == BAR')
    end

    it 'accepts interpolated string on left' do
      expect_no_offenses('"#{interpolation}" == foo')
    end

    it 'accepts interpolated regex on left' do
      expect_no_offenses('/#{interpolation}/ == foo')
    end

    it 'accepts accessor and variable on left in boolean expression' do
      expect_no_offenses('foo[0] > "bar" || baz != "baz"')
    end

    it 'accepts assignment' do
      expect_no_offenses('node = last_node.parent')
    end

    it 'accepts subtraction expression on left of comparison' do
      expect_no_offenses('(first_line - second_line) > 0')
    end

    it 'accepts number on both sides' do
      expect_no_offenses('5 == 6')
    end

    it 'accepts array of numbers on both sides' do
      expect_no_offenses('[1, 2, 3] <=> [4, 5, 6]')
    end

    it 'accepts negation' do
      expect_no_offenses('!true')
      expect_no_offenses('not true')
    end

    it 'accepts number on left of <=>' do
      expect_no_offenses('0 <=> val')
    end

    it 'accepts string literal on left of case equality check' do
      expect_no_offenses('"foo" === bar')
    end

    it 'accepts __FILE__ on left in program name check' do
      expect_no_offenses('__FILE__ == $0')
      expect_no_offenses('__FILE__ == $PROGRAM_NAME')
    end

    it 'accepts __FILE__ on left in negated program name check' do
      expect_no_offenses('__FILE__ != $0')
      expect_no_offenses('__FILE__ != $PROGRAM_NAME')
    end

    it 'registers an offense for string literal on left' do
      expect_offense(<<~RUBY)
        "foo" == bar
        ^^^^^^^^^^^^ Reverse the order of the operands `"foo" == bar`.
      RUBY

      expect_correction(<<~RUBY)
        bar == "foo"
      RUBY
    end

    it 'registers an offense for nil on left' do
      expect_offense(<<~RUBY)
        nil == bar
        ^^^^^^^^^^ Reverse the order of the operands `nil == bar`.
      RUBY

      expect_correction(<<~RUBY)
        bar == nil
      RUBY
    end

    it 'registers an offense for boolean literal on left' do
      expect_offense(<<~RUBY)
        false == active?
        ^^^^^^^^^^^^^^^^ Reverse the order of the operands `false == active?`.
      RUBY

      expect_correction(<<~RUBY)
        active? == false
      RUBY
    end

    it 'registers an offense number on left' do
      expect_offense(<<~RUBY)
        15 != @foo
        ^^^^^^^^^^ Reverse the order of the operands `15 != @foo`.
      RUBY

      expect_correction(<<~RUBY)
        @foo != 15
      RUBY
    end

    it 'registers an offense number on left of comparison' do
      expect_offense(<<~RUBY)
        42 < bar
        ^^^^^^^^ Reverse the order of the operands `42 < bar`.
      RUBY

      expect_correction(<<~RUBY)
        bar > 42
      RUBY
    end

    it 'registers an offense constant on left of comparison' do
      expect_offense(<<~RUBY)
        FOO < bar
        ^^^^^^^^^ Reverse the order of the operands `FOO < bar`.
      RUBY

      expect_correction(<<~RUBY)
        bar > FOO
      RUBY
    end

    context 'within an if or ternary statement' do
      it 'registers an offense for number on left in if condition' do
        expect_offense(<<~RUBY)
          if 10 == my_var; end
             ^^^^^^^^^^^^ Reverse the order of the operands `10 == my_var`.
        RUBY

        expect_correction(<<~RUBY)
          if my_var == 10; end
        RUBY
      end

      it 'registers an offense for number on left of comparison in if condition' do
        expect_offense(<<~RUBY)
          if 2 < bar;end
             ^^^^^^^ Reverse the order of the operands `2 < bar`.
        RUBY

        expect_correction(<<~RUBY)
          if bar > 2;end
        RUBY
      end

      it 'registers an offense for number on left in modifier if' do
        expect_offense(<<~RUBY)
          foo = 42 if 42 > bar
                      ^^^^^^^^ Reverse the order of the operands `42 > bar`.
        RUBY

        expect_correction(<<~RUBY)
          foo = 42 if bar < 42
        RUBY
      end

      it 'registers an offense for number on left of <= in ternary condition' do
        expect_offense(<<~RUBY)
          42 <= foo ? bar : baz
          ^^^^^^^^^ Reverse the order of the operands `42 <= foo`.
        RUBY

        expect_correction(<<~RUBY)
          foo >= 42 ? bar : baz
        RUBY
      end

      it 'registers an offense for number on left of >= in ternary condition' do
        expect_offense(<<~RUBY)
          42 >= foo ? bar : baz
          ^^^^^^^^^ Reverse the order of the operands `42 >= foo`.
        RUBY

        expect_correction(<<~RUBY)
          foo <= 42 ? bar : baz
        RUBY
      end

      it 'registers an offense for nil on left in ternary condition' do
        expect_offense(<<~RUBY)
          nil != foo ? bar : baz
          ^^^^^^^^^^ Reverse the order of the operands `nil != foo`.
        RUBY

        expect_correction(<<~RUBY)
          foo != nil ? bar : baz
        RUBY
      end
    end

    context 'with EnforcedStyle: forbid_for_equality_operators_only' do
      let(:cop_config) { { 'EnforcedStyle' => 'forbid_for_equality_operators_only' } }

      it 'accepts number on left of comparison' do
        expect_no_offenses('42 < bar')
      end

      it 'accepts nil on left of comparison' do
        expect_no_offenses('nil >= baz')
      end

      it 'accepts mixed order in comparisons' do
        expect_no_offenses('3 < a && a < 5')
      end

      it 'registers an offense for negated equality check' do
        expect_offense(<<~RUBY)
          42 != answer
          ^^^^^^^^^^^^ Reverse the order of the operands `42 != answer`.
        RUBY

        expect_correction(<<~RUBY)
          answer != 42
        RUBY
      end

      it 'registers an offense for equality check' do
        expect_offense(<<~RUBY)
          false == foo
          ^^^^^^^^^^^^ Reverse the order of the operands `false == foo`.
        RUBY

        expect_correction(<<~RUBY)
          foo == false
        RUBY
      end
    end
  end

  context 'enforce yoda' do
    let(:cop_config) { { 'EnforcedStyle' => 'require_for_all_comparison_operators' } }

    it 'accepts method call on receiver on right' do
      expect_no_offenses('2 == b.value')
    end

    it 'accepts safe navigation on right' do
      expect_no_offenses('2 == b&.value')
    end

    it 'accepts instance variable on right' do
      expect_no_offenses('2 == @value')
    end

    it 'accepts class variable on right' do
      expect_no_offenses('2 == @@value')
    end

    it 'accepts variable on right after assignment' do
      expect_no_offenses('b = 1; 2 == b')
    end

    it 'accepts global variable on right' do
      expect_no_offenses('5 == $var')
    end

    it 'accepts string literal on left' do
      expect_no_offenses('"bar" == foo')
    end

    it 'accepts accessor and variable on right in boolean expression' do
      expect_no_offenses('"bar" > foo[0] || "bar" != baz')
    end

    it 'accepts assignment' do
      expect_no_offenses('node = last_node.parent')
    end

    it 'accepts subtraction on right of comparison' do
      expect_no_offenses('0 < (first_line - second_line)')
    end

    it 'accepts numbers on both sides' do
      expect_no_offenses('5 == 6')
    end

    it 'accepts arrays of numbers on both sides' do
      expect_no_offenses('[1, 2, 3] <=> [4, 5, 6]')
    end

    it 'accepts negation' do
      expect_no_offenses('!true')
      expect_no_offenses('not true')
    end

    it 'accepts number on left of <=>' do
      expect_no_offenses('0 <=> val')
    end

    it 'accepts string literal on right of case equality check' do
      expect_no_offenses('bar === "foo"')
    end

    it 'registers an offense for string literal on right' do
      expect_offense(<<~RUBY)
        bar == "foo"
        ^^^^^^^^^^^^ Reverse the order of the operands `bar == "foo"`.
      RUBY

      expect_correction(<<~RUBY)
        "foo" == bar
      RUBY
    end

    it 'registers an offense for nil on right' do
      expect_offense(<<~RUBY)
        bar == nil
        ^^^^^^^^^^ Reverse the order of the operands `bar == nil`.
      RUBY

      expect_correction(<<~RUBY)
        nil == bar
      RUBY
    end

    it 'registers an offense for boolean literal on right' do
      expect_offense(<<~RUBY)
        active? == false
        ^^^^^^^^^^^^^^^^ Reverse the order of the operands `active? == false`.
      RUBY

      expect_correction(<<~RUBY)
        false == active?
      RUBY
    end

    it 'registers an offense for number on right' do
      expect_offense(<<~RUBY)
        @foo != 15
        ^^^^^^^^^^ Reverse the order of the operands `@foo != 15`.
      RUBY

      expect_correction(<<~RUBY)
        15 != @foo
      RUBY
    end

    it 'registers an offense for number on right of comparison' do
      expect_offense(<<~RUBY)
        bar > 42
        ^^^^^^^^ Reverse the order of the operands `bar > 42`.
      RUBY

      expect_correction(<<~RUBY)
        42 < bar
      RUBY
    end

    context 'within an if or ternary statement' do
      it 'registers an offense number on right in if condition' do
        expect_offense(<<~RUBY)
          if my_var == 10; end
             ^^^^^^^^^^^^ Reverse the order of the operands `my_var == 10`.
        RUBY

        expect_correction(<<~RUBY)
          if 10 == my_var; end
        RUBY
      end

      it 'registers an offense number on right of comparison in if condition' do
        expect_offense(<<~RUBY)
          if bar > 2;end
             ^^^^^^^ Reverse the order of the operands `bar > 2`.
        RUBY

        expect_correction(<<~RUBY)
          if 2 < bar;end
        RUBY
      end

      it 'registers an offense for number on right in modifier if' do
        expect_offense(<<~RUBY)
          foo = 42 if bar < 42
                      ^^^^^^^^ Reverse the order of the operands `bar < 42`.
        RUBY

        expect_correction(<<~RUBY)
          foo = 42 if 42 > bar
        RUBY
      end

      it 'registers an offense for number on right of >= in ternary condition' do
        expect_offense(<<~RUBY)
          foo >= 42 ? bar : baz
          ^^^^^^^^^ Reverse the order of the operands `foo >= 42`.
        RUBY

        expect_correction(<<~RUBY)
          42 <= foo ? bar : baz
        RUBY
      end

      it 'registers an offense for number on right of <= in ternary condition' do
        expect_offense(<<~RUBY)
          foo <= 42 ? bar : baz
          ^^^^^^^^^ Reverse the order of the operands `foo <= 42`.
        RUBY

        expect_correction(<<~RUBY)
          42 >= foo ? bar : baz
        RUBY
      end

      it 'registers an offense for nil on right in ternary condition' do
        expect_offense(<<~RUBY)
          foo != nil ? bar : baz
          ^^^^^^^^^^ Reverse the order of the operands `foo != nil`.
        RUBY

        expect_correction(<<~RUBY)
          nil != foo ? bar : baz
        RUBY
      end
    end

    context 'with EnforcedStyle: require_for_equality_operators_only' do
      let(:cop_config) { { 'EnforcedStyle' => 'require_for_equality_operators_only' } }

      it 'accepts number on right of comparison' do
        expect_no_offenses('bar > 42')
      end

      it 'accepts nil on right of comparison' do
        expect_no_offenses('bar <= nil')
      end

      it 'accepts mixed order in comparisons' do
        expect_no_offenses('a > 3 && 5 > a')
      end

      it 'registers an offense for negated equality check' do
        expect_offense(<<~RUBY)
          answer != 42
          ^^^^^^^^^^^^ Reverse the order of the operands `answer != 42`.
        RUBY

        expect_correction(<<~RUBY)
          42 != answer
        RUBY
      end

      it 'registers an offense for equality check' do
        expect_offense(<<~RUBY)
          foo == false
          ^^^^^^^^^^^^ Reverse the order of the operands `foo == false`.
        RUBY

        expect_correction(<<~RUBY)
          false == foo
        RUBY
      end
    end
  end
end
