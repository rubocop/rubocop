# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SuperWithArgsParentheses, :config do
  it 'registers an offense when using `super` without parenthesized arguments' do
    expect_offense(<<~RUBY)
      super name, age
      ^^^^^^^^^^^^^^^ Use parentheses for `super` with arguments.
    RUBY

    expect_correction(<<~RUBY)
      super(name, age)
    RUBY
  end

  it 'accepts a super call with a do-end block inside the arguments of a command call' do
    expect_no_offenses(<<~RUBY)
      emit flag, if ready?
        super arg do
        end
      end
    RUBY
  end

  it 'corrects a super call with a do-end block when the outer call has parentheses' do
    expect_offense(<<~RUBY)
      emit(flag, if ready?
        super arg do
        ^^^^^^^^^ Use parentheses for `super` with arguments.
        end
      end)
    RUBY

    expect_correction(<<~RUBY)
      emit(flag, if ready?
        super(arg) do
        end
      end)
    RUBY
  end

  it 'does not register an offense when using `super` with parenthesized arguments' do
    expect_no_offenses(<<~RUBY)
      super(name, age)
    RUBY
  end

  it 'does not register an offense when using `super` without arguments' do
    expect_no_offenses(<<~RUBY)
      super()
    RUBY
  end

  it 'does not register an offense when using zero arity `super`' do
    expect_no_offenses(<<~RUBY)
      super
    RUBY
  end
end
