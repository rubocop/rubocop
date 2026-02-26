# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EachWithObjectArgument, :config do
  it 'registers an offense for fixnum argument' do
    expect_offense(<<~RUBY)
      collection.each_with_object(0) { |e, a| a + e }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object cannot be immutable.
    RUBY
  end

  it 'registers an offense for float argument' do
    expect_offense(<<~RUBY)
      collection.each_with_object(0.1) { |e, a| a + e }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object cannot be immutable.
    RUBY
  end

  it 'registers an offense for bignum argument' do
    expect_offense(<<~RUBY)
      c.each_with_object(100000000000000000000) { |e, o| o + e }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object cannot be immutable.
    RUBY
  end

  it 'accepts a variable argument' do
    expect_no_offenses('collection.each_with_object(x) { |e, a| a.add(e) }')
  end

  it 'accepts two arguments' do
    # Two arguments would indicate that this is not Enumerable#each_with_object.
    expect_no_offenses('collection.each_with_object(1, 2) { |e, a| a.add(e) }')
  end

  it 'accepts a string argument' do
    expect_no_offenses("collection.each_with_object('') { |e, a| a << e.to_s }")
  end

  context 'when using safe navigation operator' do
    it 'registers an offense for fixnum argument' do
      expect_offense(<<~RUBY)
        collection&.each_with_object(0) { |e, a| a + e }
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ The argument to each_with_object cannot be immutable.
      RUBY
    end
  end
end
