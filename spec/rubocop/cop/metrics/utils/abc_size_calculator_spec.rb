# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::Utils::AbcSizeCalculator do
  describe '#calculate' do
    context '0 assignments, 3 branches, 0 conditions' do
      it 'returns 3' do
        node = parse_source(<<-RUBY.strip_indent).ast
          def method_name
            return x, y, z
          end
        RUBY
        expect(described_class.calculate(node)).to be_within(0.001).of(3)
      end
    end

    context '2 assignments, 6 branches, 2 conditions' do
      it 'returns 6.63' do
        node = parse_source(<<-RUBY.strip_indent).ast
          def method_name
            a = b ? c : d
            e = f ? g : h
          end
        RUBY
        expect(described_class.calculate(node)).to be_within(0.001).of(6.63)
      end
    end

    context '2 assignments, 8 branches, 4 conditions' do
      it 'returns 8.77' do
        node = parse_source(<<-RUBY.strip_indent).ast
          def method_name
            a = b ? c : d
            if a
              a
            else
              e = f ? g : h

              # The * and - are counted as branches because they are parsed as
              # `send` nodes. YARV might optimize them, but to `parser` they
              # are methods.
              e * 2.4 - 781.0
            end
          end
        RUBY
        expect(described_class.calculate(node)).to be_within(0.001).of(9.17)
      end
    end

    context '2 assignments, 9 branches, 5 conditions' do
      it 'returns 10.49' do
        node = parse_source(<<-RUBY.strip_indent).ast
          def method_name
            a = b ? c : d
            if a < b
              a
            else
              e = f ? g : h

              # The * and - are counted as branches because they are parsed as
              # `send` nodes. YARV might optimize them, but to `parser` they
              # are methods.
              e * 2.4 - 781.0
            end
          end
        RUBY
        expect(described_class.calculate(node)).to be_within(0.001).of(10.49)
      end
    end

    context 'elsif vs else if' do
      it 'counts elsif as 1 condition' do
        node = parse_source(<<-RUBY.strip_indent).ast
          def method_name
            if foo        # 0, 1, 1
              bar         # 0, 2, 1
            elsif baz     # 0, 3, 2
              qux         # 0, 4, 2
            else          # 0, 4, 3
              foobar      # 0, 5, 3
            end
          end
        RUBY

        expect(described_class.calculate(node)).to be_within(0.001).of(5.83)
      end

      it 'counts else if as 2 conditions' do
        node = parse_source(<<-RUBY.strip_indent).ast
          def method_name
            if foo        # 0, 1, 1
              bar         # 0, 2, 1
            else          # 0, 2, 2
              if baz      # 0, 3, 3
                qux       # 0, 4, 3
              else        # 0, 4, 4
                foobar    # 0, 5, 4
              end
            end
          end
        RUBY

        expect(described_class.calculate(node)).to be_within(0.001).of(6.4)
      end
    end
  end
end
