# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InstanceVarsInClass do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context 'when using instance_variable by itself' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        @instance_variable
      RUBY
    end
  end

  context 'in a class' do
    context 'when using an instance variable instead of an attr_reader' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
          class TestClass
            def foo
              @instance_variable
              ^^^^^^^^^^^^^^^^^^ Define an `attr_reader :instance_variable` and use that to access the variable instead of using the `@instance_variable` directly. You may also want to make this `attr_*` private with `private :instance_variable`.
            end
          end
        RUBY
      end
    end

    it 'informs the user when attr_accessor should be used instead' do
      expect_offense(<<-RUBY.strip_indent)
        class TestClass
          def foo
            @instance_variable = 1
            ^^^^^^^^^^^^^^^^^^^^^^ Define an `attr_accessor :instance_variable` and use that to access the variable instead of using the `@instance_variable=` directly. You may also want to make this `attr_*` private with `private :instance_variable`.
          end
        end
      RUBY
    end

    context 'in initialize' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class TestClass
            def initialize
              @instance_variable
            end
          end
        RUBY
      end
    end

    context 'when used to memoize' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          class TestClass
            def foo
              @foo ||= "bar"
            end
          end
        RUBY
      end
    end
  end
end
