# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SelectByRegexp, :config do
  { 'select' => 'grep', 'find_all' => 'grep', 'reject' => 'grep_v' }.each do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    context "with #{method}" do
      it 'registers an offense and corrects for `match?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.match? /regexp/ }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `Regexp#match?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| /regexp/.match? x }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `blockvar =~ regexp`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x =~ /regexp/ }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `regexp =~ blockvar`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| /regexp/ =~ x }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects when there is no explicit regexp' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x =~ y }
          ^^^^^^^{method}^^^^^^^^^^^^^^^ #{message}
          array.#{method} { |x| x =~ REGEXP }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^ #{message}
          array.#{method} { |x| x =~ foo.bar.baz(quux) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(y)
          array.#{correction}(REGEXP)
          array.#{correction}(foo.bar.baz(quux))
        RUBY
      end

      it 'registers an offense and corrects with a multiline block' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} do |x|
          ^^^^^^^{method}^^^^^^^ #{message}
            x.match? /regexp/
          end
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'does not register an offense when there is no block' do
        expect_no_offenses(<<~RUBY)
          array.#{method}
        RUBY
      end

      it 'does not register an offense when given a proc' do
        expect_no_offenses(<<~RUBY)
          array.#{method}(&:even?)
        RUBY
      end

      it 'does not register an offense when the block does not match a regexp' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| x.even? }
        RUBY
      end

      it 'does not register an offense when the block has multiple expressions' do
        expect_no_offenses(<<~RUBY)
          array.#{method} do |x|
            next if x.even?
            x.match? /regexp/
          end
        RUBY
      end

      it 'does not register an offense when the block arity is not 1' do
        expect_no_offenses(<<~RUBY)
          obj.#{method} { |x, y| y.match? /regexp/ }
        RUBY
      end

      it 'does not register an offense when the block uses an external variable in a regexp match' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| y.match? /regexp/ }
        RUBY
      end

      it 'does not register an offense when the block param is a method argument' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| /regexp/.match?(foo(x)) }
        RUBY
      end

      context 'with `numblock`s', :ruby27 do
        it 'registers an offense and corrects for `match?`' do
          expect_offense(<<~RUBY, method: method)
            array.#{method} { _1.match? /regexp/ }
            ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            array.#{correction}(/regexp/)
          RUBY
        end

        it 'registers an offense and corrects for `Regexp#match?`' do
          expect_offense(<<~RUBY, method: method)
            array.#{method} { /regexp/.match?(_1) }
            ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            array.#{correction}(/regexp/)
          RUBY
        end

        it 'registers an offense and corrects for `blockvar =~ regexp`' do
          expect_offense(<<~RUBY, method: method)
            array.#{method} { _1 =~ /regexp/ }
            ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            array.#{correction}(/regexp/)
          RUBY
        end

        it 'registers an offense and corrects for `regexp =~ blockvar`' do
          expect_offense(<<~RUBY, method: method)
            array.#{method} { /regexp/ =~ _1 }
            ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
          RUBY

          expect_correction(<<~RUBY)
            array.#{correction}(/regexp/)
          RUBY
        end

        it 'does not register an offense if there is more than one numbered param' do
          expect_no_offenses(<<~RUBY)
            array.#{method} { _1 =~ _2 }
          RUBY
        end

        it 'does not register an offense when the param is a method argument' do
          expect_no_offenses(<<~RUBY)
            array.#{method} { /regexp/.match?(foo(_1)) }
          RUBY
        end
      end
    end
  end
end
