# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MethodMissingSuper do
  subject(:cop) { described_class.new }

  describe 'method_missing defined as an instance method' do
    it 'registers an offense when super is not called.' do
      expect_offense(<<-RUBY.strip_indent)
        class Test
          def method_missing
          ^^^^^^^^^^^^^^^^^^ When using `method_missing`, fall back on `super`.
          end
        end
      RUBY
    end

    it 'allows method_missing when super is called' do
      expect_no_offenses(<<-RUBY)
        class Test
          def method_missing
            super
          end
        end
      RUBY
    end
  end

  describe 'method_missing defined as a class method' do
    it 'registers an offense when super is not called.' do
      expect_offense(<<-RUBY.strip_indent)
        class Test
          def self.method_missing
          ^^^^^^^^^^^^^^^^^^^^^^^ When using `method_missing`, fall back on `super`.
          end
        end
      RUBY
    end

    it 'allows method_missing when super is called' do
      expect_no_offenses(<<-RUBY)
        class Test
          def self.method_missing
            super
          end
        end
      RUBY
    end
  end
end
