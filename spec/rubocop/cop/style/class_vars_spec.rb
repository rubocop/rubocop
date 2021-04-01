# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::ClassVars, :config do
  it 'registers an offense for class variable declaration' do
    expect_offense(<<~RUBY)
      class TestClass; @@test = 10; end
                       ^^^^^^ Replace class var @@test with a class instance var.
    RUBY
  end

  it 'registers an offense for class variable set in class' do
    expect_offense(<<~RUBY)
      class TestClass
        class_variable_set(:@@test, 2)
                           ^^^^^^^ Replace class var :@@test with a class instance var.
      end
    RUBY
  end

  it 'registers an offense for class variable set on class receiver' do
    expect_offense(<<~RUBY)
      class TestClass; end
      TestClass.class_variable_set(:@@test, 42)
                                   ^^^^^^^ Replace class var :@@test with a class instance var.
    RUBY
  end

  it 'does not register an offense for class variable usage' do
    expect_no_offenses('@@test.test(20)')
  end
end
