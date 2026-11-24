# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSelfAssignment, :config do
  context 'when lhs and receiver are the same' do
    it 'registers an offense and corrects when assigning to local variable' do
      expect_offense(<<~RUBY)
        foo = foo.concat(ary)
            ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
      RUBY

      expect_correction(<<~RUBY)
        foo.concat(ary)
      RUBY
    end

    it 'registers an offense and corrects when assigning to instance variable' do
      expect_offense(<<~RUBY)
        @foo = @foo.concat(ary)
             ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
      RUBY

      expect_correction(<<~RUBY)
        @foo.concat(ary)
      RUBY
    end

    it 'does not remove a heredoc body before the right-hand side' do
      expect_offense(<<~RUBY)
        emit(<<~TEXT, @items =
                             ^ Redundant self assignment detected. Method `clear` modifies its receiver in place.
          hello
        TEXT
          @items.clear)
      RUBY

      expect_no_corrections
    end

    it 'corrects a multiline assignment with no intervening code' do
      expect_offense(<<~RUBY)
        @items =
               ^ Redundant self assignment detected. Method `clear` modifies its receiver in place.
          @items.clear
      RUBY

      expect_correction(<<~RUBY)
        @items.clear
      RUBY
    end

    it 'registers an offense and corrects when assigning to class variable' do
      expect_offense(<<~RUBY)
        @@foo = @@foo.concat(ary)
              ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
      RUBY

      expect_correction(<<~RUBY)
        @@foo.concat(ary)
      RUBY
    end

    it 'registers an offense and corrects when assigning to global variable' do
      expect_offense(<<~RUBY)
        $foo = $foo.concat(ary)
             ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
      RUBY

      expect_correction(<<~RUBY)
        $foo.concat(ary)
      RUBY
    end

    it 'registers an offense and corrects when the rhs uses safe navigation' do
      expect_offense(<<~RUBY)
        foo = foo&.concat(ary)
            ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
      RUBY

      expect_correction(<<~RUBY)
        foo&.concat(ary)
      RUBY
    end

    it 'registers an offense and corrects when the rhs receives a block' do
      expect_offense(<<~RUBY)
        foo = foo.delete_if { true }
            ^ Redundant self assignment detected. Method `delete_if` modifies its receiver in place.
      RUBY

      expect_correction(<<~RUBY)
        foo.delete_if { true }
      RUBY
    end
  end

  it 'does not register an offense when lhs and receiver are different' do
    expect_no_offenses(<<~RUBY)
      foo = bar.concat(ary)
    RUBY
  end

  it 'does not register an offense when there is no a receiver' do
    expect_no_offenses(<<~RUBY)
      foo = concat(ary)
    RUBY
  end

  it 'does not register an offense when assigning to attribute of `self`' do
    expect_no_offenses(<<~RUBY)
      self.foo = foo.concat(ary)
    RUBY
  end

  it 'does not register an offense when assigning to attribute of `self` with safe navigation' do
    expect_no_offenses(<<~RUBY)
      self.foo = foo&.concat(ary)
    RUBY
  end

  it 'registers an offense and corrects when assigning to attribute of non `self`' do
    expect_offense(<<~RUBY)
      other.foo = other.foo.concat(ary)
                ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
    RUBY

    expect_correction(<<~RUBY)
      other.foo.concat(ary)
    RUBY
  end

  it 'does not remove a heredoc opener from an attribute receiver' do
    expect_offense(<<~RUBY)
      box(<<~A).items = box(<<~B).items.clear
                      ^ Redundant self assignment detected. Method `clear` modifies its receiver in place.
        key
      A
        key
      B
    RUBY

    expect_no_corrections
  end

  it 'does not remove a comment after an attribute assignment operator' do
    expect_offense(<<~RUBY)
      other.items = # keep
                  ^ Redundant self assignment detected. Method `clear` modifies its receiver in place.
        other.items.clear
    RUBY

    expect_no_corrections
  end

  it 'registers an offense and corrects when assigning to attribute of non `self` with safe assignment' do
    expect_offense(<<~RUBY)
      other.foo = other.foo&.concat(ary)
                ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
    RUBY

    expect_correction(<<~RUBY)
      other.foo&.concat(ary)
    RUBY
  end

  it 'registers an offense and corrects when assigning to attribute of non `self` with safe assignment chain' do
    expect_offense(<<~RUBY)
      other&.foo = other&.foo&.concat(ary)
                 ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
    RUBY

    expect_correction(<<~RUBY)
      other&.foo&.concat(ary)
    RUBY
  end

  it 'does not register an offense when assigning to attribute of `self` the result from other object' do
    expect_no_offenses(<<~RUBY)
      self.foo = bar.concat(ary)
    RUBY
  end
end
