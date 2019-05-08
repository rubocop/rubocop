# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CaseEquality do
  subject(:cop) { described_class.new }

  it 'registers an offense for ===' do
    expect_offense(<<~RUBY)
      Array === var
            ^^^ Avoid the use of the case equality operator `===`.
    RUBY
  end
end
