# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::Utils::AbcSizeCalculator do
  describe '#calculate' do
    subject(:vector) { described_class.calculate(node).last }

    let(:node) { parse_source(source).ast }

    context 'multiple calls with return' do
      let(:source) { <<~RUBY }
        def method_name
          return x, y, z
        end
      RUBY

      it { is_expected.to eq '<0, 3, 0>' }
    end

    context 'assignment with ternary operator' do
      let(:source) { <<~RUBY }
        def method_name
          a = b ? c : d
          e = f ? g : h
        end
      RUBY

      it { is_expected.to eq '<2, 6, 2>' }
    end

    context 'if and arithmetic operations' do
      let(:source) { <<~RUBY }
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

      it { is_expected.to eq '<2, 8, 4>' }
    end

    context 'same with extra condition' do
      let(:source) { <<~RUBY }
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

      it { is_expected.to eq '<2, 9, 5>' }
    end

    context 'elsif vs else if' do
      context 'elsif' do
        let(:source) { <<~RUBY }
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

        it { is_expected.to eq '<0, 5, 3>' }
      end

      context 'else if' do
        let(:source) { <<~RUBY }
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

        it { is_expected.to eq '<0, 5, 4>' }
      end
    end
  end
end
