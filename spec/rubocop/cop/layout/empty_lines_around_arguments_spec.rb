# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLinesAroundArguments, :config do
  let(:empty_line_annotation) { '^{} Empty line detected around arguments.' }

  context 'when extra lines' do
    it 'registers and autocorrects offense for empty line before arg' do
      expect_offense(<<~RUBY)
        foo(

        #{empty_line_annotation}
          bar
        )
      RUBY

      expect_correction(<<~RUBY)
        foo(
          bar
        )
      RUBY
    end

    it 'registers and autocorrects offense for empty line after arg' do
      expect_offense(<<~RUBY)
        bar(
          [baz, qux]

        #{empty_line_annotation}
        )
      RUBY

      expect_correction(<<~RUBY)
        bar(
          [baz, qux]
        )
      RUBY
    end

    it 'registers and autocorrects offense for empty line between args' do
      expect_offense(<<~RUBY)
        foo.do_something(
          baz,

        #{empty_line_annotation}
          qux: 0
        )
      RUBY

      expect_correction(<<~RUBY)
        foo.do_something(
          baz,
          qux: 0
        )
      RUBY
    end

    it 'registers and autocorrects offenses when multiple empty lines are detected' do
      expect_offense(<<~RUBY)
        foo(
          baz,

        #{empty_line_annotation}
          qux,

        #{empty_line_annotation}
          biz,

        #{empty_line_annotation}
        )
      RUBY

      expect_correction(<<~RUBY)
        foo(
          baz,
          qux,
          biz,
        )
      RUBY
    end

    it 'registers and autocorrects offense when args start on definition line' do
      expect_offense(<<~RUBY)
        foo(biz,

        #{empty_line_annotation}
            baz: 0)
      RUBY

      expect_correction(<<~RUBY)
        foo(biz,
            baz: 0)
      RUBY
    end

    it 'registers and autocorrects offense when empty line between normal arg & block arg' do
      expect_offense(<<~RUBY)
        Foo.prepend(
          a,

        #{empty_line_annotation}
          Module.new do
            def something; end

            def anything; end
          end
        )
      RUBY

      expect_correction(<<~RUBY)
        Foo.prepend(
          a,
          Module.new do
            def something; end

            def anything; end
          end
        )
      RUBY
    end

    it 'registers and autocorrects offense on correct line for single offense example' do
      expect_offense(<<~RUBY)
        class Foo

          include Bar

          def baz(qux)
            fizz(
              qux,

        #{empty_line_annotation}
              10
            )
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo

          include Bar

          def baz(qux)
            fizz(
              qux,
              10
            )
          end
        end
      RUBY
    end

    it 'registers and autocorrects offense on correct lines for multi-offense example' do
      expect_offense(<<~RUBY)
        something(1, 5)
        something_else

        foo(biz,

        #{empty_line_annotation}
            qux)

        quux.map do

        end.another.thing(

        #{empty_line_annotation}
          [baz]
        )
      RUBY

      expect_correction(<<~RUBY)
        something(1, 5)
        something_else

        foo(biz,
            qux)

        quux.map do

        end.another.thing(
          [baz]
        )
      RUBY
    end

    context 'when using safe navigation operator' do
      it 'registers and autocorrects offense for empty line before arg' do
        expect_offense(<<~RUBY)
          receiver&.foo(

          #{empty_line_annotation}
            bar
          )
        RUBY

        expect_correction(<<~RUBY)
          receiver&.foo(
            bar
          )
        RUBY
      end
    end

    it 'registers autocorrects empty line when args start on definition line' do
      expect_offense(<<~RUBY)
        bar(qux,

        #{empty_line_annotation}
            78)
      RUBY

      expect_correction(<<~RUBY)
        bar(qux,
            78)
      RUBY
    end
  end

  context 'when no extra lines' do
    it 'accepts one line methods' do
      expect_no_offenses(<<~RUBY)
        foo(bar)
      RUBY
    end

    it 'accepts multiple listed mixed args' do
      expect_no_offenses(<<~RUBY)
        foo(
          bar,
          [],
          baz = nil,
          qux: 2
        )
      RUBY
    end

    it 'accepts listed args starting on definition line' do
      expect_no_offenses(<<~RUBY)
        foo(bar,
            [],
            qux: 2)
      RUBY
    end

    it 'accepts block argument with empty line' do
      expect_no_offenses(<<~RUBY)
        Foo.prepend(Module.new do
          def something; end

          def anything; end
        end)
      RUBY
    end

    it 'accepts method with argument that trails off block' do
      expect_no_offenses(<<~RUBY)
        fred.map do
          <<-EOT
            bar

            foo
          EOT
        end.join("\n")
      RUBY
    end

    it 'accepts method with no arguments that trails off block' do
      expect_no_offenses(<<~RUBY)
        foo.baz do

          bar
        end.compact
      RUBY
    end

    it 'accepts method with argument that trails off heredoc' do
      expect_no_offenses(<<~RUBY)
        bar(<<-DOCS)
          foo

        DOCS
          .call!(true)
      RUBY
    end

    it 'accepts when blank line is inserted between method with arguments and receiver' do
      expect_no_offenses(<<~RUBY)
        foo.

          bar(arg)
      RUBY
    end

    it 'accepts multiline style argument for method call without selector' do
      expect_no_offenses(<<~RUBY)
        foo.(
          arg
        )
      RUBY
    end

    context 'with one argument' do
      it 'ignores empty lines inside of method arguments' do
        expect_no_offenses(<<~RUBY)
          private(def bar

            baz
          end)
        RUBY
      end
    end

    context 'with multiple arguments' do
      it 'ignores empty lines inside of method arguments' do
        expect_no_offenses(<<~RUBY)
          foo(:bar, [1,

                     2]
          )
        RUBY
      end
    end
  end
end
