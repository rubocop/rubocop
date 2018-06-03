# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnusedMethodArgument, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'AllowUnusedKeywordArguments' => false, 'IgnoreEmptyMethods' => false }
  end

  describe 'inspection' do
    context 'when a method takes multiple arguments' do
      context 'and an argument is unused' do
        it 'registers an offense' do
          message = 'Unused method argument - `foo`. ' \
                      "If it's necessary, use `_` or `_foo` " \
                      "as an argument name to indicate that it won't be used."

          expect_offense(<<-RUBY.strip_indent)
            def some_method(foo, bar)
                            ^^^ #{message}
              puts bar
            end
          RUBY
        end

        context 'and arguments are swap-assigned' do
          it 'accepts' do
            expect_no_offenses(<<-RUBY.strip_indent)
              def foo(a, b)
                a, b = b, a
              end
            RUBY
          end
        end

        context "and one argument is assigned to another, whilst other's " \
                  'value is not used' do
          it 'registers an offense' do
            message = "Unused method argument - `a`. If it's necessary, use " \
                        '`_` or `_a` as an argument name to indicate that ' \
                        "it won't be used."

            expect_offense(<<-RUBY.strip_indent)
              def foo(a, b)
                      ^ #{message}
                a, b = b, 42
              end
            RUBY
          end
        end
      end

      context 'and all the arguments are unused' do
        it 'registers offenses and suggests the use of `*`' do
          (foo_message, bar_message) = %w[foo bar].map do |arg|
            "Unused method argument - `#{arg}`. " \
            "If it's necessary, use `_` or `_#{arg}` " \
            "as an argument name to indicate that it won't be used. " \
            'You can also write as `some_method(*)` if you want the method ' \
            "to accept any arguments but don't care about them."
          end

          expect_offense(<<-RUBY.strip_indent)
            def some_method(foo, bar)
                                 ^^^ #{bar_message}
                            ^^^ #{foo_message}
            end
          RUBY
        end
      end
    end

    context 'when a required keyword argument is unused', ruby: 2.1 do
      it 'registers an offense but does not suggest underscore-prefix' do
        expect_offense(<<-RUBY.strip_indent)
          def self.some_method(foo, bar:)
                                    ^^^ Unused method argument - `bar`.
            puts foo
          end
        RUBY
      end
    end

    context 'when an optional keyword argument is unused' do
      it 'registers an offense but does not suggest underscore-prefix' do
        expect_offense(<<-RUBY.strip_indent)
          def self.some_method(foo, bar: 1)
                                    ^^^ Unused method argument - `bar`.
            puts foo
          end
        RUBY
      end

      context 'and AllowUnusedKeywordArguments set' do
        let(:cop_config) { { 'AllowUnusedKeywordArguments' => true } }

        it 'does not care' do
          expect_no_offenses(<<-RUBY.strip_indent)
            def self.some_method(foo, bar: 1)
              puts foo
            end
          RUBY
        end
      end
    end

    context 'when a singleton method argument is unused' do
      it 'registers an offense' do
        message = "Unused method argument - `foo`. If it's necessary, use " \
                    '`_` or `_foo` as an argument name to indicate that it ' \
                    "won't be used. You can also write as `some_method(*)` " \
                    'if you want the method to accept any arguments but ' \
                    "don't care about them."

        expect_offense(<<-RUBY.strip_indent)
          def self.some_method(foo)
                               ^^^ #{message}
          end
        RUBY
      end
    end

    context 'when an underscore-prefixed method argument is unused' do
      let(:source) { <<-RUBY.strip_indent }
        def some_method(_foo)
        end
      RUBY

      it 'accepts' do
        expect_no_offenses(source)
      end
    end

    context 'when a method argument is used' do
      let(:source) { <<-RUBY.strip_indent }
        def some_method(foo)
          puts foo
        end
      RUBY

      it 'accepts' do
        expect_no_offenses(source)
      end
    end

    context 'when a variable is unused' do
      let(:source) { <<-RUBY.strip_indent }
        def some_method
          foo = 1
        end
      RUBY

      it 'does not care' do
        expect_no_offenses(source)
      end
    end

    context 'when a block argument is unused' do
      let(:source) { <<-RUBY.strip_indent }
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
          expect_no_offenses(<<-RUBY.strip_indent)
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
                      "it won't be used. You can also write as " \
                      '`some_method(*)` if you want the method to accept any ' \
                      "arguments but don't care about them."

          expect_offense(<<-RUBY.strip_indent)
            def some_method(foo)
                            ^^^ #{message}
              super(:something)
            end
          RUBY
        end
      end
    end

    context 'in a method calling `binding` without arguments' do
      let(:source) { <<-RUBY.strip_indent }
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
          'used. You can also write as `some_method(*)` if you want the ' \
          "method to accept any arguments but don't care about them."
        end

        it 'registers offenses' do
          expect_offense(<<-RUBY.strip_indent)
            def some_method(foo, bar)
                                 ^^^ #{bar_message}
                            ^^^ #{foo_message}
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
                      "won't be used. You can also write as `some_method(*)` " \
                      'if you want the method to accept any arguments but ' \
                      "don't care about them."

          expect_offense(<<-RUBY.strip_indent)
            def some_method(foo)
                            ^^^ #{message}
              binding(:something)
            end
          RUBY
        end
      end
    end
  end

  describe 'auto-correction' do
    let(:corrected_source) { autocorrect_source(source) }

    context 'when multiple arguments are unused' do
      let(:source) { <<-RUBY }
        def some_method(foo, bar)
        end
      RUBY

      let(:expected_source) { <<-RUBY }
        def some_method(_foo, _bar)
        end
      RUBY

      it 'adds underscore-prefix to them' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when only a part of arguments is unused' do
      let(:source) { <<-RUBY }
        def some_method(foo, bar)
          puts foo
        end
      RUBY

      let(:expected_source) { <<-RUBY }
        def some_method(foo, _bar)
          puts foo
        end
      RUBY

      it 'modifies only the unused one' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when there is some whitespace around the argument' do
      let(:source) { <<-RUBY }
        def some_method(foo,
            bar)
          puts foo
        end
      RUBY

      let(:expected_source) { <<-RUBY }
        def some_method(foo,
            _bar)
          puts foo
        end
      RUBY

      it 'preserves the whitespace' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when a splat argument is unused' do
      let(:source) { <<-RUBY }
        def some_method(foo, *bar)
          puts foo
        end
      RUBY

      let(:expected_source) { <<-RUBY }
        def some_method(foo, *_bar)
          puts foo
        end
      RUBY

      it 'preserves the splat' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when an unused argument has default value' do
      let(:source) { <<-RUBY }
        def some_method(foo, bar = 1)
          puts foo
        end
      RUBY

      let(:expected_source) { <<-RUBY }
        def some_method(foo, _bar = 1)
          puts foo
        end
      RUBY

      it 'preserves the default value' do
        expect(corrected_source).to eq(expected_source)
      end
    end

    context 'when a keyword argument is unused' do
      let(:source) { <<-RUBY }
        def some_method(foo, bar: 1)
          puts foo
        end
      RUBY

      it 'ignores that since modifying the name changes the method interface' do
        expect(corrected_source).to eq(source)
      end
    end

    context 'when a trailing block argument is unused' do
      let(:source) { <<-RUBY }
        def some_method(foo, bar, &block)
          foo + bar
        end
      RUBY

      let(:expected_source) { <<-RUBY }
        def some_method(foo, bar)
          foo + bar
        end
      RUBY

      it 'removes the unused block arg' do
        expect(corrected_source).to eq(expected_source)
      end
    end
  end

  context 'when IgnoreEmptyMethods config parameter is set' do
    let(:cop_config) { { 'IgnoreEmptyMethods' => true } }

    it 'accepts an empty method with a single unused parameter' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method(arg)
        end
      RUBY
    end

    it 'accepts an empty singleton method with a single unused parameter' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.method(unused)
        end
      RUBY
    end

    it 'registers an offense for a non-empty method with a single unused ' \
        'parameter' do

      message = "Unused method argument - `arg`. If it's necessary, use " \
                  '`_` or `_arg` as an argument name to indicate that it ' \
                  "won't be used. You can also write as `method(*)` if you " \
                  "want the method to accept any arguments but don't care " \
                  'about them.'

      expect_offense(<<-RUBY.strip_indent)
        def method(arg)
                   ^^^ #{message}
          1
        end
      RUBY
    end

    it 'accepts an empty method with multiple unused parameters' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method(a, b, *others)
        end
      RUBY
    end

    it 'registers an offense for a non-empty method with multiple unused ' \
        'parameters' do
      (a_message, b_message, others_message) = %w[a b others].map do |arg|
        "Unused method argument - `#{arg}`. If it's necessary, use `_` or " \
        "`_#{arg}` as an argument name to indicate that it won't be used. " \
        'You can also write as `method(*)` if you want the method ' \
        "to accept any arguments but don't care about them."
      end

      expect_offense(<<-RUBY.strip_indent)
        def method(a, b, *others)
                          ^^^^^^ #{others_message}
                      ^ #{b_message}
                   ^ #{a_message}
          1
        end
      RUBY
    end
  end
end
