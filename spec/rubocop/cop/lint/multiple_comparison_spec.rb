# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::MultipleComparison, :config do
  shared_examples 'Check to use two comparison operator' do |operator1, operator2|
    it "registers an offense for x #{operator1} y #{operator2} z" do
      expect_offense(<<~RUBY, operator1: operator1, operator2: operator2)
        x %{operator1} y %{operator2} z
        ^^^{operator1}^^^^{operator2}^^ Use the `&&` operator to compare multiple values.
      RUBY

      expect_correction(<<~RUBY)
        x #{operator1} y && y #{operator2} z
      RUBY
    end
  end

  %w[< > <= >=].repeated_permutation(2) do |operator1, operator2|
    include_examples 'Check to use two comparison operator', operator1, operator2
  end

  it 'accepts to use one compare operator' do
    expect_no_offenses('x < 1')
  end

  it 'accepts to use `&` operator' do
    expect_no_offenses('x >= y & x < z')
  end

  it 'accepts to use `|` operator' do
    expect_no_offenses('x >= y | x < z')
  end

  it 'accepts to use `^` operator' do
    expect_no_offenses('x >= y ^ x < z')
  end
end
