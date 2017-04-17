# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClassStructure, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Layout/ClassStructure' => {
        'ExpectedOrder' => %w[
          extend
          include
          inner_class
          constant
          attribute_macro
          macro
          public_class_method
          initialize
          instance_method
          protected_method
          private_method
        ],
        'Categories' => {
          'macro' => %w[validates validate],
          'include' => %w[prepend],
          'attribute_macro' => %w[attr_accessor attr_reader attr_writer]
        }
      }
    )
  end

  context 'with a complete ordered example' do
    it 'does not create offense' do
      expect_no_offenses <<-RUBY
        class Person
          # extend and include go first
          extend SomeModule
          include AnotherModule

          # inner classes
          CustomError = Class.new(StandardError)

          # constants are next
          SOME_CONSTANT = 20

          # afterwards we have attribute macros
          attr_reader :name

          # followed by other macros (if any)
          validates :name

          # public class methods are next in line
          def self.some_method
          end

          # initialization goes between class methods and other instance methods
          def initialize
          end

          # followed by other public instance methods
          def some_method
          end

          # protected and private methods are grouped near the end
          protected

          def some_protected_method
          end

          private

          def some_private_method
          end
        end
      RUBY
    end
  end

  context 'simple example' do
    let(:code) { <<-RUBY }
      class Person
        CONST = 'wrong place'
        include AnotherModule
        ^^^^^^^^^^^^^^^^^^^^^ `include` is supposed to appear before `constant`.
        extend SomeModule
        ^^^^^^^^^^^^^^^^^ `extend` is supposed to appear before `include`.
      end
    RUBY

    it { expect_offense(code) }

    specify do
      expect(autocorrect_source_with_loop(<<-RUBY.strip_indent))
        class Person
          CONST = 'wrong place'
          include AnotherModule
          extend SomeModule
        end
      RUBY
        .to eq(<<-RUBY.strip_indent)
        class Person
          extend SomeModule
          include AnotherModule
          CONST = 'wrong place'
        end
      RUBY
    end
  end

  context 'with protected methods declared before private' do
    let(:code) { <<-RUBY }
      class MyClass
        def public_method
        end

        private

        def first_private_method
        end

        def second_private_method
        end

        protected

        def first_protected_method
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `protected_method` is supposed to appear before `private_method`.
        end

        def second_protected_method
        end
      end
    RUBY

    it { expect_offense(code) }
  end

  context 'with attribute macros before after validations' do
    let(:code) { <<-RUBY }
      class Person
        include AnotherModule
        extend SomeModule
        ^^^^^^^^^^^^^^^^^ `extend` is supposed to appear before `include`.

        CustomError = Class.new(StandardError)

        validates :name

        attr_reader :name
        ^^^^^^^^^^^^^^^^^ `attribute_macro` is supposed to appear before `macro`.

        def self.some_public_class_method
        end

        def initialize
        end

        def some_public_method
        end

        def other_public_method
        end

        private :other_public_method

        private def something_inline
        end

        def yet_other_public_method
        end

        protected

        def some_protected_method
        end

        private

        def some_private_method
        end
      end
    RUBY

    it { expect_offense(code) }
  end
end
