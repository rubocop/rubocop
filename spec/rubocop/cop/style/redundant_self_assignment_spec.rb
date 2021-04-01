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

  it 'registers an offense and corrects when assigning to attribute of `self`' do
    expect_offense(<<~RUBY)
      self.foo = foo.concat(ary)
               ^ Redundant self assignment detected. Method `concat` modifies its receiver in place.
    RUBY

    expect_correction(<<~RUBY)
      foo.concat(ary)
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

  it 'does not register an offense when assigning to attribute of `self` the result from other object' do
    expect_no_offenses(<<~RUBY)
      self.foo = bar.concat(ary)
    RUBY
  end
end
