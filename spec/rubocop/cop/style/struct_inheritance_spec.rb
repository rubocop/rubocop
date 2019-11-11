# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::StructInheritance do
  subject(:cop) { described_class.new }

  it 'registers an offense when extending instance of Struct' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY
  end

  it 'registers an offense when extending instance of Struct with do ... end' do
    expect_offense(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name) do end
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Don't extend an instance initialized by `Struct.new`. Use a block to customize the struct.
      end
    RUBY
  end

  it 'accepts plain class' do
    expect_no_offenses(<<~RUBY)
      class Person
      end
    RUBY
  end

  it 'accepts extending DelegateClass' do
    expect_no_offenses(<<~RUBY)
      class Person < DelegateClass(Animal)
      end
    RUBY
  end

  it 'accepts assignment to Struct.new' do
    expect_no_offenses('Person = Struct.new(:first_name, :last_name)')
  end

  it 'accepts assignment to block form of Struct.new' do
    expect_no_offenses(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
        def age
          42
        end
      end
    RUBY
  end

  it 'autocorrects simple inline class with no block' do
    new_source = autocorrect_source(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
      end
    RUBY

    expect(new_source).to eq(<<~RUBY)
      Person = Struct.new(:first_name, :last_name)
    RUBY
  end

  it 'autocorrects a class with a body' do
    new_source = autocorrect_source(<<~RUBY)
      class Person < Struct.new(:first_name, :last_name)
        def age
          42
        end
      end
    RUBY

    expect(new_source).to eq(<<~RUBY)
      Person = Struct.new(:first_name, :last_name) do
        def age
          42
        end
      end
    RUBY
  end

  it 'ignores a class with an empty block and empty body' do
    original_source = <<~RUBY
      class Person < Struct.new(:first_name, :last_name) do end
      end
    RUBY

    expect(autocorrect_source(original_source)).to eq(original_source)
  end

  it 'ignores a class with a body and an empty block' do
    original_source = <<~RUBY
      class Person < Struct.new(:first_name, :last_name) do end
        def age
          42
        end
      end
    RUBY

    expect(autocorrect_source(original_source)).to eq(original_source)
  end

  it 'ignores a class with a body and a block' do
    original_source = <<~RUBY
      class Person < Struct.new(:first_name, :last_name) do def baz; end end
        def age
          42
        end
      end
    RUBY

    expect(autocorrect_source(original_source)).to eq(original_source)
  end
end
