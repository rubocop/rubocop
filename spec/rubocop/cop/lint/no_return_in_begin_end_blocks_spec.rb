# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NoReturnInBeginEndBlocks do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  def return_inside_or_assignment_block
    <<-RUBY
      @bad_method ||= begin
        return "odd number" if rand(1..2).odd?

        "even number"
      end
    RUBY
  end

  def no_return_inside_or_assignment_block
    <<-RUBY
      @good_method ||= begin
        if rand(1..2).odd?
          "odd number"
        else
          "even number"
        end
      end
    RUBY
  end

  context 'when no return is used inside an or assignment block' do
    it 'does not register an offense' do
      expect_no_offenses(no_return_inside_or_assignment_block)
    end
  end

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

  shared_examples 'accetps a block with no return' do |operator|
    it "accetps a block with no return when using #{operator}" do
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

  %w[+= -= *= /= **= ||=].each do |operator|
    include_examples 'rejects return inside a block', operator
    include_examples 'accetps a block with no return', operator
  end
end
