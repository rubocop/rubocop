# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::Utils::CodeLengthCalculator do
  describe '#calculate' do
    context 'when method' do
      it 'calculates method length' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            # a = 2
            a = [
              3,
              4
            ]
          end
        RUBY

        length = described_class.new(source.ast, source).calculate
        expect(length).to eq(5)
      end

      it 'does not count blank lines' do
        source = parse_source(<<~RUBY)
          def test
            a = 1


            a = [
              3,
              4
            ]
          end
        RUBY

        length = described_class.new(source.ast, source).calculate
        expect(length).to eq(5)
      end

      it 'counts comments if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            # a = 2
            a = [
              3,
              4
            ]
          end
        RUBY

        length = described_class.new(source.ast, source, count_comments: true).calculate
        expect(length).to eq(6)
      end

      it 'folds arrays if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            a = [
              2,
              3
            ]
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[array]).calculate
        expect(length).to eq(2)
      end

      it 'folds hashes if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            a = {
              foo: :bar,
              baz: :quux
            }
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(2)
      end

      it 'folds hashes as method args if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            foo({
              foo: :bar,
              baz: :quux
            })
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(2)
      end

      it 'folds multiline hashes without braces as method args if asked' do
        source = parse_source(<<~RUBY)
          def test
            foo(foo: :bar,
              baz: :quux)
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'folds multiline hashes with line break after it as method args if asked' do
        source = parse_source(<<~RUBY)
          def test
            foo(foo: :bar,
              baz: :quux
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'folds multiline hashes with line break before it as method args if asked' do
        source = parse_source(<<~RUBY)
          def test
            foo(
              foo: :bar,
              baz: :quux)
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'folds hashes without braces as the one of method args if asked' do
        source = parse_source(<<~RUBY)
          def test
            foo(foo, foo: :bar,
              baz: :quux)
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'counts single line correctly if asked folding' do
        source = parse_source(<<~RUBY)
          def test
            foo(foo: :bar, baz: :quux)
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'counts single line without parentheses correctly if asked folding' do
        source = parse_source(<<~RUBY)
          def test
            foo foo: :bar, baz: :quux
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'counts single line hash with line breaks correctly if asked folding' do
        source = parse_source(<<~RUBY)
          def test
            foo(
              foo: :bar, baz: :quux
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'folds hashes with comment if asked' do
        source = parse_source(<<~RUBY)
          def test
            foo(
              # foo: :bar,
              baz: :quux
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(1)
      end

      it 'counts single line hash as the one of method args if asked folding' do
        source = parse_source(<<~RUBY)
          def test
            foo(
              bar,
              baz: :quux
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(4)
      end

      it 'counts single line hash as the one of method args with safe navigation operator if asked folding' do
        source = parse_source(<<~RUBY)
          def test
            foo&.bar(
              baz,
              qux: :quux
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(4)
      end

      it 'counts single line hash with other args correctly if asked folding' do
        source = parse_source(<<~RUBY)
          def test
            foo(
              { foo: :bar },
              bar, baz
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(4)
      end

      it 'folds hashes as method kwargs if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            foo(
              foo: :bar,
              baz: :quux
            )
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(2)
      end

      it 'folds heredocs if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            a = <<~HERE
              Lorem
              ipsum
              dolor
            HERE
            a = 3
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[heredoc]).calculate
        expect(length).to eq(3)
      end

      it 'folds method calls if asked' do
        source = parse_source(<<~RUBY)
          def test
            a = 1
            foo(
              1,
              2,
              3
            )
            obj&.foo(
              1,
              2
            )
            foo(1)
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[method_call]).calculate
        expect(length).to eq(4)
      end
    end

    context 'when class' do
      it 'calculates class length' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1
            # a = 2
            a = 3
          end
        RUBY

        length = described_class.new(source.ast, source).calculate
        expect(length).to eq(2)
      end

      it 'calculates singleton class length' do
        source = parse_source(<<~RUBY)
          class << self
            a = 1
            # a = 2
            a = 3
          end
        RUBY

        length = described_class.new(source.ast, source).calculate
        expect(length).to eq(2)
      end

      it 'does not count blank lines' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1


            a = 3
          end
        RUBY

        length = described_class.new(source.ast, source).calculate
        expect(length).to eq(2)
      end

      it 'counts comments if asked' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1
            # a = 2
            a = 3
          end
        RUBY

        length = described_class.new(source.ast, source, count_comments: true).calculate
        expect(length).to eq(3)
      end

      it 'folds arrays if asked' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1
            a = [
              2,
              3
            ]

            def test
              a = 1
              a = [
                2
              ]
            end
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[array]).calculate
        expect(length).to eq(6)
      end

      it 'folds hashes if asked' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1
            a = {
              foo: :bar,
              baz: :quux
            }

            def test
              a = 1
              a = {
                foo: :bar
              }
            end
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[hash]).calculate
        expect(length).to eq(6)
      end

      it 'folds heredocs if asked' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1
            a = <<~HERE
              Lorem
              ipsum
              dolor
            HERE

            def test
              a = 1
              a = <<~HERE
                Lorem
                ipsum
              HERE
              a = 3
            end
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[heredoc]).calculate
        expect(length).to eq(7)
      end

      it 'does not count lines of inner classes' do
        source = parse_source(<<~RUBY)
          class Test
            a = 1
            a = 2
            a = [
              3
            ]

            class Inner
              a = 1
              # a = 2
              a = [
                3,
                4
              ]
            end
          end
        RUBY

        length = described_class.new(source.ast, source, foldable_types: %i[array]).calculate
        expect(length).to eq(3)
      end
    end

    it 'raises when unknown foldable type is passed' do
      source = parse_source(<<~RUBY)
        def test
          a = 1
        end
      RUBY

      expect do
        described_class.new(source.ast, source, foldable_types: %i[unknown]).calculate
      end.to raise_error(ArgumentError, /Unknown foldable type/)
    end
  end
end
