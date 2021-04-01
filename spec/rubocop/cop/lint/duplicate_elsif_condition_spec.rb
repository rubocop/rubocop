# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::DuplicateElsifCondition, :config do
  it 'registers an offense for repeated elsif conditions' do
    expect_offense(<<~RUBY)
      if x == 1
      elsif x == 2
      elsif x == 1
            ^^^^^^ Duplicate `elsif` condition detected.
      end
    RUBY
  end

  it 'registers an offense for subsequent repeated elsif conditions' do
    expect_offense(<<~RUBY)
      if x == 1
      elsif x == 2
      elsif x == 2
            ^^^^^^ Duplicate `elsif` condition detected.
      end
    RUBY
  end

  it 'registers multiple offenses for multiple repeated elsif conditions' do
    expect_offense(<<~RUBY)
      if x == 1
      elsif x == 2
      elsif x == 1
            ^^^^^^ Duplicate `elsif` condition detected.
      elsif x == 2
            ^^^^^^ Duplicate `elsif` condition detected.
      end
    RUBY
  end

  it 'does not register an offense for non-repeated elsif conditions' do
    expect_no_offenses(<<~RUBY)
      if x == 1
      elsif x == 2
      else
      end
    RUBY
  end

  it 'does not register an offense for partially repeated elsif conditions' do
    expect_no_offenses(<<~RUBY)
      if x == 1
      elsif x == 1 && x == 2
      end
    RUBY
  end
end
