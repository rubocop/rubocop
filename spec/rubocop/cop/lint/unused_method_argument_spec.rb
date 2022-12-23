# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnusedMethodArgument, :config do
  let(:cop_config) do
    {
      'AllowUnusedKeywordArguments' => false,
      'IgnoreEmptyMethods' => false,
      'IgnoreNotImplementedMethods' => false
    }
  end

  describe 'inspection' do
    context 'when a method takes multiple arguments' do
      context 'and an argument is unused' do
        it 'registers an offense and adds underscore-prefix' do
          message = 'Unused method argument - `foo`. ' \
                    "If it's necessary, use `_` or `_foo` " \
                    "as an argument name to indicate that it won't be used. " \
                    "If it's unnecessary, remove it."

          expect_offense(<<~RUBY)
            def some_method(foo, bar)
                            ^^^ #{message}
              puts bar
            end
          RUBY

          expect_correction(<<~RUBY)
            def some_method(_foo, bar)
              puts bar
            end
          RUBY
        end

        context 'and there is some whitespace around the unused argument' do
          it 'registers an offense and preserves whitespace' do
            message = 'Unused method argument - `bar`. ' \
                      "If it's necessary, use `_` or `_bar` " \
                      "as an argument name to indicate that it won't be used. " \
                      "If it's unnecessary, remove it."

            expect_offense(<<~RUBY)
              def some_method(foo,
                  bar)
                  ^^^ #{message}
                puts foo
              end
            RUBY

            expect_correction(<<~RUBY)
              def some_method(foo,
                  _bar)
                puts foo
              end
            RUBY
          end
        end

        context 'and arguments are swap-assigned' do
          it 'accepts' do
            expect_no_offenses(<<~RUBY)
              def foo(a, b)
                a, b = b, a
              end
            RUBY
          end
        end

        context "and one argument is assigned to another, whilst other's value is not used" do
          it 'registers an offense' do
            message = "Unused method argument - `a`. If it's necessary, use " \
                      '`_` or `_a` as an argument name to indicate that ' \
                      "it won't be used. If it's unnecessary, remove it."

            expect_offense(<<~RUBY)
              def foo(a, b)
                      ^ #{message}
                a, b = b, 42
              end
            RUBY

            expect_correction(<<~RUBY)
              def foo(_a, b)
                a, b = b, 42
              end
            RUBY
          end
        end
      end

      context 'and all the arguments are unused' do
        it 'registers offenses and suggests the use of `*` and ' \
           'autocorrects to add underscore-prefix to all arguments' do
          (foo_message, bar_message) = %w[foo bar].map do |arg|
            "Unused method argument - `#{arg}`. " \
              "If it's necessary, use `_` or `_#{arg}` " \
              "as an argument name to indicate that it won't be used. " \
              "If it's unnecessary, remove it. " \
              'You can also write as `some_method(*)` if you want the method ' \
              "to accept any arguments but don't care about them."
          end

          expect_offense(<<~RUBY)
            def some_method(foo, bar)
                                 ^^^ #{bar_message}
                            ^^^ #{foo_message}
            end
          RUBY

          expect_correction(<<~RUBY)
            def some_method(_foo, _bar)
            end
          RUBY
        end
      end
    end

    context 'when a splat argument is unused' do
      it 'registers an offense and preserves the splat' do
        message = 'Unused method argument - `bar`. ' \
                  "If it's necessary, use `_` or `_bar` " \
                  "as an argument name to indicate that it won't be used. " \
                  "If it's unnecessary, remove it."

        expect_offense(<<~RUBY)
          def some_method(foo, *bar)
                                ^^^ #{message}
            puts foo
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method(foo, *_bar)
            puts foo
          end
        RUBY
      end
    end

    context 'when an argument with a default value is unused' do
      it 'registers an offense and preserves the default value' do
        message = 'Unused method argument - `bar`. ' \
                  "If it's necessary, use `_` or `_bar` " \
                  "as an argument name to indicate that it won't be used. " \
                  "If it's unnecessary, remove it."

        expect_offense(<<~RUBY)
          def some_method(foo, bar = 1)
                               ^^^ #{message}
            puts foo
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method(foo, _bar = 1)
            puts foo
          end
        RUBY
      end
    end

    context 'when a required keyword argument is unused', ruby: 2.1 do
      context 'when a required keyword argument is unused' do
        it 'registers an offense but does not suggest underscore-prefix' do
          expect_offense(<<~RUBY)
            def self.some_method(foo, bar:)
                                      ^^^ Unused method argument - `bar`.
              puts foo
            end
          RUBY

          expect_no_corrections
        end
      end
    end

    context 'when an optional keyword argument is unused' do
      it 'registers an offense but does not suggest underscore-prefix' do
        expect_offense(<<~RUBY)
          def self.some_method(foo, bar: 1)
                                    ^^^ Unused method argument - `bar`.
            puts foo
          end
        RUBY

        expect_no_corrections
      end

      context 'and AllowUnusedKeywordArguments set' do
        let(:cop_config) { { 'AllowUnusedKeywordArguments' => true } }

        it 'does not care' do
          expect_no_offenses(<<~RUBY)
            def self.some_method(foo, bar: 1)
              puts foo
            end
          RUBY
        end
      end
    end

    context 'when a trailing block argument is unused' do
      it 'registers an offense and removes the unused block arg' do
        message = 'Unused method argument - `block`. ' \
                  "If it's necessary, use `_` or `_block` " \
                  "as an argument name to indicate that it won't be used. " \
                  "If it's unnecessary, remove it."

        expect_offense(<<~RUBY)
          def some_method(foo, bar, &block)
                                     ^^^^^ #{message}
            foo + bar
          end
        RUBY

        expect_correction(<<~RUBY)
          def some_method(foo, bar)
            foo + bar
          end
        RUBY
      end
    end

    context 'when a singleton method argument is unused' do
      it 'registers an offense' do
        message = "Unused method argument - `foo`. If it's necessary, use " \
                  '`_` or `_foo` as an argument name to indicate that it ' \
                  "won't be used. If it's unnecessary, remove it. " \
                  'You can also write as `some_method(*)` if you want the ' \
                  "method to accept any arguments but don't care about them."

        expect_offense(<<~RUBY)
          def self.some_method(foo)
                               ^^^ #{message}
          end
        RUBY

        expect_correction(<<~RUBY)
          def self.some_method(_foo)
          end
        RUBY
      end
    end

    context 'when an underscore-prefixed method argument is unused' do
      let(:source) { <<~RUBY }
        def some_method(_foo)
        end
      RUBY

      it 'accepts' do
        expect_no_offenses(source)
      end
    end

    context 'when a method argument is used' do
      let(:source) { <<~RUBY }
        def some_method(foo)
          puts foo
        end
      RUBY

      it 'accepts' do
        expect_no_offenses(source)
      end
    end

    context 'when a variable is unused' do
      let(:source) { <<~RUBY }
        def some_method
          foo = 1
        end
      RUBY

      it 'does not care' do
        expect_no_offenses(source)
      end
    end

    context 'when a block argument is unused' do
      let(:source) { <<~RUBY }
        1.times do |foo|
        end
      RUBY

      it 'does not care' do
        expect_no_offenses(source)
      end
    end

    context 'in a method calling `super` without arguments' do
      context 'when a method argument is not used explicitly' do
        it 'accepts since the arguments are guaranteed to be the same as ' \
           "superclass' ones and the user has no control on them" do
          expect_no_offenses(<<~RUBY)
            def some_method(foo)
              super
            end
          RUBY
        end
      end
    end

    context 'in a method calling `super` with arguments' do
      context 'when a method argument is unused' do
        it 'registers an offense' do
          message = "Unused method argument - `foo`. If it's necessary, use " \
                    '`_` or `_foo` as an argument name to indicate that ' \
                    "it won't be used. If it's unnecessary, remove it. " \
                    'You can also write as `some_method(*)` if you want ' \
                    "the method to accept any arguments but don't care about " \
                    'them.'

          expect_offense(<<~RUBY)
            def some_method(foo)
                            ^^^ #{message}
              super(:something)
            end
          RUBY

          expect_correction(<<~RUBY)
            def some_method(_foo)
              super(:something)
            end
          RUBY
        end
      end
    end

    context 'in a method calling `binding` without arguments' do
      let(:source) { <<~RUBY }
        def some_method(foo, bar)
          do_something binding
        end
      RUBY

      it 'accepts all arguments' do
        expect_no_offenses(source)
      end

      context 'inside another method definition' do
        (foo_message, bar_message) = %w[foo bar].map do |arg|
          "Unused method argument - `#{arg}`. If it's necessary, use `_` or " \
            "`_#{arg}` as an argument name to indicate that it won't be " \
            "used. If it's unnecessary, remove it. You can also write as " \
            '`some_method(*)` if you want the method to accept any arguments ' \
            "but don't care about them."
        end

        it 'registers offenses' do
          expect_offense(<<~RUBY)
            def some_method(foo, bar)
                                 ^^^ #{bar_message}
                            ^^^ #{foo_message}
              def other(a)
                puts something(binding)
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            def some_method(_foo, _bar)
              def other(a)
                puts something(binding)
              end
            end
          RUBY
        end
      end
    end

    context 'in a method calling `binding` with arguments' do
      context 'when a method argument is unused' do
        it 'registers an offense' do
          message = "Unused method argument - `foo`. If it's necessary, use " \
                    '`_` or `_foo` as an argument name to indicate that it ' \
                    "won't be used. If it's unnecessary, remove it. You can " \
                    'also write as `some_method(*)` if you want the method ' \
                    "to accept any arguments but don't care about them."

          expect_offense(<<~RUBY)
            def some_method(foo)
                            ^^^ #{message}
              binding(:something)
            end
          RUBY

          expect_correction(<<~RUBY)
            def some_method(_foo)
              binding(:something)
            end
          RUBY
        end
      end
    end
  end

  context 'when IgnoreEmptyMethods config parameter is set' do
    let(:cop_config) { { 'IgnoreEmptyMethods' => true } }

    it 'accepts an empty method with a single unused parameter' do
      expect_no_offenses(<<~RUBY)
        def method(arg)
        end
      RUBY
    end

    it 'accepts an empty singleton method with a single unused parameter' do
      expect_no_offenses(<<~RUBY)
        def self.method(unused)
        end
      RUBY
    end

    it 'registers an offense for a non-empty method with a single unused parameter' do
      message = "Unused method argument - `arg`. If it's necessary, use " \
                '`_` or `_arg` as an argument name to indicate that it ' \
                "won't be used. If it's unnecessary, remove it. You can also write " \
                'as `method(*)` if you want the method to accept any arguments ' \
                "but don't care about them."

      expect_offense(<<~RUBY)
        def method(arg)
                   ^^^ #{message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(_arg)
          1
        end
      RUBY
    end

    it 'accepts an empty method with multiple unused parameters' do
      expect_no_offenses(<<~RUBY)
        def method(a, b, *others)
        end
      RUBY
    end

    it 'registers an offense for a non-empty method with multiple unused parameters' do
      (a_message, b_message, others_message) = %w[a b others].map do |arg|
        "Unused method argument - `#{arg}`. If it's necessary, use `_` or " \
          "`_#{arg}` as an argument name to indicate that it won't be used. " \
          "If it's unnecessary, remove it. " \
          'You can also write as `method(*)` if you want the method ' \
          "to accept any arguments but don't care about them."
      end

      expect_offense(<<~RUBY)
        def method(a, b, *others)
                          ^^^^^^ #{others_message}
                      ^ #{b_message}
                   ^ #{a_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(_a, _b, *_others)
          1
        end
      RUBY
    end
  end

  context 'when IgnoreNotImplementedMethods config parameter is set' do
    let(:cop_config) { { 'IgnoreNotImplementedMethods' => true } }

    it 'accepts a method with a single unused parameter & raises NotImplementedError' do
      expect_no_offenses(<<~RUBY)
        def method(arg)
          raise NotImplementedError
        end
      RUBY
    end

    it 'accepts a method with a single unused parameter & raises NotImplementedError, message' do
      expect_no_offenses(<<~RUBY)
        def method(arg)
          raise NotImplementedError, message
        end
      RUBY
    end

    it 'accepts a method with a single unused parameter & raises ::NotImplementedError' do
      expect_no_offenses(<<~RUBY)
        def method(arg)
          raise ::NotImplementedError
        end
      RUBY
    end

    it 'accepts a method with a single unused parameter & fails with message' do
      expect_no_offenses(<<~RUBY)
        def method(arg)
          fail "TODO"
        end
      RUBY
    end

    it 'accepts a method with a single unused parameter & fails without message' do
      expect_no_offenses(<<~RUBY)
        def method(arg)
          fail
        end
      RUBY
    end

    it 'accepts an empty singleton method with a single unused parameter &' \
       'raise NotImplementedError' do
      expect_no_offenses(<<~RUBY)
        def self.method(unused)
          raise NotImplementedError
        end
      RUBY
    end

    it 'registers an offense for a non-empty method with a single unused parameter' do
      message = "Unused method argument - `arg`. If it's necessary, use " \
                '`_` or `_arg` as an argument name to indicate that it ' \
                "won't be used. If it's unnecessary, remove it. You can also " \
                'write as `method(*)` if you want the method to accept any ' \
                "arguments but don't care about them."

      expect_offense(<<~RUBY)
        def method(arg)
                   ^^^ #{message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(_arg)
          1
        end
      RUBY
    end

    it 'accepts an empty method with multiple unused parameters' do
      expect_no_offenses(<<~RUBY)
        def method(a, b, *others)
          raise NotImplementedError
        end
      RUBY
    end

    it 'registers an offense for a non-empty method with multiple unused parameters' do
      (a_message, b_message, others_message) = %w[a b others].map do |arg|
        "Unused method argument - `#{arg}`. If it's necessary, use `_` or " \
          "`_#{arg}` as an argument name to indicate that it won't be used. " \
          "If it's unnecessary, remove it. " \
          'You can also write as `method(*)` if you want the method ' \
          "to accept any arguments but don't care about them."
      end

      expect_offense(<<~RUBY)
        def method(a, b, *others)
                          ^^^^^^ #{others_message}
                      ^ #{b_message}
                   ^ #{a_message}
          1
        end
      RUBY

      expect_correction(<<~RUBY)
        def method(_a, _b, *_others)
          1
        end
      RUBY
    end
  end
end
