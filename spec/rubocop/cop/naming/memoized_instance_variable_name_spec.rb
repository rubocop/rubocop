# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MemoizedInstanceVariableName do
  subject(:cop) { described_class.new }

  context 'memoized variable does not match method name' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
      def x
        @my_var ||= :foo
        ^^^^^^^ Memoized variable does not match method name.
      end
      RUBY
    end
  end

  context 'memoized variable does not match class method name' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
      def self.x
        @my_var ||= :foo
        ^^^^^^^ Memoized variable does not match method name.
      end
      RUBY
    end
  end

  context 'memoized variable does not match method name during assignment' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
      foo = def x
        @y ||= :foo
        ^^ Memoized variable does not match method name.
      end
      RUBY
    end
  end

  context 'memoized variable does not match method name for block' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
      def x
        @y ||= begin
        ^^ Memoized variable does not match method name.
          :foo
        end
      end
      RUBY
    end
  end

  context 'memoized variable after other code does not match method name' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        def foo
          helper_variable = something_we_need_to_calculate_foo
          @bar ||= calculate_expensive_thing(helper_variable)
          ^^^^ Memoized variable does not match method name.
        end
      RUBY
    end
  end

  context 'memoized variable matches method name' do
    it 'does not register an offense' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def x
          @x ||= :foo
        end
      RUBY
    end

    context 'memoized variable matches method name during assignment' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          foo = def y
            @y ||= :foo
          end
        RUBY
      end
    end

    context 'memoized variable matches method name for block' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def z
            @z ||= begin
              :foo
            end
          end
        RUBY
      end
    end

    context 'non-memoized variable does not match method name' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def a
            x ||= :foo
          end
        RUBY
      end
    end

    context 'memoized variable matches predicate method name' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def a?
            @a ||= :foo
          end
        RUBY
      end
    end

    context 'code follows memoized variable assignment' do
      it 'does not register an offense' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def a
            @b ||= :foo
            call_something_else
          end
        RUBY
      end

      context 'memoized variable after other code' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            def foo
              helper_variable = something_we_need_to_calculate_foo
              @foo ||= calculate_expensive_thing(helper_variable)
            end
          RUBY
        end
      end

      context 'instance variables in initialize methods' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            def initialize
              @files_with_offenses ||= {}
            end
          RUBY
        end
      end
    end
  end
end
