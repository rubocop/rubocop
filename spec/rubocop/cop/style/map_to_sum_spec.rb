# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MapToSum, :config do
  %i[map collect].each do |method|
    [:sum, :'sum(0)', :'sum(BigDecimal("0.0"))'].each do |sum|
      context "for `#{method}.#{sum}` with block arity 1" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x| x * 2 }.#{sum}
                ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            foo.#{sum} { |x| x * 2 }
          RUBY
        end
      end

      context "for `#{method}.#{sum}` with block arity 2" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x, y| x.to_f * y.to_i }.#{sum}
                ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            foo.#{sum} { |x, y| x.to_f * y.to_i }
          RUBY
        end
      end

      context 'when using numbered parameters', :ruby27 do
        context "for `#{method}.#{sum}` with block arity 1" do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              foo.#{method} { _1 * 2 }.#{sum}
                  ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
            RUBY

            expect_correction(<<~RUBY)
              foo.#{sum} { _1 * 2 }
            RUBY
          end
        end

        context "for `#{method}.#{sum}` with block arity 2" do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              foo.#{method} { _1.to_f * _2.to_i }.#{sum}
                  ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
            RUBY

            expect_correction(<<~RUBY)
              foo.#{sum} { _1.to_f * _2.to_i }
            RUBY
          end
        end
      end

      context "for `#{method}.#{sum}` with symbol proc" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method}(&:do_something).#{sum}
                ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          case sum
          when :sum
            expect_correction(<<~RUBY)
              foo.sum(&:do_something)
            RUBY
          when :'sum(0)'
            expect_correction(<<~RUBY)
              foo.sum(0, &:do_something)
            RUBY
          when :'sum(BigDecimal("0.0"))'
            expect_correction(<<~RUBY)
              foo.sum(BigDecimal("0.0"), &:do_something)
            RUBY
          else
            raise 'unexpected sum symbol'
          end
        end
      end

      context "when the receiver of #{sum} is an array" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3].#{method} { |x| x * 2 }.#{sum}
                      ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3].#{sum} { |x| x * 2 }
          RUBY
        end
      end

      context "when the receiver of #{sum} is a hash" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            { foo: :bar }.#{method} { |x, y| y.to_f }.#{sum}
                          ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            { foo: :bar }.#{sum} { |x, y| y.to_f }
          RUBY
        end
      end

      context "when #{sum} chained further" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x| x * 2 }.#{sum}.bar
                ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            foo.#{sum} { |x| x * 2 }.bar
          RUBY
        end
      end

      context "`#{method}` followed by `#{sum}` with a block passed to `sum`" do
        it 'does not register an offense but does not correct' do
          expect_no_offenses(<<~RUBY)
            foo.#{method} { |x| x * 2 }.#{sum} { |x| x * x }
          RUBY
        end
      end

      context "`#{method}` followed by `#{sum}` with a numbered block passed to `sum`", :ruby27 do
        it 'does not register an offense but does not correct' do
          expect_no_offenses(<<~RUBY)
            foo.#{method} { |x| x * 2 }.#{sum} { |x| x * x }
          RUBY
        end
      end

      context "`#{method}` followed by `#{sum}` with an `it` block passed to `sum`", :ruby34 do
        it 'does not register an offense but does not correct' do
          expect_no_offenses(<<~RUBY)
            foo.#{method} { |x| x * 2 }.#{sum} { |x| x * x }
          RUBY
        end
      end

      context "`map` and `#{method}.#{sum}` with newlines" do
        it 'registers an offense and corrects with newline removal' do
          expect_offense(<<~RUBY, method: method)
            {foo: bar}
              .#{method} { |k, v| v.do_something }
               ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
              .#{sum}
              .freeze
          RUBY

          expect_correction(<<~RUBY)
            {foo: bar}
              .#{sum} { |k, v| v.do_something }
              .freeze
          RUBY
        end
      end

      context 'with safe navigation' do
        it "registers an offense and corrects for `foo&.#{method}.#{sum}" do
          expect_offense(<<~RUBY, method: method)
            foo&.#{method} { |x| x * 2 }.#{sum}
                 ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            foo&.#{sum} { |x| x * 2 }
          RUBY
        end

        it "registers an offense and corrects for `foo.#{method}&.#{sum}" do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x| x * 2 }&.#{sum}
                ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            foo.#{sum} { |x| x * 2 }
          RUBY
        end

        it "registers an offense and corrects for `foo&.#{method}&.#{sum}" do
          expect_offense(<<~RUBY, method: method)
            foo&.#{method} { |x| x * 2 }&.#{sum}
                 ^{method} Pass a block to `sum` instead of calling `#{method}.sum`.
          RUBY

          expect_correction(<<~RUBY)
            foo&.#{sum} { |x| x * 2 }
          RUBY
        end
      end
    end

    context "`#{method}` without `sum`" do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          foo.#{method} { |x| x * 2 }
        RUBY
      end
    end
  end
end
