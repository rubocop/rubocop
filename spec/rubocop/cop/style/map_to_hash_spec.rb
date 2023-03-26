# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::MapToHash, :config do
  context '>= Ruby 2.6', :ruby26 do
    %i[map collect].each do |method|
      context "for `#{method}.to_h` with block arity 1" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x| [x, x * 2] }.to_h
                ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_correction(<<~RUBY)
            foo.to_h { |x| [x, x * 2] }
          RUBY
        end
      end

      context "for `#{method}.to_h` with block arity 2" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x, y| [x.to_s, y.to_i] }.to_h
                ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_correction(<<~RUBY)
            foo.to_h { |x, y| [x.to_s, y.to_i] }
          RUBY
        end
      end

      context 'when using numbered parameters', :ruby27 do
        context "for `#{method}.to_h` with block arity 1" do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              foo.#{method} { [_1, _1 * 2] }.to_h
                  ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
            RUBY

            expect_correction(<<~RUBY)
              foo.to_h { [_1, _1 * 2] }
            RUBY
          end
        end

        context "for `#{method}.to_h` with block arity 2" do
          it 'registers an offense and corrects' do
            expect_offense(<<~RUBY, method: method)
              foo.#{method} { [_1.to_s, _2.to_i] }.to_h
                  ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
            RUBY

            expect_correction(<<~RUBY)
              foo.to_h { [_1.to_s, _2.to_i] }
            RUBY
          end
        end
      end

      context "for `#{method}.to_h` with symbol proc" do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method}(&:do_something).to_h
                ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_correction(<<~RUBY)
            foo.to_h(&:do_something)
          RUBY
        end
      end

      context 'when the receiver is an array' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            [1, 2, 3].#{method} { |x| [x, x * 2] }.to_h
                      ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_correction(<<~RUBY)
            [1, 2, 3].to_h { |x| [x, x * 2] }
          RUBY
        end
      end

      context 'when the receiver is an hash' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            { foo: :bar }.#{method} { |x, y| [x.to_s, y.to_s] }.to_h
                          ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_correction(<<~RUBY)
            { foo: :bar }.to_h { |x, y| [x.to_s, y.to_s] }
          RUBY
        end
      end

      context 'when chained further' do
        it 'registers an offense and corrects' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x| x * 2 }.to_h.bar
                ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_correction(<<~RUBY)
            foo.to_h { |x| x * 2 }.bar
          RUBY
        end
      end

      context "`#{method}` without `to_h`" do
        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY, method: method)
            foo.#{method} { |x| x * 2 }
          RUBY
        end
      end

      context "`#{method}.to_h` with a block on `to_h`" do
        it 'registers an offense but does not correct' do
          expect_offense(<<~RUBY, method: method)
            foo.#{method} { |x| x * 2 }.to_h { |x| [x.to_s, x] }
                ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
          RUBY

          expect_no_corrections
        end
      end

      context "`map` and `#{method}.to_h` with newlines" do
        it 'registers an offense and corrects with newline removal' do
          expect_offense(<<~RUBY, method: method)
            {foo: bar}
              .#{method} { |k, v| [k.to_s, v.do_something] }
               ^{method} Pass a block to `to_h` instead of calling `#{method}.to_h`.
              .to_h
              .freeze
          RUBY

          expect_correction(<<~RUBY)
            {foo: bar}
              .to_h { |k, v| [k.to_s, v.do_something] }
              .freeze
          RUBY
        end
      end
    end
  end
end
