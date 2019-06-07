# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NoArrayOfRange do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when creating a single range in an array without parens' do
    expect_offense(<<~RUBY)
          [1..10]
          ^^^^^^^ Use `[(1..10)]` instead of `[1..10]` to create an array of a single range. Or you want just a range: `(1..10)`.
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      [(1..10)]
    RUBY
  end
end
