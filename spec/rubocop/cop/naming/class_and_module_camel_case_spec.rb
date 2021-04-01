# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::ClassAndModuleCamelCase, :config do
  it 'registers an offense for underscore in class and module name' do
    expect_offense(<<~RUBY)
      class My_Class
            ^^^^^^^^ Use CamelCase for classes and modules.
      end

      module My_Module
             ^^^^^^^^^ Use CamelCase for classes and modules.
      end
    RUBY
  end

  it 'is not fooled by qualified names' do
    expect_offense(<<~RUBY)
      class Top::My_Class
            ^^^^^^^^^^^^^ Use CamelCase for classes and modules.
      end

      module My_Module::Ala
             ^^^^^^^^^^^^^^ Use CamelCase for classes and modules.
      end
    RUBY
  end

  it 'accepts CamelCase names' do
    expect_no_offenses(<<~RUBY)
      class MyClass
      end

      module Mine
      end
    RUBY
  end

  it 'allows module_parent method' do
    expect_no_offenses(<<~RUBY)
      class module_parent::MyClass
      end
    RUBY
  end

  context 'custom allowed names' do
    let(:cop_config) { { 'AllowedNames' => %w[getter_class setter_class] } }

    it 'does not register offense for multiple allowed names' do
      expect_no_offenses(<<~RUBY)
        class getter_class::MyClass
        end

        class setter_class::MyClass
        end
      RUBY
    end
  end
end
