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

    context '2 assignments, 8 branches, 3 conditions' do
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
        expect(described_class.calculate(node)).to be_within(0.001).of(8.77)
      end
    end
  end
end
