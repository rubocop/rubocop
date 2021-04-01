# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::Utils::AbcSizeCalculator do
  describe '#calculate' do
    subject(:vector) do
      described_class.calculate(node,
                                discount_repeated_attributes: discount_repeated_attributes).last
    end

    let(:discount_repeated_attributes) { false }

    let(:node) { parse_source(source).ast }

    context 'multiple calls with return' do
      let(:source) { <<~RUBY }
        def method_name
          return x, y, z
        end
      RUBY

      it { is_expected.to eq '<0, 3, 0>' }
    end

    context 'with +=' do
      let(:source) { <<~RUBY }
        def method_name
          x = nil
          x += 1
        end
      RUBY

      it { is_expected.to eq '<2, 0, 0>' }
    end

    context 'with += for setters' do
      let(:source) { <<~RUBY }
        def method_name
          foo.bar += 1
        end
      RUBY

      it { is_expected.to eq '<1, 2, 0>' }
    end

    context 'with ||=' do
      let(:source) { <<~RUBY }
        def method_name
          x = nil
          x ||= 1
        end
      RUBY

      it { is_expected.to eq '<2, 0, 1>' }
    end

    context 'with ||= on a constant' do
      let(:source) { <<~RUBY }
        def method_name
          self::FooModule ||= Mod
        end
      RUBY

      it { is_expected.to eq '<1, 0, 1>' }
    end

    context 'with &&=' do
      let(:source) { <<~RUBY }
        def method_name
          x = nil
          x &&= 1
        end
      RUBY

      it { is_expected.to eq '<2, 0, 1>' }
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

    context 'with a block' do
      let(:source) { <<~RUBY }
        def method_name
          x = foo    # <1, 1, 0>
          bar do     # <1, 2, 0>  (+1 for bar, 0 for non-empty block)
            y = baz  # <2, 3, 0>
          end
        end
      RUBY

      it { is_expected.to eq '<2, 3, 0>' }
    end

    context 'same but with 7 arguments' do
      let(:source) { <<~RUBY }
        def method_name
          x = foo
          bar do |a, (b, c), d = 42, *e, f: 42, **g|
            y = baz
          end
        end
      RUBY

      it { is_expected.to eq '<9, 3, 0>' }
    end

    context 'with unused assignments' do
      let(:source) { <<~RUBY }
        def method_name
          _, _ignored, foo, = [1, 2, 3]  # <1, 0, 0>
          bar do |_, (only_real_assignment, _unused), *, **| # <+1, 1, 0>
            only_real_assignment
          end
        end
      RUBY

      it { is_expected.to eq '<2, 1, 0>' }
    end

    context 'with a known iterating block' do
      let(:source) { <<~RUBY }
        def method_name
          x = foo       # <1, 1, 0>
          x.each do     # <1, 2, 1>  (+1 B for each, +1 C iterating block)
            y = baz     # <2, 3, 1>
          end
          x.map(&:to_s) # <2, 4, 2>  (+1 B for map, +1 C iterating block)
        end
      RUBY

      it { is_expected.to eq '<2, 4, 2>' }
    end

    context 'method with arguments' do
      let(:source) { <<~RUBY }
        def method_name(a = 0, *b, c: 42, **d)
        end
      RUBY

      it { is_expected.to eq '<4, 0, 0>' }
    end

    context 'with .foo =' do
      let(:source) { <<~RUBY }
        def method_name
          foo.bar = 42
        end
      RUBY

      it { is_expected.to eq '<1, 2, 0>' }
    end

    context 'with []=' do
      let(:source) { <<~RUBY }
        def method_name
          x = {}
          x[:hello] = 'world'
        end
      RUBY

      it { is_expected.to eq '<2, 1, 0>' }
    end

    context 'multiple assignment' do
      let(:source) { <<~RUBY }
        def method_name
          a, b, c = d
        end
      RUBY

      it { is_expected.to eq '<3, 1, 0>' }
    end

    context 'multiple assignment with method setters' do
      let(:source) { <<~RUBY }
        def method_name
          self.a, foo.b, bar[42] = nil
        end
      RUBY

      it { is_expected.to eq '<3, 5, 0>' }
    end

    context 'equivalent to multiple assignment with method setters' do
      let(:source) { <<~RUBY }
        def method_name
          self.a = nil    # 1,  1, 0
          foo.b = nil     # 1, +2, 0
          bar[42] = nil   # 1, +2, 0
        end
      RUBY

      it { is_expected.to eq '<3, 5, 0>' }
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

    context 'with &.foo' do
      let(:source) { <<~RUBY }
        def method_name
          method&.foo
          method&.foo
        end
      RUBY

      it { is_expected.to eq '<0, 4, 2>' }

      context 'with repeated lvar receivers' do
        let(:source) { <<~RUBY }
          def foo
            var = other = 1                           #  2, 0,  0
            var&.do_something                         #    +1, +1
            var&.dont_count_this_as_condition         #    +1, +0
            var = 2                                   # +1
            var&.start_counting_again                 #    +1, +1
            var&.dont_count_this_as_condition_either  #    +1, +0
            other&.do_something                       #    +1, +1
          end
        RUBY

        it { is_expected.to eq '<3, 5, 3>' }
      end
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

    context 'with a for' do
      let(:source) { <<~RUBY }
        def method_name
          for x in 0..5  # 2, 0, 1
            puts x       #   +1
          end
        end
      RUBY

      it { is_expected.to eq '<2, 1, 1>' }
    end

    context 'with a yield' do
      let(:source) { <<~RUBY }
        def method_name
          yield 42
        end
      RUBY

      it { is_expected.to eq '<0, 1, 0>' }
    end

    context 'when counting repeated calls' do
      let(:discount_repeated_attributes) { false }
      let(:source) { <<~RUBY }
        def method_name(var)
          var.foo
          var.foo
          bar
          bar
        end
      RUBY

      it { is_expected.to eq '<1, 4, 0>' }
    end

    context 'when discounting repeated calls' do
      let(:discount_repeated_attributes) { true }

      context 'when root receiver is a var' do
        let(:source) { <<~RUBY }
          def method_name(var)  #   1, 0, 0
            var.foo.bar.baz     #     +3
            var.foo.bar.qux     #     +1
            var.foo.bar = 42    #  +1 +1   (partial invalidation)
            var.foo             #     +0
            var.foo.bar         #     +1
            var.foo.bar.baz     #     +1
            var = 42            #  +1      (complete invalidation)
            var.foo.bar         #     +2
          end
        RUBY

        it { is_expected.to eq '<3, 9, 0>' }
      end

      context 'when root receiver is self/nil' do
        let(:source) { <<~RUBY }
          def method_name       #   0, 0, 0
            self.foo.bar.baz    #     +3
            foo.bar.qux         #     +1
            foo.bar = 42        #  +1 +1    (partial invalidation)
            foo                 #     +0
            self.foo.bar        #     +1
            foo&.bar.baz        #     +1    (C += 0 since `csend` treated as `send`)
            self.foo ||= 42     #  +1 +1 +1 (complete invalidation)
            self.foo.bar        #     +2
          end
        RUBY

        it { is_expected.to eq '<2, 9, 1>' }
      end

      context 'when some calls have arguments' do
        let(:source) { <<~RUBY }
          def method_name(var)  #   1, 0, 0
            var.foo(42).bar     #     +2
            var.foo(42).bar     #     +2
            var.foo.bar         #     +2
            var.foo.bar         #     +0
            var.foo.bar(42)     #     +1
          end
        RUBY

        it { is_expected.to eq '<1, 7, 0>' }
      end
    end
  end
end
