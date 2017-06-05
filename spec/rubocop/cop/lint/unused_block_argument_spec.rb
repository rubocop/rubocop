# frozen_string_literal: true

describe RuboCop::Cop::Lint::UnusedBlockArgument, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'AllowUnusedKeywordArguments' => false } }

  context 'inspection' do
    before do
      inspect_source(cop, source)
    end

    context 'when a block takes multiple arguments' do
      context 'and an argument is unused' do
        let(:source) { <<-RUBY }
          hash = { foo: 'FOO', bar: 'BAR' }
          hash.each do |key, value|
            puts key
          end
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `value`. ' \
            "If it's necessary, use `_` or `_value` as an argument name " \
            "to indicate that it won't be used."
          )
          expect(cop.offenses.first.severity.name).to eq(:warning)
          expect(cop.offenses.first.line).to eq(2)
          expect(cop.highlights).to eq(['value'])
        end
      end

      context 'and all the arguments are unused' do
        let(:source) { <<-RUBY }
          hash = { foo: 'FOO', bar: 'BAR' }
          hash.each do |key, value|
            puts :something
          end
        RUBY

        it 'registers offenses and suggests omitting them' do
          expect(cop.offenses.size).to eq(2)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `key`. ' \
            "You can omit all the arguments if you don't care about them."
          )
          expect(cop.offenses.first.line).to eq(2)
          expect(cop.highlights).to eq(%w[key value])
        end
      end
    end

    context 'when a block takes single argument' do
      context 'and the argument is unused' do
        let(:source) { <<-RUBY }
          1.times do |index|
            puts :something
          end
        RUBY

        it 'registers an offense and suggests omitting that' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `index`. ' \
            "You can omit the argument if you don't care about it."
          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['index'])
        end
      end

      context 'and the method call is `define_method`' do
        let(:source) { <<-RUBY }
          define_method(:foo) do |bar|
            puts 'baz'
          end
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `bar`. ' \
            "If it's necessary, use `_` or `_bar` as an argument name " \
            "to indicate that it won't be used."
          )
          expect(cop.highlights).to eq(['bar'])
        end
      end
    end

    context 'when a block have a block local variable' do
      context 'and the variable is unused' do
        let(:source) { <<-RUBY }
          1.times do |index; block_local_variable|
            puts index
          end
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block local variable - `block_local_variable`.'
          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['block_local_variable'])
        end
      end
    end

    context 'when a lambda block takes arguments' do
      context 'and all the arguments are unused' do
        let(:source) { <<-RUBY }
          -> (foo, bar) { do_something }
        RUBY

        it 'registers offenses and suggests using a proc' do
          expect(cop.offenses.size).to eq(2)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `foo`. ' \
            "If it's necessary, use `_` or `_foo` as an argument name " \
            "to indicate that it won't be used. " \
            'Also consider using a proc without arguments instead of a ' \
            "lambda if you want it to accept any arguments but don't care " \
            'about them.'

          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(%w[foo bar])
        end
      end

      context 'and an argument is unused' do
        let(:source) { <<-RUBY }
          -> (foo, bar) { puts bar }
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `foo`. ' \
            "If it's necessary, use `_` or `_foo` as an argument name " \
            "to indicate that it won't be used."
          )
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(['foo'])
        end
      end
    end

    context 'when an underscore-prefixed block argument is not used' do
      let(:source) { <<-RUBY }
        1.times do |_index|
          puts 'foo'
        end
      RUBY

      it 'accepts' do
        expect_no_offenses(<<-RUBY.strip_indent)
          1.times do |_index|
            puts 'foo'
          end
        RUBY
      end
    end

    context 'when an optional keyword argument is unused' do
      context 'when the method call is `define_method`' do
        let(:source) { <<-RUBY }
          define_method(:foo) do |bar: 'default'|
            puts 'bar'
          end
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `bar`. ' \
            "If it's necessary, use `_` or `_bar` as an argument name " \
            "to indicate that it won't be used."
          )
          expect(cop.highlights).to eq(['bar'])
        end

        context 'when AllowUnusedKeywordArguments set' do
          let(:cop_config) { { 'AllowUnusedKeywordArguments' => true } }

          it 'does not care' do
            expect_no_offenses(<<-RUBY.strip_indent)
              define_method(:foo) do |bar: 'default'|
                puts 'bar'
              end
            RUBY
          end
        end
      end

      context 'when the method call is not `define_method`' do
        let(:source) { <<-RUBY }
          foo(:foo) do |bar: 'default'|
            puts 'bar'
          end
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(1)
          expect(cop.offenses.first.message).to eq(
            'Unused block argument - `bar`. ' \
            "You can omit the argument if you don't care about it."
          )
          expect(cop.highlights).to eq(['bar'])
        end

        context 'when AllowUnusedKeywordArguments set' do
          let(:cop_config) { { 'AllowUnusedKeywordArguments' => true } }

          it 'does not care' do
            expect_no_offenses(<<-RUBY.strip_indent)
              foo(:foo) do |bar: 'default'|
                puts 'bar'
              end
            RUBY
          end
        end
      end
    end

    context 'when a method argument is not used' do
      let(:source) { <<-RUBY }
        def some_method(foo)
        end
      RUBY

      it 'does not care' do
        expect_no_offenses(<<-RUBY.strip_indent)
          def some_method(foo)
          end
        RUBY
      end
    end

    context 'when a variable is not used' do
      let(:source) { <<-RUBY }
        1.times do
          foo = 1
        end
      RUBY

      it 'does not care' do
        expect_no_offenses(<<-RUBY.strip_indent)
          1.times do
            foo = 1
          end
        RUBY
      end
    end

    context 'in a method calling `binding` without arguments' do
      let(:source) { <<-RUBY }
        test do |key, value|
          puts something(binding)
        end
      RUBY

      it 'accepts all arguments' do
        expect_no_offenses(<<-RUBY.strip_indent)
          test do |key, value|
            puts something(binding)
          end
        RUBY
      end

      context 'inside a method definition' do
        let(:source) { <<-RUBY }
          test do |key, value|
            def other(a)
              puts something(binding)
            end
          end
        RUBY

        it 'registers offenses' do
          expect(cop.offenses.size).to eq 2
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(%w[key value])
        end
      end
    end

    context 'in a method calling `binding` with arguments' do
      context 'when a method argument is unused' do
        let(:source) { <<-RUBY }
          test do |key, value|
            puts something(binding(:other))
          end
        RUBY

        it 'registers an offense' do
          expect(cop.offenses.size).to eq(2)
          expect(cop.offenses.first.line).to eq(1)
          expect(cop.highlights).to eq(%w[key value])
        end
      end
    end

    context 'with an empty block' do
      let(:source) { <<-RUBY }
        super { |bar| }
      RUBY

      context 'when not configured to ignore empty blocks' do
        let(:cop_config) { { 'IgnoreEmptyBlocks' => false } }

        it 'does not register an offense' do
          expect(cop.offenses.size).to eq(1)
        end
      end

      context 'when configured to ignore empty blocks' do
        let(:cop_config) { { 'IgnoreEmptyBlocks' => true } }

        it 'does not register an offense' do
          expect_no_offenses('        super { |bar| }')
        end
      end
    end
  end

  context 'auto-correct' do
    it 'fixes single' do
      expect(autocorrect_source(cop, <<-SOURCE
      arr.map { |foo| stuff }
      SOURCE
                               )).to eq(<<-CORRECTED_SOURCE
      arr.map { |_foo| stuff }
      CORRECTED_SOURCE
                                       )
    end

    it 'fixes multiple' do
      expect(autocorrect_source(cop, <<-SOURCE
      hash.map { |key, val| stuff }
      SOURCE
                               )).to eq(<<-CORRECTED_SOURCE
      hash.map { |_key, _val| stuff }
      CORRECTED_SOURCE
                                       )
    end

    it 'preserves whitespace' do
      expect(autocorrect_source(cop, <<-SOURCE
      hash.map { |key,
                  val| stuff }
      SOURCE
                               )).to eq(<<-CORRECTED_SOURCE
      hash.map { |_key,
                  _val| stuff }
      CORRECTED_SOURCE
                                       )
    end

    it 'preserves splat' do
      expect(autocorrect_source(cop, <<-SOURCE
      obj.method { |foo, *bars, baz| stuff(foo, baz) }
      SOURCE
                               )).to eq(<<-CORRECTED_SOURCE
      obj.method { |foo, *_bars, baz| stuff(foo, baz) }
      CORRECTED_SOURCE
                                       )
    end

    it 'preserves default' do
      expect(autocorrect_source(cop, <<-SOURCE
      obj.method { |foo, bar = baz| stuff(foo) }
      SOURCE
                               )).to eq(<<-CORRECTED_SOURCE
      obj.method { |foo, _bar = baz| stuff(foo) }
      CORRECTED_SOURCE
                                       )
    end

    it 'ignores used' do
      original_source = <<-SOURCE
      obj.method { |foo, baz| stuff(foo, baz) }
      SOURCE

      expect(autocorrect_source(cop, original_source)).to eq(original_source)
    end
  end

  context 'when IgnoreEmptyBlocks config parameter is set' do
    subject(:cop) { described_class.new(config) }
    let(:cop_config) { { 'IgnoreEmptyBlocks' => true } }

    it 'accepts an empty block with a single unused parameter' do
      expect_no_offenses('->(arg) { }')
    end

    it 'registers an offense for a non-empty block with an unused parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->(arg) { 1 }
           ^^^ Unused block argument - `arg`. If it's necessary, use `_` or `_arg` as an argument name to indicate that it won't be used. Also consider using a proc without arguments instead of a lambda if you want it to accept any arguments but don't care about them.
      RUBY
    end

    it 'accepts an empty block with multiple unused parameters' do
      expect_no_offenses('->(arg1, arg2, *others) { }')
    end

    it 'registers an offense for a non-empty block with multiple unused args' do
      expect_offense(<<-RUBY.strip_indent)
        ->(arg1, arg2, *others) { 1 }
                        ^^^^^^ Unused block argument - `others`. If it's necessary, use `_` or `_others` as an argument name to indicate that it won't be used. Also consider using a proc without arguments instead of a lambda if you want it to accept any arguments but don't care about them.
                 ^^^^ Unused block argument - `arg2`. If it's necessary, use `_` or `_arg2` as an argument name to indicate that it won't be used. Also consider using a proc without arguments instead of a lambda if you want it to accept any arguments but don't care about them.
           ^^^^ Unused block argument - `arg1`. If it's necessary, use `_` or `_arg1` as an argument name to indicate that it won't be used. Also consider using a proc without arguments instead of a lambda if you want it to accept any arguments but don't care about them.
      RUBY
    end
  end
end
