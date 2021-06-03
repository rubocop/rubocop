# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnusedBlockArgument, :config do
  let(:cop_config) { { 'AllowUnusedKeywordArguments' => false } }

  context 'inspection' do
    context 'when a block takes multiple arguments' do
      context 'and an argument is unused' do
        it 'registers an offense' do
          message = "Unused block argument - `value`. If it's " \
                    'necessary, use `_` or `_value` as an argument ' \
                    "name to indicate that it won't be used."

          expect_offense(<<~RUBY)
            hash.each do |key, value|
                               ^^^^^ #{message}
              puts key
            end
          RUBY

          expect_correction(<<~RUBY)
            hash.each do |key, _value|
              puts key
            end
          RUBY
        end
      end

      context 'and all arguments are used' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            obj.method { |foo, bar| stuff(foo, bar) }
          RUBY
        end
      end

      context 'and arguments are swap-assigned' do
        it 'accepts' do
          expect_no_offenses(<<~RUBY)
            hash.each do |key, value|
              key, value = value, key
            end
          RUBY
        end
      end

      context "and one argument is assigned to another, whilst other's value is not used" do
        it 'registers an offense' do
          message = 'Unused block argument - `key`. ' \
                    "If it's necessary, use `_` or `_key` as an argument " \
                    "name to indicate that it won't be used."

          expect_offense(<<~RUBY)
            hash.each do |key, value|
                          ^^^ #{message}
              key, value = value, 42
            end
          RUBY

          expect_correction(<<~RUBY)
            hash.each do |_key, value|
              key, value = value, 42
            end
          RUBY
        end
      end

      context 'and a splat argument is unused' do
        it 'registers an offense and preserves splat' do
          message = 'Unused block argument - `bars`. ' \
                    "If it's necessary, use `_` or `_bars` as an argument " \
                    "name to indicate that it won't be used."

          expect_offense(<<~RUBY)
            obj.method { |foo, *bars, baz| stuff(foo, baz) }
                                ^^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            obj.method { |foo, *_bars, baz| stuff(foo, baz) }
          RUBY
        end
      end

      context 'and an argument with default value is unused' do
        it 'registers an offense and preserves default value' do
          message = 'Unused block argument - `bar`. ' \
                    "If it's necessary, use `_` or `_bar` as an argument " \
                    "name to indicate that it won't be used."

          expect_offense(<<~RUBY)
            obj.method do |foo, bar = baz|
                                ^^^ #{message}
              stuff(foo)
            end
          RUBY

          expect_correction(<<~RUBY)
            obj.method do |foo, _bar = baz|
              stuff(foo)
            end
          RUBY
        end
      end

      context 'and all the arguments are unused' do
        it 'registers offenses and suggests omitting them' do
          (key_message, value_message) = %w[key value].map do |arg|
            "Unused block argument - `#{arg}`. You can omit all the " \
              "arguments if you don't care about them."
          end

          expect_offense(<<~RUBY)
            hash = { foo: 'FOO', bar: 'BAR' }
            hash.each do |key, value|
                               ^^^^^ #{value_message}
                          ^^^ #{key_message}
              puts :something
            end
          RUBY

          expect_correction(<<~RUBY)
            hash = { foo: 'FOO', bar: 'BAR' }
            hash.each do |_key, _value|
              puts :something
            end
          RUBY
        end

        context 'and unused arguments span multiple lines' do
          it 'registers offenses and suggests omitting them' do
            key_message, value_message = %w[key value].map do |arg|
              "Unused block argument - `#{arg}`. You can omit all the " \
                "arguments if you don't care about them."
            end

            expect_offense(<<~RUBY)
              hash.each do |key,
                            ^^^ #{key_message}
                            value|
                            ^^^^^ #{value_message}
                puts :something
              end
            RUBY

            expect_correction(<<~RUBY)
              hash.each do |_key,
                            _value|
                puts :something
              end
            RUBY
          end
        end
      end
    end

    context 'when a block takes single argument' do
      context 'and the argument is unused' do
        it 'registers an offense and suggests omitting that' do
          message = 'Unused block argument - `index`. ' \
                    "You can omit the argument if you don't care about it."

          expect_offense(<<~RUBY)
            1.times do |index|
                        ^^^^^ #{message}
              puts :something
            end
          RUBY

          expect_correction(<<~RUBY)
            1.times do |_index|
              puts :something
            end
          RUBY
        end
      end

      context 'and the method call is `define_method`' do
        it 'registers an offense' do
          message = 'Unused block argument - `bar`. ' \
                    "If it's necessary, use `_` or `_bar` as an argument " \
                    "name to indicate that it won't be used."

          expect_offense(<<~RUBY)
            define_method(:foo) do |bar|
                                    ^^^ #{message}
              puts 'baz'
            end
          RUBY

          expect_correction(<<~RUBY)
            define_method(:foo) do |_bar|
              puts 'baz'
            end
          RUBY
        end
      end
    end

    context 'when a block have a block local variable' do
      context 'and the variable is unused' do
        it 'registers an offense' do
          expect_offense(<<~RUBY)
            1.times do |index; block_local_variable|
                               ^^^^^^^^^^^^^^^^^^^^ Unused block local variable - `block_local_variable`.
              puts index
            end
          RUBY

          expect_correction(<<~RUBY)
            1.times do |index; _block_local_variable|
              puts index
            end
          RUBY
        end
      end

      context 'and the variable is used' do
        it 'does not register offense' do
          expect_no_offenses(<<~RUBY)
            1.times do |index; x|
              x = 10
              puts index
            end
          RUBY
        end
      end
    end

    context 'when a lambda block takes arguments' do
      context 'and all the arguments are unused' do
        it 'registers offenses and suggests using a proc' do
          (foo_message, bar_message) = %w[foo bar].map do |arg|
            "Unused block argument - `#{arg}`. " \
              "If it's necessary, use `_` or `_#{arg}` as an argument name " \
              "to indicate that it won't be used. " \
              'Also consider using a proc without arguments instead of a ' \
              "lambda if you want it to accept any arguments but don't care " \
              'about them.'
          end

          expect_offense(<<~RUBY)
            -> (foo, bar) { do_something }
                     ^^^ #{bar_message}
                ^^^ #{foo_message}
          RUBY

          expect_correction(<<~RUBY)
            -> (_foo, _bar) { do_something }
          RUBY
        end
      end

      context 'and an argument is unused' do
        it 'registers an offense' do
          message = 'Unused block argument - `foo`. ' \
                    "If it's necessary, use `_` or `_foo` as an argument " \
                    "name to indicate that it won't be used."

          expect_offense(<<~RUBY)
            -> (foo, bar) { puts bar }
                ^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            -> (_foo, bar) { puts bar }
          RUBY
        end
      end
    end

    context 'when an underscore-prefixed block argument is not used' do
      it 'accepts' do
        expect_no_offenses(<<~RUBY)
          1.times do |_index|
            puts 'foo'
          end
        RUBY
      end
    end

    context 'when an optional keyword argument is unused' do
      context 'when the method call is `define_method`' do
        it 'registers an offense' do
          message = 'Unused block argument - `bar`. ' \
                    "If it's necessary, use `_` or `_bar` as an argument name " \
                    "to indicate that it won't be used."

          expect_offense(<<~RUBY)
            define_method(:foo) do |bar: 'default'|
                                    ^^^ #{message}
              puts 'bar'
            end
          RUBY

          expect_no_corrections
        end

        context 'when AllowUnusedKeywordArguments set' do
          let(:cop_config) { { 'AllowUnusedKeywordArguments' => true } }

          it 'does not care' do
            expect_no_offenses(<<~RUBY)
              define_method(:foo) do |bar: 'default'|
                puts 'bar'
              end
            RUBY
          end
        end
      end

      context 'when the method call is not `define_method`' do
        it 'registers an offense' do
          message = 'Unused block argument - `bar`. ' \
                    "You can omit the argument if you don't care about it."

          expect_offense(<<~RUBY)
            foo(:foo) do |bar: 'default'|
                          ^^^ #{message}
              puts 'bar'
            end
          RUBY

          expect_no_corrections
        end

        context 'when AllowUnusedKeywordArguments set' do
          let(:cop_config) { { 'AllowUnusedKeywordArguments' => true } }

          it 'does not care' do
            expect_no_offenses(<<~RUBY)
              foo(:foo) do |bar: 'default'|
                puts 'bar'
              end
            RUBY
          end
        end
      end
    end

    context 'when a method argument is not used' do
      it 'does not care' do
        expect_no_offenses(<<~RUBY)
          def some_method(foo)
          end
        RUBY
      end
    end

    context 'when a variable is not used' do
      it 'does not care' do
        expect_no_offenses(<<~RUBY)
          1.times do
            foo = 1
          end
        RUBY
      end
    end

    context 'in a method calling `binding` without arguments' do
      it 'accepts all arguments' do
        expect_no_offenses(<<~RUBY)
          test do |key, value|
            puts something(binding)
          end
        RUBY
      end

      context 'inside a method definition' do
        it 'registers offenses' do
          (key_message, value_message) = %w[key value].map do |arg|
            "Unused block argument - `#{arg}`. You can omit all the " \
              "arguments if you don't care about them."
          end

          expect_offense(<<~RUBY)
            test do |key, value|
                          ^^^^^ #{value_message}
                     ^^^ #{key_message}
              def other(a)
                puts something(binding)
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            test do |_key, _value|
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
          (key_message, value_message) = %w[key value].map do |arg|
            "Unused block argument - `#{arg}`. You can omit all the " \
              "arguments if you don't care about them."
          end

          expect_offense(<<~RUBY)
            test do |key, value|
                          ^^^^^ #{value_message}
                     ^^^ #{key_message}
              puts something(binding(:other))
            end
          RUBY

          expect_correction(<<~RUBY)
            test do |_key, _value|
              puts something(binding(:other))
            end
          RUBY
        end
      end
    end

    context 'with an empty block' do
      context 'when not configured to ignore empty blocks' do
        let(:cop_config) { { 'IgnoreEmptyBlocks' => false } }

        it 'registers an offense' do
          message = 'Unused block argument - `bar`. You can omit the ' \
                    "argument if you don't care about it."

          expect_offense(<<~RUBY)
            super { |bar| }
                     ^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            super { |_bar| }
          RUBY
        end
      end

      context 'when configured to ignore empty blocks' do
        let(:cop_config) { { 'IgnoreEmptyBlocks' => true } }

        it 'does not register an offense' do
          expect_no_offenses('super { |bar| }')
        end
      end
    end
  end

  context 'when IgnoreEmptyBlocks config parameter is set' do
    let(:cop_config) { { 'IgnoreEmptyBlocks' => true } }

    it 'accepts an empty block with a single unused parameter' do
      expect_no_offenses('->(arg) { }')
    end

    it 'registers an offense for a non-empty block with an unused parameter' do
      message = "Unused block argument - `arg`. If it's necessary, use `_` " \
                "or `_arg` as an argument name to indicate that it won't " \
                'be used. Also consider using a proc without arguments ' \
                'instead of a lambda if you want it to accept any arguments ' \
                "but don't care about them."

      expect_offense(<<~RUBY)
        ->(arg) { 1 }
           ^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        ->(_arg) { 1 }
      RUBY
    end

    it 'accepts an empty block with multiple unused parameters' do
      expect_no_offenses('->(arg1, arg2, *others) { }')
    end

    it 'registers an offense for a non-empty block with multiple unused args' do
      (arg1_message, arg2_message, others_message) = %w[arg1 arg2 others]
                                                     .map do |arg|
        "Unused block argument - `#{arg}`. If it's necessary, use `_` or " \
          "`_#{arg}` as an argument name to indicate that it won't be used. " \
          'Also consider using a proc without arguments instead of a lambda ' \
          "if you want it to accept any arguments but don't care about them."
      end

      expect_offense(<<~RUBY)
        ->(arg1, arg2, *others) { 1 }
                        ^^^^^^ #{others_message}
                 ^^^^ #{arg2_message}
           ^^^^ #{arg1_message}
      RUBY

      expect_correction(<<~RUBY)
        ->(_arg1, _arg2, *_others) { 1 }
      RUBY
    end
  end
end
