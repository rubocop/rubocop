# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EndInMethod do
  subject(:cop) { described_class.new }

  it 'registers an offense for def with an END inside' do
    expect_offense(<<~RUBY)
      def test
        END { something }
        ^^^ `END` found in method definition. Use `at_exit` instead.
      end
    RUBY
  end

  it 'registers an offense for defs with an END inside' do
    expect_offense(<<~RUBY)
      def self.test
        END { something }
        ^^^ `END` found in method definition. Use `at_exit` instead.
      end
    RUBY
  end

  it 'accepts END outside of def(s)' do
    expect_no_offenses('END { something }')
  end
end
