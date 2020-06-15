# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::Utils::CodeLengthCalculator do
  describe '#calculate' do
    context 'when method' do
      it 'calculates method length' do
        node = parse_source(<<~RUBY).ast
          def test
            a = 1
            # a = 2
            a = [
              3,
              4
            ]
          end
        RUBY

        length = described_class.new(node).calculate
        expect(length).to eq(5)
      end

      it 'does not count blank lines' do
        node = parse_source(<<~RUBY).ast
          def test
            a = 1


            a = [
              3,
              4
            ]
          end
        RUBY

        length = described_class.new(node).calculate
        expect(length).to eq(5)
      end

      it 'counts comments if asked' do
        node = parse_source(<<~RUBY).ast
          def test
            a = 1
            # a = 2
            a = [
              3,
              4
            ]
          end
        RUBY

        length = described_class.new(node, count_comments: true).calculate
        expect(length).to eq(6)
      end

      it 'folds arrays if asked' do
        node = parse_source(<<~RUBY).ast
          def test
            a = 1
            a = [
              2,
              3
            ]
          end
        RUBY

        length = described_class.new(node, foldable_types: %i[array]).calculate
        expect(length).to eq(2)
      end

      it 'folds hashes if asked' do
        node = parse_source(<<~RUBY).ast
          def test
            a = 1
            a = {
              foo: :bar,
              baz: :quux
            }
          end
        RUBY

        length = described_class.new(node, foldable_types: %i[hash]).calculate
        expect(length).to eq(2)
      end

      it 'folds heredocs if asked' do
        node = parse_source(<<~RUBY).ast
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

        length = described_class.new(node, foldable_types: %i[heredoc]).calculate
        expect(length).to eq(3)
      end
    end

    context 'when class' do
      it 'calculates class length' do
        node = parse_source(<<~RUBY).ast
          class Test
            a = 1
            # a = 2
            a = 3
          end
        RUBY

        length = described_class.new(node).calculate
        expect(length).to eq(2)
      end

      it 'does not count blank lines' do
        node = parse_source(<<~RUBY).ast
          class Test
            a = 1


            a = 3
          end
        RUBY

        length = described_class.new(node).calculate
        expect(length).to eq(2)
      end

      it 'counts comments if asked' do
        node = parse_source(<<~RUBY).ast
          class Test
            a = 1
            # a = 2
            a = 3
          end
        RUBY

        length = described_class.new(node, count_comments: true).calculate
        expect(length).to eq(3)
      end

      it 'folds arrays if asked' do
        node = parse_source(<<~RUBY).ast
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

        length = described_class.new(node, foldable_types: %i[array]).calculate
        expect(length).to eq(6)
      end

      it 'folds hashes if asked' do
        node = parse_source(<<~RUBY).ast
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

        length = described_class.new(node, foldable_types: %i[hash]).calculate
        expect(length).to eq(6)
      end

      it 'folds heredocs if asked' do
        node = parse_source(<<~RUBY).ast
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

        length = described_class.new(node, foldable_types: %i[heredoc]).calculate
        expect(length).to eq(7)
      end

      it 'does not count lines of inner classes' do
        node = parse_source(<<~RUBY).ast
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

        length = described_class.new(node, foldable_types: %i[array]).calculate
        expect(length).to eq(3)
      end
    end

    it 'raises when unknown foldable type is passed' do
      node = parse_source(<<~RUBY).ast
        def test
          a = 1
        end
      RUBY

      expect do
        described_class.new(node, foldable_types: %i[unknown]).calculate
      end.to raise_error(ArgumentError, /Unknown foldable type/)
    end
  end
end
