# frozen_string_literal: true

describe RuboCop::Cop::Style::MethodCallWithArgsParentheses, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) do
    { 'IgnoredMethods' => %w(puts) }
  end

  it 'accepts no parens in method call without args' do
    inspect_source(cop, 'top.test')
    expect(cop.offenses).to be_empty
  end

  it 'accepts parens in method call with args' do
    inspect_source(cop, 'top.test(a, b)')
    expect(cop.offenses).to be_empty
  end

  it 'register an offence for method call without parens' do
    inspect_source(cop, 'top.test a, b')
    expect(cop.offenses.size).to eq(1)
  end

  it 'register an offence for non-reciever method call without parens' do
    inspect_source(cop, 'test a, b')
    expect(cop.offenses.size).to eq(1)
  end

  it 'register an offence for methods starting with a capital without parens' do
    inspect_source(cop, 'Test a, b')
    expect(cop.offenses.size).to eq(1)
  end

  it 'register an offence for superclass call without parens' do
    inspect_source(cop, 'super a')
    expect(cop.offenses.size).to eq(1)
  end

  it 'register no offence for superclass call without args' do
    inspect_source(cop, 'super')
    expect(cop.offenses).to be_empty
  end

  it 'register no offence for yield without args' do
    inspect_source(cop, 'yield')
    expect(cop.offenses).to be_empty
  end

  it 'register no offence for superclass call with parens' do
    inspect_source(cop, 'super(a)')
    expect(cop.offenses).to be_empty
  end

  it 'register an offence for yield without parens' do
    inspect_source(cop, 'yield a')
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts no parens for operators' do
    inspect_source(cop, 'top.test + a')
    expect(cop.offenses).to be_empty
  end

  it 'accepts no parens for unary operators' do
    inspect_source(cop, '!test')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects call by adding needed braces' do
    new_source = autocorrect_source(cop, 'top.test a')
    expect(new_source).to eq('top.test(a)')
  end

  it 'auto-corrects superclass call by adding needed braces' do
    new_source = autocorrect_source(cop, 'super a')
    expect(new_source).to eq('super(a)')
  end

  it 'ignores method listed in IgnoredMethods' do
    inspect_source(cop, 'puts :test')
    expect(cop.offenses).to be_empty
  end

  context 'with DSL like methods' do
    let(:cop_config) do
      { 'IgnoreDslMethods' => 'true' }
    end

    context 'in a class body' do
      it 'does not register an offense' do
        inspect_source(cop, [
          'class Foo',
          '  bar :baz',
          'end'
        ].join("\n"))

        expect(cop.offenses).to be_empty
      end
    end

    context 'in a module body' do
      it 'does not register an offense' do
        inspect_source(cop, [
          'module Foo',
          '  bar :baz',
          'end'
        ].join("\n"))

        expect(cop.offenses).to be_empty
      end
    end
  end
end
