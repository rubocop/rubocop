# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UselessComparison do
  subject(:cop) { described_class.new }

  described_class::OPS.each do |op|
    it "registers an offense for a simple comparison with #{op}" do
      expect_offense(<<~RUBY, op: op)
        5 %{op} 5
          ^{op} Comparison of something with itself detected.
        a %{op} a
          ^{op} Comparison of something with itself detected.
      RUBY
    end

    it "registers an offense for a complex comparison with #{op}" do
      expect_offense(<<~RUBY, op: op)
        5 + 10 * 30 %{op} 5 + 10 * 30
                    ^{op} Comparison of something with itself detected.
        a.top(x) %{op} a.top(x)
                 ^{op} Comparison of something with itself detected.
      RUBY
    end
  end

  it 'works with lambda.()' do
    expect_offense(<<~RUBY)
      a.(x) > a.(x)
            ^ Comparison of something with itself detected.
    RUBY
  end
end
