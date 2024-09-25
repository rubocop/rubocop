# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantSafeNavigation, :config do
  let(:cop_config) { { 'AllowedMethods' => %w[respond_to?] } }

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
end
