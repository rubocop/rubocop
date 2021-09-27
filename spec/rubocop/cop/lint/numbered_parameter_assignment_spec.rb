# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::NumberedParameterAssignment, :config do
  # NOTE: Assigning to numbered parameter (from `_1` to `_9`) cause an error in Ruby 3.0.
  context 'when Ruby 2.7 or lower', :ruby27 do
    (1..9).to_a.each do |number|
      it "registers an offense when using `_#{number}` numbered parameter" do
        expect_offense(<<~RUBY)
          _#{number} = :value
          ^^^^^^^^^^^ `_#{number}` is reserved for numbered parameter; consider another name.
        RUBY
      end
    end
  end

  it 'registers an offense when using `_0` lvar' do
    expect_offense(<<~RUBY)
      _0 = :value
      ^^^^^^^^^^^ `_0` is similar to numbered parameter; consider another name.
    RUBY
  end

  it 'registers an offense when using `_10` lvar' do
    expect_offense(<<~RUBY)
      _10 = :value
      ^^^^^^^^^^^^ `_10` is similar to numbered parameter; consider another name.
    RUBY
  end

  it 'does not register an offense when using non numbered parameter' do
    expect_no_offenses(<<~RUBY)
      non_numbered_parameter_name = :value
    RUBY
  end

  it 'does not register an offense when index assignment' do
    expect_no_offenses(<<~RUBY)
      Hash.new { _1[_2] = :value }
    RUBY
  end
end
