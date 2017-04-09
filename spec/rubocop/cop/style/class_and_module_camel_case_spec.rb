# frozen_string_literal: true

describe RuboCop::Cop::Style::ClassAndModuleCamelCase do
  subject(:cop) { described_class.new }

  it 'registers an offense for underscore in class and module name' do
    inspect_source(cop, <<-END.strip_indent)
      class My_Class
      end

      module My_Module
      end
    END
    expect(cop.offenses.size).to eq(2)
  end

  it 'is not fooled by qualified names' do
    inspect_source(cop, <<-END.strip_indent)
      class Top::My_Class
      end

      module My_Module::Ala
      end
    END
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts CamelCase names' do
    inspect_source(cop, <<-END.strip_indent)
      class MyClass
      end

      module Mine
      end
    END
    expect(cop.offenses).to be_empty
  end
end
