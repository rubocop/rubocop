# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SingleConstantInitialization do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a constant is initialized twice' do
    expect_offense(<<-RUBY.strip_indent)
      CONSTANT = 1
      CONSTANT = 2
      ^^^^^^^^^^^^ Constant `CONSTANT` initialized more than once.
    RUBY
  end

  it 'does not register an offense when a constant is initialized only once' do
    expect_no_offenses(<<-RUBY.strip_indent)
      CONSTANT = 1

      module TestModule1
        class TestClass1
          CONSTANT = 1
        end

        class TestClass2
          CONSTANT = 1
        end
      end

      module TestModule2
        class TestClass1
          CONSTANT = 1
        end

        class TestClass2
          CONSTANT = 1
        end
      end
    RUBY
  end
end
