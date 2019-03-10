# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::MemoizedInstanceVariableName, :config do
  subject(:cop) { described_class.new(config) }

  context 'with default EnforcedStyleForLeadingUnderscores => disallowed' do
    let(:cop_config) do
      { 'EnforcedStyleForLeadingUnderscores' => 'disallowed' }
    end

    context 'memoized variable does not match method name' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
        def x
          @my_var ||= :foo
          ^^^^^^^ Memoized variable `@my_var` does not match method name `x`. Use `@x` instead.
        end
        RUBY
      end
    end

    context 'memoized variable does not match class method name' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
        def self.x
          @my_var ||= :foo
          ^^^^^^^ Memoized variable `@my_var` does not match method name `x`. Use `@x` instead.
        end
        RUBY
      end
    end

    context 'memoized variable does not match method name during assignment' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
        foo = def x
          @y ||= :foo
          ^^ Memoized variable `@y` does not match method name `x`. Use `@x` instead.
        end
        RUBY
      end
    end

    context 'memoized variable does not match method name for block' do
      it 'registers an offense' do
        expect_offense(<<-RUBY.strip_indent)
        def x
          @y ||= begin
          ^^ Memoized variable `@y` does not match method name `x`. Use `@x` instead.
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
            ^^^^ Memoized variable `@bar` does not match method name `foo`. Use `@foo` instead.
          end
        RUBY
      end

      it 'registers an offense for a predicate method' do
        expect_offense(<<-RUBY.strip_indent)
          def foo?
            helper_variable = something_we_need_to_calculate_foo
            @bar ||= calculate_expensive_thing(helper_variable)
            ^^^^ Memoized variable `@bar` does not match method name `foo?`. Use `@foo` instead.
          end
        RUBY
      end

      it 'registers an offense for a bang method' do
        expect_offense(<<-RUBY.strip_indent)
          def foo!
            helper_variable = something_we_need_to_calculate_foo
            @bar ||= calculate_expensive_thing(helper_variable)
            ^^^^ Memoized variable `@bar` does not match method name `foo!`. Use `@foo` instead.
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

      it 'does not registers an offense when method has leading `_`' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def _foo
            @foo ||= :foo
          end
        RUBY
      end

      it 'does not register an offense with a leading `_` for both names' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def _foo
            @_foo ||= :foo
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

      context 'memoized variable matches bang method name' do
        it 'does not register an offense' do
          expect_no_offenses(<<-RUBY.strip_indent)
            def a!
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

  context 'EnforcedStyleForLeadingUnderscores: required' do
    let(:cop_config) { { 'EnforcedStyleForLeadingUnderscores' => 'required' } }

    it 'registers an offense when names match but missing a leading _' do
      expect_offense(<<-RUBY.strip_indent)
      def foo
        @foo ||= :foo
        ^^^^ Memoized variable `@foo` does not start with `_`. Use `@_foo` instead.
      end
      RUBY
    end

    it 'registers an offense when it has leading `_` but names do not match' do
      expect_offense(<<-RUBY.strip_indent)
      def foo
        @_my_var ||= :foo
        ^^^^^^^^ Memoized variable `@_my_var` does not match method name `foo`. Use `@_foo` instead.
      end
      RUBY
    end

    it 'does not register an offense with a leading `_` for both names' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def _foo
          @_foo ||= :foo
        end
      RUBY
    end
  end

  context 'EnforcedStyleForLeadingUnderscores: optional' do
    let(:cop_config) { { 'EnforcedStyleForLeadingUnderscores' => 'optional' } }

    context 'memoized variable matches method name' do
      it 'does not register an offense with a leading underscore' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def x
            @_x ||= :foo
          end
        RUBY
      end

      it 'does not register an offense without a leading underscore' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def x
            @x ||= :foo
          end
        RUBY
      end

      it 'does not register an offense with a leading `_` for both names' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def _x
            @_x ||= :foo
          end
        RUBY
      end

      it 'does not register an offense with a leading `_` for method name' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def _x
            @x ||= :foo
          end
        RUBY
      end
    end
  end
end
