# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::NoMetaprogramming do
  include RuboCop::RSpec::ExpectOffense

  subject(:cop) { described_class.new }

  context 'when using send' do
    let(:source) do
      <<~RUBY
        foo.send(:bar)
      RUBY
    end

    it { expect_no_offenses source }
  end

  context 'when using included' do
    let(:source) do
      <<~RUBY
        module A
          def self.included(mod)
          ^^^^^^^^^^^^^^^^^^^^^^ self.included modifies the behavior of classes at runtime. Please avoid using if possible.
          end
        end
      RUBY
    end

    it { expect_offense source }
  end

  context 'when using inherited' do
    let(:source) do
      <<~RUBY
        class Foo
          def self.inherited(subclass)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ self.inherited modifies the behavior of classes at runtime. Please avoid using if possible.
            puts "New subclass: " + subclass
          end
        end
      RUBY
    end

    it { expect_offense source }
  end

  context 'when a rails concern' do
    let(:source) do
      <<~RUBY
        module Bar
          extend ActiveSupport::Concern
          include Foo

          included do
            self.method_injected_by_foo
          end

          class_methods do
            self.method_injected_by_baz
          end
        end
      RUBY
    end

    it { expect_no_offenses source }
  end

  context 'when using define_method' do
    let(:source) do
      <<~RUBY
        class A
          define_method("something") do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^ Please do not define methods dynamically, instead define them using `def` and explicitly. This helps readability for both humans and machines.
          end
        end
      RUBY
    end

    it { expect_offense source }

    context 'an example from Payments code' do
      let(:source) do
        <<~RUBY
          module AssociationCacheable
            extend ActiveSupport::Concern

            module ClassMethods
              def cached_belongs_to(association_name, options = {})
                define_method(association_name) do
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please do not define methods dynamically, instead define them using `def` and explicitly. This helps readability for both humans and machines.
                end
              end
            end
          end
        RUBY
      end

      it { expect_offense source }
    end
  end

  context 'when using method_missing' do
    let(:source) do
      <<~RUBY
        class A
          def method_missing(name, *args, **kwargs)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please do not use method_missing. Instead, explicitly define the methods you expect to receive.
          end
        end
      RUBY
    end

    it { expect_offense source }
  end

  context 'when using define_singleton_method' do
    let(:source) do
      <<~RUBY
        class A
          define_singleton_method("was_" + "early?") do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please do not use define_singleton_method. Instead, define the method explicitly using `def self.my_method; end`
          end
        end
      RUBY
    end

    it { expect_offense source }

    context 'on an instance of a class' do
      let(:source) do
        <<~RUBY
          Transmission.define_singleton_method(:types) do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Please do not use define_singleton_method. Instead, define the method explicitly using `def self.my_method; end`
            @vals
          end
        RUBY
      end

      it { expect_offense source }
    end
  end

  context 'when using instance_eval' do
    let(:source) do
      <<~RUBY
        def some_method
          thing.instance_eval do
          ^^^^^^^^^^^^^^^^^^^ Please do not use instance_eval to augment behavior onto an instance. Instead, define the method you want to use in the class definition.
            def /(delimiter)
              split(delimiter)
            end
          end
        end
      RUBY
    end

    it { expect_offense source }
  end

  context 'when using class_eval' do
    let(:source) do
      <<~RUBY
        String.class_eval do
        ^^^^^^^^^^^^^^^^^ Please do not use class_eval to augment behavior onto a class. Instead, define the method you want to use in the class definition.
          def /(delimiter)
            split(delimiter)
          end
        end
      RUBY
    end

    it { expect_offense source }
  end
end
