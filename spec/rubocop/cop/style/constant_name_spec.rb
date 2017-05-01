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
    expect_no_offenses('TOP_TEST = 5')
  end

  it 'allows screaming snake case in multiple const assignment' do
    expect_no_offenses('TOP_TEST, TEST_2 = 5, 6')
  end

  it 'does not check names if rhs is a method call' do
    expect_no_offenses('AnythingGoes = test')
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
    expect_no_offenses('Parser::CurrentRuby = Parser::Ruby20')
  end

  it 'checks qualified const names' do
    inspect_source(cop, <<-END.strip_indent)
      ::AnythingGoes = 30
      a::Bar_foo = 10
    END
    expect(cop.offenses.size).to eq(2)
  end
end
