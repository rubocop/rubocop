# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NoReturnInBeginEndBlocks, :config do
  shared_examples 'rejects return inside a block' do |operator|
    it "rejects a return statement inside a block when using #{operator}" do
      expect_offense(<<-RUBY)
        some_value = 10

        some_value #{operator} begin
          return 1 if rand(1..2).odd?
          ^^^^^^^^ Do not `return` in `begin..end` blocks in assignment contexts.
          2
        end
      RUBY
    end
  end

  shared_examples 'accepts a block with no return' do |operator|
    it "accepts a block with no return when using #{operator}" do
      expect_no_offenses(<<-RUBY)
        @good_method #{operator} begin
          if rand(1..2).odd?
            "odd number"
          else
            "even number"
          end
        end
      RUBY
    end
  end

  %w[= += -= *= /= **= ||=].each do |operator|
    include_examples 'rejects return inside a block', operator
    include_examples 'accepts a block with no return', operator
  end
end
