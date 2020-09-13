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

  def return_inside_simple_assignment_block
    <<-RUBY
      bad_method = begin
        return "odd number" if rand(1..2).odd?

        "even number"
      end
    RUBY
  end

  def return_inside_add_and_assignment_block
    <<-RUBY
      some_value = 10

      some_value += begin
        return 1 if rand(1..2).odd?

        2
      end
    RUBY
  end

  def return_inside_subtract_and_assignment_block
    <<-RUBY
      some_value = 10

      some_value -= begin
        return 1 if rand(1..2).odd?

        2
      end
    RUBY
  end

  def return_inside_multiply_and_assignment_block
    <<-RUBY
      some_value = 10

      some_value *= begin
        return 1 if rand(1..2).odd?

        2
      end
    RUBY
  end

  def return_inside_divide_and_assignment_block
    <<-RUBY
      some_value = 10

      some_value /= begin
        return 1 if rand(1..2).odd?

        2
      end
    RUBY
  end

  def return_inside_exponent_and_assignment_block
    <<-RUBY
      some_value = 10

      some_value **= begin
        return 1 if rand(1..2).odd?

        2
      end
    RUBY
  end

  shared_examples 'accepts return inside a block' do |name, code|
    it "accepts a return statement inside a block when using #{name}" do
      expect_no_offenses(send(code))
    end
  end

  [
    ['simple assignment', 'return_inside_simple_assignment_block'],
    ['add and assignment', 'return_inside_add_and_assignment_block'],
    ['subtract and assignment', 'return_inside_subtract_and_assignment_block'],
    ['multiply and assignment', 'return_inside_multiply_and_assignment_block'],
    ['divide and assignment', 'return_inside_divide_and_assignment_block'],
    ['exponent and assignment', 'return_inside_exponent_and_assignment_block']
  ].each do |name, code|
    include_examples 'accepts return inside a block', name, code
  end

  shared_examples 'rejects return inside a block' do |name, code|
    it "rejects a return statement inside a block when using #{name}" do
      expect_offense(send(code))
    end
  end

  context 'when return is used inside an or assignment block' do
    it 'registers an offense' do
      inspect_source(return_inside_or_assignment_block)
      expect(cop.offenses.size).to eq(1)
      expect(cop.highlights).to eq(['return "odd number"'])
    end
  end

  context 'when no return is used inside an or assignment block' do
    it 'does not register an offense' do
      expect_no_offenses(no_return_inside_or_assignment_block)
    end
  end
end
