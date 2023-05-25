# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RedundantSafeNavigation, :config do
  let(:cop_config) { { 'AllowedMethods' => %w[respond_to?] } }

  it 'registers an offense and corrects when `&.` is used inside `if` condition' do
    expect_offense(<<~RUBY)
      if foo&.respond_to?(:bar)
            ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
        do_something
      elsif foo&.respond_to?(:baz)
               ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
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
                             ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
    RUBY

    expect_correction(<<~RUBY)
      do_something unless foo.respond_to?(:bar)
    RUBY
  end

  %i[while until].each do |loop_type|
    it 'registers an offense and corrects when `&.` is used inside `#{loop_type}` condition' do
      expect_offense(<<~RUBY, loop_type: loop_type)
        %{loop_type} foo&.respond_to?(:bar)
        _{loop_type}    ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
          do_something
        end

        begin
          do_something
        end %{loop_type} foo&.respond_to?(:bar)
            _{loop_type}    ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
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
                         ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
                                                    ^^^^^^^^^^^^^^^^^^^ Redundant safe navigation detected.
    RUBY

    expect_correction(<<~RUBY)
      do_something if foo.respond_to?(:bar) && !foo.respond_to?(:baz)
    RUBY
  end

  it 'registers an offense and corrects when `&.` is used for `to_d`' do
    expect_offense(<<~RUBY)
      if foo&.to_d
            ^^^^^^ Redundant safe navigation detected.
        do_something_else
      end
    RUBY

    expect_correction(<<~RUBY)
      if foo.to_d
        do_something_else
      end
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
end
