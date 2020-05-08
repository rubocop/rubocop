# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NoReturnInBeginEndBlocks do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<~RUBY)
      def bad_method
        @bad_method ||= begin
          return "odd number" if rand(1..2).odd?
          ^^^^^^^^^^^^^^^^^^^ Do not `return` in `begin..end` blocks in assignment contexts.

          "even number"
        end
      end
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<~RUBY)
      def good_method
        @good_method ||= begin
          if rand(1..2).odd?
            "odd number"
          else
            "even number"
          end
        end
      end
    RUBY
  end
end
