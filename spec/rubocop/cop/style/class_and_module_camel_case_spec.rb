# frozen_string_literal: true

describe RuboCop::Cop::Style::ClassAndModuleCamelCase do
  subject(:cop) { described_class.new }

  it 'registers an offense for underscore in class and module name' do
    expect_offense(<<-RUBY.strip_indent)
      class My_Class
            ^^^^^^^^ Use CamelCase for classes and modules.
      end

      module My_Module
             ^^^^^^^^^ Use CamelCase for classes and modules.
      end
    RUBY
  end

  it 'is not fooled by qualified names' do
    expect_offense(<<-RUBY.strip_indent)
      class Top::My_Class
            ^^^^^^^^^^^^^ Use CamelCase for classes and modules.
      end

      module My_Module::Ala
             ^^^^^^^^^^^^^^ Use CamelCase for classes and modules.
      end
    RUBY
  end

  it 'accepts CamelCase names' do
    expect_no_offenses(<<-END.strip_indent)
      class MyClass
      end

      module Mine
      end
    END
  end
end
