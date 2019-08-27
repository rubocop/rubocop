# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::UnlessWithOperator do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using operator in unless conditional' do
    expect_offense(<<~RUBY)
      return false unless false || true
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not use `unless` with operator. Split this over several lines.
    RUBY
  end

  it 'does not register an offense when using operator in unless conditional' do
    expect_no_offenses(<<~RUBY)
      return false unless false
    RUBY
  end
end
