# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::ClassStructure, :config do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      'Layout/ClassStructure' => {
        'ExpectedOrder' => %w[
          module_inclusion
          constants
          attribute_macros
          macros
          public_class_methods
          initializer
          public_methods
          protected_methods
          private_methods
        ],
        'Categories' => {
          'macros' => %w[validates validate],
          'module_inclusion' => %w[prepend extend include],
          'attribute_macros' => %w[attr_accessor attr_reader attr_writer]
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
    specify do
      expect_offense <<-RUBY.strip_indent
        class Person
          CONST = 'wrong place'
          include AnotherModule
          ^^^^^^^^^^^^^^^^^^^^^ `module_inclusion` is supposed to appear before `constants`.
          extend SomeModule
        end
      RUBY
    end

    specify do
      expect(autocorrect_source_with_loop(<<-RUBY.strip_indent))
        class Example
          CONST = 1
          include AnotherModule
          extend SomeModule
        end
      RUBY
        .to eq(<<-RUBY.strip_indent)
        class Example
          include AnotherModule
          extend SomeModule
          CONST = 1
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
        ^^^^^^^^^^^^^^^^^^^^^^^^^^ `protected_methods` is supposed to appear before `private_methods`.
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

        CustomError = Class.new(StandardError)

        validates :name

        attr_reader :name
        ^^^^^^^^^^^^^^^^^ `attribute_macros` is supposed to appear before `macros`.

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
