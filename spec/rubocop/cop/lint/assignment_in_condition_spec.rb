# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::AssignmentInCondition, :config do
  let(:cop_config) { { 'AllowSafeAssignment' => true } }

  it 'registers an offense for lvar assignment in condition' do
    expect_offense(<<~RUBY)
      if test = 10
              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (test = 10)
      end
    RUBY
  end

  it 'registers an offense for lvar assignment in while condition' do
    expect_offense(<<~RUBY)
      while test = 10
                 ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      while (test = 10)
      end
    RUBY
  end

  it 'registers an offense for lvar assignment in until condition' do
    expect_offense(<<~RUBY)
      until test = 10
                 ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      until (test = 10)
      end
    RUBY
  end

  it 'registers an offense for ivar assignment in condition' do
    expect_offense(<<~RUBY)
      if @test = 10
               ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (@test = 10)
      end
    RUBY
  end

  it 'registers an offense for clvar assignment in condition' do
    expect_offense(<<~RUBY)
      if @@test = 10
                ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (@@test = 10)
      end
    RUBY
  end

  it 'registers an offense for gvar assignment in condition' do
    expect_offense(<<~RUBY)
      if $test = 10
               ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if ($test = 10)
      end
    RUBY
  end

  it 'registers an offense for constant assignment in condition' do
    expect_offense(<<~RUBY)
      if TEST = 10
              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (TEST = 10)
      end
    RUBY
  end

  it 'registers an offense for collection element assignment in condition' do
    expect_offense(<<~RUBY)
      if a[3] = 10
              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (a[3] = 10)
      end
    RUBY
  end

  it 'accepts == in condition' do
    expect_no_offenses(<<~RUBY)
      if test == 10
      end
    RUBY
  end

  it 'registers an offense for assignment after == in condition' do
    expect_offense(<<~RUBY)
      if test == 10 || foobar = 1
                              ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if test == 10 || (foobar = 1)
      end
    RUBY
  end

  it 'accepts = in a block that is called in a condition' do
    expect_no_offenses('return 1 if any_errors? { o = inspect(file) }')
  end

  it 'accepts = in a block followed by method call' do
    expect_no_offenses('return 1 if any_errors? { o = file }.present?')
  end

  it 'accepts = in a numblock that is called in a condition' do
    expect_no_offenses('return 1 if any_errors? { o = inspect(_1) }')
  end

  it 'accepts = in a numblock followed by method call' do
    expect_no_offenses('return 1 if any_errors? { o = _1 }.present?')
  end

  context 'Ruby 3.4', :ruby34 do
    it 'accepts = in an itblock that is called in a condition' do
      expect_no_offenses('return 1 if any_errors? { o = inspect(it) }')
    end

    it 'accepts = in an itblock followed by method call' do
      expect_no_offenses('return 1 if any_errors? { o = it }.present?')
    end
  end

  it 'accepts assignment in a block after ||' do
    expect_no_offenses(<<~RUBY)
      if x?(bar) || y? { z = baz }
        foo
      end
    RUBY
  end

  it 'registers an offense for = in condition inside a block' do
    expect_offense(<<~RUBY)
      foo { x if y = z }
                   ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
    RUBY

    expect_correction(<<~RUBY)
      foo { x if (y = z) }
    RUBY
  end

  it 'accepts ||= in condition' do
    expect_no_offenses('raise StandardError unless foo ||= bar')
  end

  it 'registers an offense for assignment after ||= in condition' do
    expect_offense(<<~RUBY)
      raise StandardError unless (foo ||= bar) || a = b
                                                    ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
    RUBY

    expect_correction(<<~RUBY)
      raise StandardError unless (foo ||= bar) || (a = b)
    RUBY
  end

  it 'registers an offense for assignment methods' do
    expect_offense(<<~RUBY)
      if test.method = 10
                     ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (test.method = 10)
      end
    RUBY
  end

  it 'registers an offense for assignment methods with safe navigation operator' do
    expect_offense(<<~RUBY)
      if test&.method = 10
                      ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
      end
    RUBY

    expect_correction(<<~RUBY)
      if (test&.method = 10)
      end
    RUBY
  end

  it 'does not blow up for empty if condition' do
    expect_no_offenses(<<~RUBY)
      if ()
      end
    RUBY
  end

  it 'does not blow up for empty unless condition' do
    expect_no_offenses(<<~RUBY)
      unless ()
      end
    RUBY
  end

  it 'does not register an offense for assignment in method call' do
    expect_no_offenses(<<~RUBY)
      return unless %i[asc desc].include?(order = params[:order])
    RUBY
  end

  context 'safe assignment is allowed' do
    it 'accepts = in condition surrounded with braces' do
      expect_no_offenses(<<~RUBY)
        if (test = 10)
        end
      RUBY
    end

    it 'accepts []= in condition surrounded with braces' do
      expect_no_offenses(<<~RUBY)
        if (test[0] = 10)
        end
      RUBY
    end

    %i[&& ||].each do |operator|
      context "with an unparenthesized assignment inside a parenthesized #{operator} statement" do
        %i[if while until].each do |keyword|
          context "inside an #{keyword} statement" do
            it 'registers an offense and corrects' do
              expect_offense(<<~RUBY, keyword: keyword, operator: operator)
                %{keyword} (foo == bar %{operator} test = 10)
                _{keyword}             _{operator}      ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{keyword} (foo == bar #{operator} (test = 10))
                end
              RUBY
            end

            it 'registers an offense and corrects inside nested parentheses' do
              expect_offense(<<~RUBY, keyword: keyword, operator: operator)
                %{keyword} ((foo == bar %{operator} test = 10))
                _{keyword}              _{operator}      ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
                end
              RUBY

              expect_correction(<<~RUBY)
                #{keyword} ((foo == bar #{operator} (test = 10)))
                end
              RUBY
            end
          end

          context "inside an #{keyword} modifier" do
            it 'registers an offense and corrects' do
              expect_offense(<<~RUBY, keyword: keyword, operator: operator)
                do_something %{keyword} (foo == bar %{operator} test = 10)
                             _{keyword}             _{operator}      ^ Use `==` if you meant to do a comparison or wrap the expression in parentheses to indicate you meant to assign in a condition.
              RUBY

              expect_correction(<<~RUBY)
                do_something #{keyword} (foo == bar #{operator} (test = 10))
              RUBY
            end
          end
        end
      end

      context "with a compound assignment using #{operator} inside parentheses" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            if (test = foo #{operator} bar == baz)
            end
          RUBY
        end
      end
    end
  end

  context 'safe assignment is not allowed' do
    let(:cop_config) { { 'AllowSafeAssignment' => false } }

    it 'does not accept = in condition surrounded with braces' do
      expect_offense(<<~RUBY)
        if (test = 10)
                 ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
        end
      RUBY

      expect_no_corrections
    end

    it 'does not accept []= in condition surrounded with braces' do
      expect_offense(<<~RUBY)
        if (test[0] = 10)
                    ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
        end
      RUBY

      expect_no_corrections
    end

    %i[&& ||].each do |operator|
      context "with an unparenthesized assignment inside a parenthesized #{operator} statement" do
        %i[if while until].each do |keyword|
          context "inside an #{keyword} statement" do
            it 'registers an offense but does not correct' do
              expect_offense(<<~RUBY, keyword: keyword, operator: operator)
                %{keyword} (foo == bar %{operator} test = 10)
                _{keyword}             _{operator}      ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
                end
              RUBY

              expect_no_corrections
            end

            it 'registers an offense but does not correct inside nested parentheses' do
              expect_offense(<<~RUBY, keyword: keyword, operator: operator)
                %{keyword} ((foo == bar %{operator} test = 10))
                _{keyword}              _{operator}      ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
                end
              RUBY

              expect_no_corrections
            end
          end

          context "inside an #{keyword} modifier" do
            it 'registers an offense but does not correct' do
              expect_offense(<<~RUBY, keyword: keyword, operator: operator)
                do_something %{keyword} (foo == bar %{operator} test = 10)
                             _{keyword}             _{operator}      ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
              RUBY

              expect_no_corrections
            end
          end
        end
      end

      context "with a compound assignment using #{operator} inside parentheses" do
        it 'registers an offense but does not correct' do
          expect_offense(<<~RUBY)
            if (test = foo #{operator} bar == baz)
                     ^ Use `==` if you meant to do a comparison or move the assignment up out of the condition.
            end
          RUBY

          expect_no_corrections
        end
      end
    end
  end
end
