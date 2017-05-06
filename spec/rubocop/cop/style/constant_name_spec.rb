# frozen_string_literal: true

describe RuboCop::Cop::Style::ConstantName do
  subject(:cop) { described_class.new }

  it 'registers an offense for camel case in const name' do
    inspect_source(cop,
                   'TopCase = 5')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers offenses for camel case in multiple const assignment' do
    inspect_source(cop,
                   'TopCase, Test2, TEST_3 = 5, 6, 7')
    expect(cop.offenses.size).to eq(2)
  end

  it 'registers an offense for snake case in const name' do
    inspect_source(cop,
                   'TOP_test = 5')
    expect(cop.offenses.size).to eq(1)
  end

  it 'allows screaming snake case in const name' do
    inspect_source(cop,
                   'TOP_TEST = 5')
    expect(cop.offenses).to be_empty
  end

  it 'allows screaming snake case in multiple const assignment' do
    inspect_source(cop,
                   'TOP_TEST, TEST_2 = 5, 6')
    expect(cop.offenses).to be_empty
  end

  it 'does not check names if rhs is a method call' do
    inspect_source(cop,
                   'AnythingGoes = test')
    expect(cop.offenses).to be_empty
  end

  it 'does not check names if rhs is a method call with block' do
    inspect_source(cop, <<-END.strip_indent)
      AnythingGoes = test do
        do_something
      end
    END
    expect(cop.offenses).to be_empty
  end

  it 'does not check if rhs is another constant' do
    inspect_source(cop,
                   'Parser::CurrentRuby = Parser::Ruby20')
    expect(cop.offenses).to be_empty
  end

  it 'checks qualified const names' do
    inspect_source(cop, <<-END.strip_indent)
      ::AnythingGoes = 30
      a::Bar_foo = 10
    END
    expect(cop.offenses.size).to eq(2)
  end

  it 'auto-corrects camel case to screaming snake case' do
    new_source = autocorrect_source(cop, 'ConstantName = 5')
    expect(new_source).to eq 'CONSTANT_NAME = 5'
  end

  it 'correctly auto-corrects camel cased initialisms' do
    new_source = autocorrect_source(cop, 'ConstantCSV = 5')
    expect(new_source).to eq 'CONSTANT_CSV = 5'
  end
end
