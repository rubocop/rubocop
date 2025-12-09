# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantSafeNavigation, :config do
  let(:cop_config) do
    { 'AllowedMethods' => %w[respond_to?], 'AdditionalNilMethods' => %w[present?] }
  end

  it 'registers an offense and corrects when `&.` is used for camel case const receiver' do
    expect_offense(<<~RUBY)
      Const&.do_something
           ^^ Redundant safe navigation detected, use `.` instead.
      ConstName&.do_something
               ^^ Redundant safe navigation detected, use `.` instead.
      Const_name&.do_something # It is treated as camel case, similar to the `Naming/ConstantName` cop.
                ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      Const.do_something
      ConstName.do_something
      Const_name.do_something # It is treated as camel case, similar to the `Naming/ConstantName` cop.
    RUBY
  end

  it 'does not register an offense when `&.` is used for snake case const receiver' do
    expect_no_offenses(<<~RUBY)
      CONST&.do_something
      CONST_NAME&.do_something
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used for namespaced camel case const receiver' do
    expect_offense(<<~RUBY)
      FOO::Const&.do_something
                ^^ Redundant safe navigation detected, use `.` instead.
      bar::ConstName&.do_something
                    ^^ Redundant safe navigation detected, use `.` instead.
      BAZ::Const_name&.do_something # It is treated as camel case, similar to the `Naming/ConstantName` cop.
                     ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      FOO::Const.do_something
      bar::ConstName.do_something
      BAZ::Const_name.do_something # It is treated as camel case, similar to the `Naming/ConstantName` cop.
    RUBY
  end

  it 'does not register an offense when `&.` is used for namespaced snake case const receiver' do
    expect_no_offenses(<<~RUBY)
      FOO::CONST&.do_something
      bar::CONST_NAME&.do_something
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used inside `if` condition' do
    expect_offense(<<~RUBY)
      if foo&.respond_to?(:bar)
            ^^ Redundant safe navigation detected, use `.` instead.
        do_something
      elsif foo&.respond_to?(:baz)
               ^^ Redundant safe navigation detected, use `.` instead.
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo.respond_to?(:bar)
        do_something
      elsif foo.respond_to?(:baz)
        do_something_else
      end
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used inside `unless` condition' do
    expect_offense(<<~RUBY)
      do_something unless foo&.respond_to?(:bar)
                             ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      do_something unless foo.respond_to?(:bar)
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used for string literals' do
    expect_offense(<<~RUBY)
      '2012-03-02 16:05:37'&.to_time
                           ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      '2012-03-02 16:05:37'.to_time
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used for integer literals' do
    expect_offense(<<~RUBY)
      42&.minutes
        ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      42.minutes
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used for array literals' do
    expect_offense(<<~RUBY)
      [1, 2, 3]&.join(', ')
               ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      [1, 2, 3].join(', ')
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used for hash literals' do
    expect_offense(<<~RUBY)
      {k: :v}&.count
             ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      {k: :v}.count
    RUBY
  end

  it 'does not register an offense when `&.` is used for `nil` literal' do
    expect_no_offenses(<<~RUBY)
      nil&.to_i
    RUBY
  end

  it 'registers an offense and correct when `&.` is used with `self`' do
    expect_offense(<<~RUBY)
      self&.foo
          ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      self.foo
    RUBY
  end

  %i[while until].each do |loop_type|
    it 'registers an offense and corrects when `&.` is used inside `#{loop_type}` condition' do
      expect_offense(<<~RUBY, loop_type: loop_type)
        %{loop_type} foo&.respond_to?(:bar)
        _{loop_type}    ^^ Redundant safe navigation detected, use `.` instead.
          do_something
        end

        begin
          do_something
        end %{loop_type} foo&.respond_to?(:bar)
            _{loop_type}    ^^ Redundant safe navigation detected, use `.` instead.
      RUBY

      expect_correction(<<~RUBY)
        #{loop_type} foo.respond_to?(:bar)
          do_something
        end

        begin
          do_something
        end #{loop_type} foo.respond_to?(:bar)
      RUBY
    end
  end

  it 'registers an offense and corrects when `&.` is used inside complex condition' do
    expect_offense(<<~RUBY)
      do_something if foo&.respond_to?(:bar) && !foo&.respond_to?(:baz)
                         ^^ Redundant safe navigation detected, use `.` instead.
                                                    ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      do_something if foo.respond_to?(:bar) && !foo.respond_to?(:baz)
    RUBY
  end

  it 'does not register an offense when using `&.` outside of conditions' do
    expect_no_offenses(<<~RUBY)
      foo&.respond_to?(:bar)

      if condition
        foo&.respond_to?(:bar)
      end
    RUBY
  end

  it 'does not register an offense when using `&.` with non-allowed method in condition' do
    expect_no_offenses(<<~RUBY)
      do_something if foo&.bar?
    RUBY
  end

  it 'does not register an offense when using `&.respond_to?` with `nil` specific method as argument in condition' do
    expect_no_offenses(<<~RUBY)
      do_something if foo&.respond_to?(:to_a)
    RUBY
  end

  it 'does not register an offense when `&.` is used with coercion methods' do
    expect_no_offenses(<<~RUBY)
      foo&.to_s || 'Default string'
      foo&.to_i || 1
      do_something if foo&.to_d
    RUBY
  end

  it 'registers an offense and corrects when `.&` is used in `.to_h` conversion with default' do
    expect_offense(<<~RUBY)
      foo&.to_h || {}
         ^^^^^^^^^^^^ Redundant safe navigation with default literal detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_h
    RUBY
  end

  it 'registers an offense and corrects when `.&` is used in `.to_h` conversion having block with default' do
    expect_offense(<<~RUBY)
      foo&.to_h { |k, v| [k, v] } || {}
         ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Redundant safe navigation with default literal detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_h { |k, v| [k, v] }
    RUBY
  end

  it 'does not register an offense when `.&` is used in `.to_h` conversion with incorrect default' do
    expect_no_offenses(<<~RUBY)
      foo&.to_h || { a: 1 }
    RUBY
  end

  it 'registers an offense and corrects when `.&` is used in `.to_a` conversion with default' do
    expect_offense(<<~RUBY)
      foo&.to_a || []
         ^^^^^^^^^^^^ Redundant safe navigation with default literal detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_a
    RUBY
  end

  it 'does not register an offense when `.&` is used in `.to_a` conversion with incorrect default' do
    expect_no_offenses(<<~RUBY)
      foo&.to_a || [1]
    RUBY
  end

  it 'registers an offense and corrects when `.&` is used in `.to_i` conversion with default' do
    expect_offense(<<~RUBY)
      foo&.to_i || 0
         ^^^^^^^^^^^ Redundant safe navigation with default literal detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_i
    RUBY
  end

  it 'does not register an offense when `.&` is used in `.to_i` conversion with incorrect default' do
    expect_no_offenses(<<~RUBY)
      foo&.to_i || 1
    RUBY
  end

  it 'registers an offense and corrects when `.&` is used in `.to_f` conversion with default' do
    expect_offense(<<~RUBY)
      foo&.to_f || 0.0
         ^^^^^^^^^^^^^ Redundant safe navigation with default literal detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_f
    RUBY
  end

  it 'does not register an offense when `.&` is used in `.to_f` conversion with incorrect default' do
    expect_no_offenses(<<~RUBY)
      foo&.to_f || 1.0
    RUBY
  end

  it 'registers an offense and corrects when `.&` is used in `.to_s` conversion with default' do
    expect_offense(<<~RUBY)
      foo&.to_s || ''
         ^^^^^^^^^^^^ Redundant safe navigation with default literal detected.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_s
    RUBY
  end

  it 'does not register an offense when `.&` is used in `.to_s` conversion with incorrect default' do
    expect_no_offenses(<<~RUBY)
      foo&.to_s || 'default'
    RUBY
  end

  context 'when InferNonNilReceiver is disabled' do
    let(:cop_config) { { 'InferNonNilReceiver' => false } }

    it 'does not register an offense when method is called on receiver on preceding line' do
      expect_no_offenses(<<~RUBY)
        foo.bar
        foo&.baz
      RUBY
    end
  end

  context 'when InferNonNilReceiver is enabled' do
    let(:cop_config) { { 'InferNonNilReceiver' => true } }

    it 'registers an offense and corrects when method is called on receiver on preceding line' do
      expect_offense(<<~RUBY)
        foo.bar
        foo&.baz
           ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
      RUBY

      expect_correction(<<~RUBY)
        foo.bar
        foo.baz
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver on preceding line and is a method argument' do
      expect_offense(<<~RUBY)
        zoo(1, foo.bar, 2)
        foo&.baz
           ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
      RUBY

      expect_correction(<<~RUBY)
        zoo(1, foo.bar, 2)
        foo.baz
      RUBY
    end

    it 'registers an offense and corrects when method is called on a receiver in a condition' do
      expect_offense(<<~RUBY)
        if foo.condition?
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo.condition?
          foo.bar
        end
      RUBY
    end

    it 'registers an offense and corrects when method receiver is a sole condition of parent `if`' do
      expect_offense(<<~RUBY)
        if foo
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        else
          foo&.baz
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo
          foo.bar
        else
          foo&.baz
        end
      RUBY
    end

    it 'registers an offense and corrects when method receiver is a sole condition of parent `elsif`' do
      expect_offense(<<~RUBY)
        if condition?
          1
        elsif foo
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        else
          foo&.baz
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition?
          1
        elsif foo
          foo.bar
        else
          foo&.baz
        end
      RUBY
    end

    it 'registers an offense and corrects when method receiver is a sole condition of parent ternary' do
      expect_offense(<<~RUBY)
        foo ? foo&.bar : foo&.baz
                 ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
      RUBY

      expect_correction(<<~RUBY)
        foo ? foo.bar : foo&.baz
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver in lhs of condition' do
      expect_offense(<<~RUBY)
        if foo.condition? && other_condition
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo.condition? && other_condition
          foo.bar
        end
      RUBY
    end

    it 'does not register an offense when method is called on receiver in rhs of condition' do
      expect_no_offenses(<<~RUBY)
        if other_condition && foo.condition?
          foo&.bar
        end
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver in `if` condition of if/else' do
      expect_offense(<<~RUBY)
        if foo.condition?
          1
        else
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        end
      RUBY

      expect_correction(<<~RUBY)
        if foo.condition?
          1
        else
          foo.bar
        end
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver in `elsif`' do
      expect_offense(<<~RUBY)
        if condition?
          1
        elsif foo.condition?
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        end
      RUBY

      expect_correction(<<~RUBY)
        if condition?
          1
        elsif foo.condition?
          foo.bar
        end
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver in condition of ternary' do
      expect_offense(<<~RUBY)
        foo.condition? ? foo&.bar : foo&.baz
                            ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
                                       ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
      RUBY

      expect_correction(<<~RUBY)
        foo.condition? ? foo.bar : foo.baz
      RUBY
    end

    it 'does not register an offense when method is called on receiver further in the condition' do
      expect_no_offenses(<<~RUBY)
        if condition1? && (foo.condition? || condition2?)
          foo&.bar
        end
      RUBY
    end

    it 'does not register an offense when method is called on receiver in a previous branch body' do
      expect_no_offenses(<<~RUBY)
        if condition?
          foo.bar
        elsif foo&.bar?
          2
        end
      RUBY
    end

    it 'does not register an offense when receiver is a sole condition in a previous `if`' do
      expect_no_offenses(<<~RUBY)
        if foo
          do_something
        end

        foo&.bar
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver on preceding line in array literal' do
      expect_offense(<<~RUBY)
        [
          foo.bar,
          foo&.baz
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        ]
      RUBY

      expect_correction(<<~RUBY)
        [
          foo.bar,
          foo.baz
        ]
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver on preceding line in hash literal' do
      expect_offense(<<~RUBY)
        {
          bar: foo.bar,
          baz: foo&.baz,
                  ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
          foo&.zoo => 3
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          bar: foo.bar,
          baz: foo.baz,
          foo.zoo => 3
        }
      RUBY
    end

    it 'does not register an offense when `nil`s method is called on receiver' do
      expect_no_offenses(<<~RUBY)
        if foo.nil?
          foo&.bar
        end
      RUBY
    end

    it 'does not register an offense when calling custom nil method' do
      expect_no_offenses(<<~RUBY)
        foo.present?
        foo&.bar
      RUBY
    end

    it 'registers an offense and corrects when receiver is a `case` condition' do
      expect_offense(<<~RUBY)
        case foo.condition
        when 1
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        when foo&.baz
                ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
          2
        else
          foo&.zoo
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        end
      RUBY

      expect_correction(<<~RUBY)
        case foo.condition
        when 1
          foo.bar
        when foo.baz
          2
        else
          foo.zoo
        end
      RUBY
    end

    it 'does not register an offense when method is called on receiver in another branch' do
      expect_no_offenses(<<~RUBY)
        case
        when 1
          foo.bar
        when 2
          foo&.baz
        else
          foo&.zoo
        end
      RUBY
    end

    it 'registers an offense and corrects when method is called on receiver in a branch condition' do
      expect_offense(<<~RUBY)
        case
        when 1
          2
        when foo.bar
          foo&.bar
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        else
          foo&.baz
             ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        end
      RUBY

      expect_correction(<<~RUBY)
        case
        when 1
          2
        when foo.bar
          foo.bar
        else
          foo.baz
        end
      RUBY
    end

    it 'registers an offense and corrects when method is called in preceding line in assignment with `||`' do
      expect_offense(<<~RUBY)
        x = foo.bar || true
        foo&.baz
           ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
      RUBY

      expect_correction(<<~RUBY)
        x = foo.bar || true
        foo.baz
      RUBY
    end

    it 'registers an offense and corrects when method is called in preceding line in assignment' do
      expect_offense(<<~RUBY)
        CONST = foo.bar
        foo&.baz
           ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
      RUBY

      expect_correction(<<~RUBY)
        CONST = foo.bar
        foo.baz
      RUBY
    end

    it 'ignores offenses outside of the method definition scope' do
      expect_no_offenses(<<~RUBY)
        foo.bar

        def x
          foo&.bar
        end
      RUBY
    end

    it 'ignores offenses outside of the singleton method definition scope' do
      expect_no_offenses(<<~RUBY)
        foo.bar

        def self.x
          foo&.bar
        end
      RUBY
    end

    it 'correctly detects and corrects complex cases' do
      expect_offense(<<~RUBY)
        x = 1 && foo.bar

        if true
          foo&.bar
        elsif (foo.bar)
          call(1, 2, 3 + foo&.baz)
                            ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
        else
          case
          when 1, foo&.bar
                     ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
            [
              1,
              {
                2 => 3,
                foo&.baz => 4,
                   ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
                4 => -foo&.zoo
                         ^^ Redundant safe navigation on non-nil receiver (detected by analyzing previous code/method invocations).
              }
            ]
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        x = 1 && foo.bar

        if true
          foo&.bar
        elsif (foo.bar)
          call(1, 2, 3 + foo.baz)
        else
          case
          when 1, foo.bar
            [
              1,
              {
                2 => 3,
                foo.baz => 4,
                4 => -foo.zoo
              }
            ]
          end
        end
      RUBY
    end
  end

  it 'registers an offense when `&.` is used for `to_s`' do
    expect_offense(<<~RUBY)
      foo.to_s&.strip
              ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_s.strip
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_s` with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_s&.zero?
    RUBY
  end

  it 'registers an offense when `&.` is used for `to_i`' do
    expect_offense(<<~RUBY)
      foo.to_i&.zero?
              ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_i.zero?
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_i` with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_i&.zero?
    RUBY
  end

  it 'registers an offense when `&.` is used for `to_f`' do
    expect_offense(<<~RUBY)
      foo.to_f&.zero?
              ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_f.zero?
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_f` with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_f&.zero?
    RUBY
  end

  it 'registers an offense when `&.` is used for `to_a`' do
    expect_offense(<<~RUBY)
      foo.to_a&.size
              ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_a.size
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_a` with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_a&.zero?
    RUBY
  end

  it 'registers an offense when `&.` is used for `to_h`' do
    expect_offense(<<~RUBY)
      foo.to_h&.size
              ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_h.size
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_h` with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_h&.zero?
    RUBY
  end

  it 'registers an offense when `&.` is used for `to_h` with block' do
    expect_offense(<<~RUBY)
      foo.to_h { |entry| do_something(entry) }&.keys
                                              ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_h { |entry| do_something(entry) }.keys
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_h { ... }` with block with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_h { |entry| do_something(entry) }&.keys
    RUBY
  end

  it 'registers an offense when `&.` is used for `to_h` with numbered block' do
    expect_offense(<<~RUBY)
      foo.to_h { do_something(_1) }&.keys
                                   ^^ Redundant safe navigation detected, use `.` instead.
    RUBY

    expect_correction(<<~RUBY)
      foo.to_h { do_something(_1) }.keys
    RUBY
  end

  it 'does not register an offense when `&.` is used for `to_h { ... }` with numbered block with safe navigation' do
    expect_no_offenses(<<~RUBY)
      foo&.to_h { do_something(_1) }&.keys
    RUBY
  end
end
