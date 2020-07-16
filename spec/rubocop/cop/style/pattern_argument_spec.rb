# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PatternArgument, :config do
  context 'when using Ruby 2.5 or newer', :ruby25 do
    %w[all? any? none? one?].each do |method|
      describe method do
        describe 'Range' do
          context 'invoking === or aliases' do
            it 'is positive' do
              expect_offense(<<~RUBY, method: method)
                [1, 2, 3].#{method} { |e| (1..5) === e }
                          ^{method} Pass `(1..5)` as an argument to `#{method}` instead of a block.
                [1, 2, 3].#{method} { |e| Range.new(1, 5).include?(e) }
                          ^{method} Pass `Range.new(1, 5)` as an argument to `#{method}` instead of a block.
                [1, 2, 3].#{method} { |e| Range::new(1, 5).member?(e) }
                          ^{method} Pass `Range::new(1, 5)` as an argument to `#{method}` instead of a block.
              RUBY

              expect_correction(<<~RUBY)
                [1, 2, 3].#{method}(1..5)
                [1, 2, 3].#{method}(Range.new(1, 5))
                [1, 2, 3].#{method}(Range::new(1, 5))
              RUBY
            end
          end

          context 'when using Ruby 2.6+', :ruby26 do
            it 'using an endless range' do
              expect_offense(<<~RUBY, method: method)
                [1, 2, 3].#{method} { |e| (1..) === e }
                          ^{method} Pass `(1..)` as an argument to `#{method}` instead of a block.
              RUBY

              expect_correction("[1, 2, 3].#{method}(1..)\n")
            end
          end

          context 'when using Ruby 2.7+', :ruby27 do
            it 'using a beginless range' do
              expect_offense(<<~RUBY, method: method)
                [1, 2, 3].#{method} { |e| (...1) === e }
                          ^{method} Pass `(...1)` as an argument to `#{method}` instead of a block.
              RUBY

              expect_correction("[1, 2, 3].#{method}(...1)\n")
            end
          end
        end

        describe 'Set' do
          context 'invoking === or aliases' do
            it 'is positive' do
              expect_offense(<<~RUBY, method: method)
                [1, 2, 3].#{method} { |e| Set[1, 2, 3] === e }
                          ^{method} Pass `Set[1, 2, 3]` as an argument to `#{method}` instead of a block.
                [1, 2, 3].#{method} { |e| Set.new([1, 2, 3]).include?(e) }
                          ^{method} Pass `Set.new([1, 2, 3])` as an argument to `#{method}` instead of a block.
                [1, 2, 3].#{method} { |e| Set::new([1, 2, 3]).member?(e) }
                          ^{method} Pass `Set::new([1, 2, 3])` as an argument to `#{method}` instead of a block.
              RUBY

              expect_correction(<<~RUBY)
                [1, 2, 3].#{method}(Set[1, 2, 3])
                [1, 2, 3].#{method}(Set.new([1, 2, 3]))
                [1, 2, 3].#{method}(Set::new([1, 2, 3]))
              RUBY
            end
          end
        end

        describe 'Regexp' do
          context 'invoking ===, =~, match or match? on a regexp within the block' do
            it 'is positive' do
              expect_offense(<<~RUBY, method: method)
                %w[foo bar].#{method} { |e| /((\w)(\2))/ === e }
                            ^{method} Pass `/((\w)(\2))/` as an argument to `#{method}` instead of a block.
                %w[foo bar].#{method} { |e| Regexp.new('((\w)(\2))') =~ e }
                            ^{method} Pass `Regexp.new('((\w)(\2))')` as an argument to `#{method}` instead of a block.
                %w[foo bar].#{method} { |e| /((\w)(\2))/.match(e) }
                            ^{method} Pass `/((\w)(\2))/` as an argument to `#{method}` instead of a block.
                %w[foo bar].#{method} { |e| Regexp::new('((\w)(\2))').match?(e) }
                            ^{method} Pass `Regexp::new('((\w)(\2))')` as an argument to `#{method}` instead of a block.
              RUBY

              expect_correction(<<~RUBY)
                %w[foo bar].#{method}(/((\w)(\2))/)
                %w[foo bar].#{method}(Regexp.new('((\w)(\2))'))
                %w[foo bar].#{method}(/((\w)(\2))/)
                %w[foo bar].#{method}(Regexp::new('((\w)(\2))'))
              RUBY
            end
          end
        end

        context '=~, match, match? on lvar using a regular expression' do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              %w[foo baa].#{method} { |e| e =~ /((\w)(\2))/ }
                          ^{method} Pass `/((\w)(\2))/` as an argument to `#{method}` instead of a block.
              %w[foo baa].#{method} { |e| e.match(/((\w)(\2))/) }
                          ^{method} Pass `/((\w)(\2))/` as an argument to `#{method}` instead of a block.
              %w[foo baa].#{method} { |e| e.match?(/((\w)(\2))/) }
                          ^{method} Pass `/((\w)(\2))/` as an argument to `#{method}` instead of a block.
              %w[foo baa].#{method} { |e| e =~ Regexp.new('((\w)(\2))') }
                          ^{method} Pass `Regexp.new('((\w)(\2))')` as an argument to `#{method}` instead of a block.
              %w[foo baa].#{method} { |e| e.match(Regexp.new('((\w)(\2))')) }
                          ^{method} Pass `Regexp.new('((\w)(\2))')` as an argument to `#{method}` instead of a block.
              %w[foo baa].#{method} { |e| e.match?(Regexp.new('((\w)(\2))')) }
                          ^{method} Pass `Regexp.new('((\w)(\2))')` as an argument to `#{method}` instead of a block.
            RUBY

            expect_correction(<<~RUBY)
              %w[foo baa].#{method}(/((\w)(\2))/)
              %w[foo baa].#{method}(/((\w)(\2))/)
              %w[foo baa].#{method}(/((\w)(\2))/)
              %w[foo baa].#{method}(Regexp.new('((\w)(\2))'))
              %w[foo baa].#{method}(Regexp.new('((\w)(\2))'))
              %w[foo baa].#{method}(Regexp.new('((\w)(\2))'))
            RUBY
          end
        end

        context "invoking #{method} on an underscore variable" do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              _.#{method} { |e| /foo/.match?(e) }
                ^{method} Pass `/foo/` as an argument to `#{method}` instead of a block.
            RUBY

            expect_correction("_.#{method}(/foo/)\n")
          end
        end

        context "invoking #{method} on a local variable" do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              some_array.#{method} { |e| (1..10).include?(e) }
                         ^{method} Pass `(1..10)` as an argument to `#{method}` instead of a block.
            RUBY

            expect_correction("some_array.#{method}(1..10)\n")
          end
        end

        context "chaining #{method} with a safe navigation operator" do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              [1, 2, 3]&.#{method} { |e| (1..4).member?(e) }
                         ^{method} Pass `(1..4)` as an argument to `#{method}` instead of a block.
            RUBY

            expect_correction("[1, 2, 3]&.#{method}(1..4)\n")
          end
        end

        context 'invoking === to check the receiver class' do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              [1, 2, 3].#{method} { |e| e.is_a?(Symbol) }
                        ^{method} Pass `Symbol` as an argument to `#{method}` instead of a block.
            RUBY

            expect_correction("[1, 2, 3].#{method}(Symbol)\n")
          end
        end

        context 'is positive in a multiline block' do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              [1, 2, 3].#{method} do |e|
                        ^{method} Pass `Numeric` as an argument to `#{method}` instead of a block.
                Numeric === e
              end
            RUBY

            expect_correction("[1, 2, 3].#{method}(Numeric)\n")
          end
        end

        context 'invoking === on lvar passing an object that does not internally use lvar' do
          it 'is positive' do
            expect_offense(<<~RUBY, method: method)
              [1, 2, 3].#{method} { |e| e === f }
                        ^{method} Pass `f` as an argument to `#{method}` instead of a block.
              [1, 2, 3].#{method} { |e| e === another_method }
                        ^{method} Pass `another_method` as an argument to `#{method}` instead of a block.
            RUBY

            expect_correction(<<~RUBY)
              [1, 2, 3].#{method}(f)
              [1, 2, 3].#{method}(another_method)
            RUBY
          end
        end

        it 'accepts methods like member?, include?, =~, match, match? when receiver is not set, range or regexp' do
          expect_no_offenses(<<~RUBY)
            [1, 2, 3].#{method} { |e| array.member?(e) }
            [1, 2, 3].#{method} { |e| array.include?(e) }
            [1, 2, 3].#{method} { |e| [1, 2, 3].member?(e) }
            [1, 2, 3].#{method} { |e| [1, 2, 3].include?(e) }
            %w[foo bar].#{method} { |e| obj =~ e }
            %w[foo bar].#{method} { |e| obj.match(e) }
            %w[foo bar].#{method} { |e| obj.match?(e) }
          RUBY
        end

        it 'accepts invoking other methods in ranges, regexp, sets' do
          expect_no_offenses(<<~RUBY)
            [/foo/, /bar/].#{method} { |e| /((\w)(\2))/ == e }
            [1, 2, 3].#{method} { |e| Set[1, 2, 3].subset?(Set[e]) }
            [1, 2, 3].#{method} { |e| (5..10).cover?(e) }
          RUBY
        end

        it 'accepts a block with methods other than ===' do
          expect_no_offenses(<<~RUBY)
            ["foo", "bar"].#{method} { |e| /foo/ =~ e }
            [1, 2, 3].#{method} { |e| e == 42 }
            many_integers.#{method} { |e| e >= some_different_number }
            [:foo, :bar, :foobar].#{method} { |e| e.kind_of(String) }
            [1, 2, 3].#{method} { |e| Prime.prime?(e) }
          RUBY
        end

        it 'accepts a block with more than 1 expression in the body' do
          expect_no_offenses(<<~RUBY)
            ["foo", "bar"].#{method} { |e| 42 > 41 && /foo/ === e }
            [1, 2, 3].#{method} { |e| n = (Math::PI * e).fdiv(magic_number); n === e }
            ["foo", "bar"].#{method} do |e|
              e =~ /foo/ && 1 == 0
            end
            [{ foo: :foo, bar: :bar }, { foo: :bar, bar: :foo }].#{method} do |hash|
              foo, bar = hash.values_at(:foo, :bar)
              foo.include?(bar)
            end
          RUBY
        end

        it 'accepts a block yielding multiple values' do
          expect_no_offenses(<<~RUBY)
            [1, 2, 3].#{method} { |x, y| Set[foo(y), bar(y)].include?(x) }
            [1, 2, 3].#{method} { |_, x| Set[1, 2, 3].include?(x) }
            { foo: :foo, bar: :bar }.#{method} { |key, _| Symbol === key }
            [[1, :one], [2, :two]].#{method} { |_, e| Symbol === e }
            [%w[fo_o o], %w[foo_bar bar]].#{method} { |e, f| /_\#{f}$/ === e }
          RUBY
        end

        it 'accepts using lvar to invoke a method whose value is used with a supported method' do
          expect_no_offenses(<<~RUBY)
            [1, 2, 3].#{method} { |e| e === f(e) }
            [1, 2, 3].#{method} { |e| e === f + 2 }
            [1, 2, 3].#{method} { |e| e === e.another_method }
          RUBY
        end

        it 'accepts using lvar as the complement for another method' do
          expect_no_offenses("[1, 2, 3].#{method} { |x| Set[1, 2, 3].include?(foo(x)) }")
        end
      end
    end
  end

  context 'below Ruby 2.5', :ruby24 do
    %i[all? any? none? one?].each do |method|
      it "does not flag if the pattern could be used as the predicate argument in #{method}" do
        expect_no_offenses("[1, 2, 3].#{method} { |e| (1..10).include?(e) }")
      end
    end
  end
end
