# frozen_string_literal: true

describe RuboCop::Cop::Style::ColonMethodCall do
  subject(:cop) { described_class.new }

  it 'registers an offense for instance method call' do
    inspect_source(cop, 'test::method_name')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for instance method call with arg' do
    inspect_source(cop, 'test::method_name(arg)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for class method call' do
    inspect_source(cop, 'Class::method_name')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for class method call with arg' do
    inspect_source(cop, 'Class::method_name(arg, arg2)')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for constant access' do
    inspect_source(cop, 'Tip::Top::SOME_CONST')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for nested class' do
    inspect_source(cop, 'Tip::Top.some_method')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for op methods' do
    inspect_source(cop, 'Tip::Top.some_method[3]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense when for constructor methods' do
    inspect_source(cop, 'Tip::Top(some_arg)')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for Java static types' do
    inspect_source(cop, 'Java::int')
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects "::" with "."' do
    new_source = autocorrect_source(cop, 'test::method')
    expect(new_source).to eq('test.method')
  end
end
