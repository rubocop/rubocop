# frozen_string_literal: true

describe RuboCop::Cop::Style::ClassAndModuleCamelCase do
  subject(:cop) { described_class.new }

  it 'registers an offense for underscore in class and module name' do
    inspect_source(cop,
                   ['class My_Class',
                    'end',
                    '',
                    'module My_Module',
                    'end'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'is not fooled by qualified names' do
    inspect_source(cop,
                   ['class Top::My_Class',
                    'end',
                    '',
                    'module My_Module::Ala',
                    'end'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts CamelCase names' do
    inspect_source(cop,
                   ['class MyClass',
                    'end',
                    '',
                    'module Mine',
                    'end'])
    expect(cop.offenses).to be_empty
  end
end
