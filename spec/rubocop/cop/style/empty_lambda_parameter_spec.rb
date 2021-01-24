# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::EmptyLambdaParameter, :config do
  it 'registers an offense for an empty block parameter with a lambda' do
    expect_offense(<<~RUBY)
      -> () { do_something }
         ^^ Omit parentheses for the empty lambda parameters.
    RUBY

    expect_correction(<<~RUBY)
      -> { do_something }
    RUBY
  end

  it 'accepts a keyword lambda' do
    expect_no_offenses(<<-RUBY)
      lambda { || do_something }
    RUBY
  end

  it 'does not crash on a super' do
    expect_no_offenses(<<-RUBY)
      def foo
        super { || do_something }
      end
    RUBY
  end
end
