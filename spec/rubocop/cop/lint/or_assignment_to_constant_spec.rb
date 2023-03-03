# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::OrAssignmentToConstant, :config do
  it 'registers an offense with or-assignment to a constant' do
    expect_offense(<<~RUBY)
      CONST ||= 1
            ^^^ Avoid using or-assignment with constants.
    RUBY

    expect_correction(<<~RUBY)
      CONST = 1
    RUBY
  end

  it 'registers an offense with or-assignment to a constant in method definition' do
    expect_offense(<<~RUBY)
      def foo
        M::CONST ||= 1
                 ^^^ Avoid using or-assignment with constants.
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense with or-assignment to a constant in singleton method definition' do
    expect_offense(<<~RUBY)
      def self.foo
        M::CONST ||= 1
                 ^^^ Avoid using or-assignment with constants.
      end
    RUBY

    expect_no_corrections
  end

  it 'registers an offense with or-assignment to a constant in method definition using `define_method`' do
    expect_offense(<<~RUBY)
      define_method :foo do
        M::CONST ||= 1
                 ^^^ Avoid using or-assignment with constants.
      end
    RUBY

    expect_correction(<<~RUBY)
      define_method :foo do
        M::CONST = 1
      end
    RUBY
  end

  it 'does not register an offense with plain assignment to a constant' do
    expect_no_offenses(<<~RUBY)
      CONST = 1
    RUBY
  end

  [
    ['a local variable', 'var'],
    ['an instance variable', '@var'],
    ['a class variable', '@@var'],
    ['a global variable', '$var'],
    ['an attribute', 'self.var']
  ].each do |type, var|
    it "does not register an offense with or-assignment to #{type}" do
      expect_no_offenses(<<~RUBY)
        #{var} ||= 1
      RUBY
    end
  end
end
