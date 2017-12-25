# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StructInheritance do
  subject(:cop) { described_class.new }

  it 'registers an offense when extending instance of Struct' do
    expect_offense(<<-RUBY.strip_indent)
      class Person < Struct.new(:first_name, :last_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`.
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct with do ... end' do
    expect_offense(<<-RUBY.strip_indent)
      class Person < Struct.new(:first_name, :last_name) do end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`.
      end
    RUBY
  end

  it 'accepts plain class' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Person
      end
    RUBY
  end

  it 'accepts extending DelegateClass' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class Person < DelegateClass(Animal)
      end
    RUBY
  end

  it 'accepts assignment to Struct.new' do
    expect_no_offenses('Person = Struct.new(:first_name, :last_name)')
  end
end
