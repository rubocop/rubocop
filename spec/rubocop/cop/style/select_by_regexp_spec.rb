# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SelectByRegexp, :config do
  shared_examples 'regexp match' do |method, correction|
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

      it 'registers an offense and corrects for `blockvar =~ lvar`' do
        expect_offense(<<~RUBY, method: method)
          lvar = /regexp/
          array.#{method} { |x| x =~ lvar }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          lvar = /regexp/
          array.#{correction}(lvar)
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

      it 'registers an offense and corrects for `lvar =~ blockvar`' do
        expect_offense(<<~RUBY, method: method)
          lvar = /regexp/
          array.#{method} { |x| lvar =~ x }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          lvar = /regexp/
          array.#{correction}(lvar)
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

      it 'does not register an offense when the block body is empty' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { }
        RUBY
      end

      it 'registers an offense and corrects without a receiver' do
        expect_offense(<<~RUBY, method: method)
          #{method} { |x| x.match?(/regexp/) }
          ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          #{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects when the receiver is an array' do
        expect_offense(<<~RUBY, method: method)
          [].#{method} { |x| x.match?(/regexp/) }
          ^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
          foo.to_a.#{method} { |x| x.match?(/regexp/) }
          ^^^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          [].#{correction}(/regexp/)
          foo.to_a.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects when the receiver is a range' do
        expect_offense(<<~RUBY, method: method)
          ('aaa'...'abc').#{method} { |x| x.match?(/ab/) }
          ^^^^^^^^^^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          ('aaa'...'abc').#{correction}(/ab/)
        RUBY
      end

      it 'registers an offense and corrects when the receiver is a set' do
        expect_offense(<<~RUBY, method: method)
          Set.new.#{method} { |x| x.match?(/regexp/) }
          ^^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
          [].to_set.#{method} { |x| x.match?(/regexp/) }
          ^^^^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          Set.new.#{correction}(/regexp/)
          [].to_set.#{correction}(/regexp/)
        RUBY
      end

      it 'does not register an offense when the receiver is a hash literal' do
        expect_no_offenses(<<~RUBY)
          {}.#{method} { |x| x.match? /regexp/ }
          { foo: :bar }.#{method} { |x| x.match? /regexp/ }
        RUBY
      end

      it 'does not register an offense when the receiver is `Hash.new`' do
        expect_no_offenses(<<~RUBY)
          Hash.new.#{method} { |x| x.match? /regexp/ }
          Hash.new(:default).#{method} { |x| x.match? /regexp/ }
          Hash.new { |hash, key| :default }.#{method} { |x| x.match? /regexp/ }
        RUBY
      end

      it 'does not register an offense when the receiver is `Hash[]`' do
        expect_no_offenses(<<~RUBY)
          Hash[h].#{method} { |x| x.match? /regexp/ }
          Hash[:foo, 0, :bar, 1].#{method} { |x| x.match? /regexp/ }
        RUBY
      end

      it 'does not register an offense when the receiver is `to_h`' do
        expect_no_offenses(<<~RUBY)
          to_h.#{method} { |x| x.match? /regexp/ }
          foo.to_h.#{method} { |x| x.match? /regexp/ }
        RUBY
      end

      it 'does not register an offense when the receiver is `to_hash`' do
        expect_no_offenses(<<~RUBY)
          to_hash.#{method} { |x| x.match? /regexp/ }
          foo.to_hash.#{method} { |x| x.match? /regexp/ }
        RUBY
      end

      it 'registers an offense if `to_h` is in the receiver chain but not the actual receiver' do
        # Although there is a `to_h` in the chain, we cannot be sure
        # of the type of the ultimate receiver.
        expect_offense(<<~RUBY, method: method)
          foo.to_h.bar.#{method} { |x| x.match? /regexp/ }
          ^^^^^^^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          foo.to_h.bar.#{correction}(/regexp/)
        RUBY
      end

      it 'does not register an offense when the receiver is `ENV`' do
        expect_no_offenses(<<~RUBY)
          ENV.#{method} { |x| x.match? /regexp/ }
          ::ENV.#{method} { |x| x.match? /regexp/ }
        RUBY
      end
    end
  end

  shared_examples 'regexp match with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    it 'registers an offense and corrects for `match?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.match? /regexp/ }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `match?` with safe navigation' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { _1.match? /regexp/ }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{correction}(/regexp/)
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

    it 'does not register an offense when using `match?` without a receiver' do
      expect_no_offenses(<<~RUBY)
        array.#{method} { |item| match?(item) }
      RUBY
    end
  end

  shared_examples 'regexp match with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    it 'registers an offense and corrects for `match?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.match? /regexp/ }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `match?` with safe navigation' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { it.match? /regexp/ }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `Regexp#match?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { /regexp/.match?(it) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `blockvar =~ regexp`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it =~ /regexp/ }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `regexp =~ blockvar`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { /regexp/ =~ it }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'does not register an offense when the param is a method argument' do
      expect_no_offenses(<<~RUBY)
        array.#{method} { /regexp/.match?(foo(it)) }
      RUBY
    end

    it 'does not register an offense when using `match?` without a receiver' do
      expect_no_offenses(<<~RUBY)
        array.#{method} { |item| match?(item) }
      RUBY
    end
  end

  shared_examples 'regexp match with safe navigation' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    it 'registers an offense and corrects for `match?`' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { |x| x.match? /regexp/ }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{correction}(/regexp/)
      RUBY
    end

    it 'does not register an offense when the receiver is `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Hash&.new.#{method} { |x| x.match? /regexp/ }
        Hash&.new { |hash, key| :default }.#{method} { |x| x.match? /regexp/ }
      RUBY
    end

    it 'does not register an offense when the receiver is `to_h`' do
      expect_no_offenses(<<~RUBY)
        foo&.to_h.#{method} { |x| x.match? /regexp/ }
      RUBY
    end

    it 'does not register an offense when the receiver is `to_hash`' do
      expect_no_offenses(<<~RUBY)
        foo&.to_hash.#{method} { |x| x.match? /regexp/ }
      RUBY
    end
  end

  shared_examples 'regexp mismatch' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    context "with #{method}" do
      it 'registers an offense and corrects for `blockvar !~ regexp`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x !~ /regexp/ }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `blockvar !~ lvar`' do
        expect_offense(<<~RUBY, method: method)
          lvar = /regexp/
          array.#{method} { |x| x !~ lvar }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          lvar = /regexp/
          array.#{correction}(lvar)
        RUBY
      end

      it 'registers an offense and corrects for `regexp !~ blockvar`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| /regexp/ !~ x }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `lvar !~ blockvar`' do
        expect_offense(<<~RUBY, method: method)
          lvar = /regexp/
          array.#{method} { |x| lvar !~ x }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          lvar = /regexp/
          array.#{correction}(lvar)
        RUBY
      end

      it 'registers an offense and corrects when there is no explicit regexp' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x !~ y }
          ^^^^^^^{method}^^^^^^^^^^^^^^^ #{message}
          array.#{method} { |x| x !~ REGEXP }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^ #{message}
          array.#{method} { |x| x !~ foo.bar.baz(quux) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(y)
          array.#{correction}(REGEXP)
          array.#{correction}(foo.bar.baz(quux))
        RUBY
      end
    end
  end

  shared_examples 'regexp mismatch with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    it 'registers an offense and corrects for `blockvar !~ regexp`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1 !~ /regexp/ }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `regexp !~ blockvar`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { /regexp/ !~ _1 }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'does not register an offense if there is more than one numbered param' do
      expect_no_offenses(<<~RUBY)
        array.#{method} { _1 !~ _2 }
      RUBY
    end
  end

  shared_examples 'regexp mismatch with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    it 'registers an offense and corrects for `blockvar !~ regexp`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it !~ /regexp/ }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end

    it 'registers an offense and corrects for `regexp !~ blockvar`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { /regexp/ !~ it }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(/regexp/)
      RUBY
    end
  end

  shared_examples 'regexp mismatch with safe navigation' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a regexp match."

    context "with #{method}" do
      it 'registers an offense and corrects for `blockvar !~ regexp`' do
        expect_offense(<<~RUBY, method: method)
          array&.#{method} { |x| x !~ /regexp/ }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array&.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `blockvar !~ lvar`' do
        expect_offense(<<~RUBY, method: method)
          lvar = /regexp/
          array&.#{method} { |x| x !~ lvar }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          lvar = /regexp/
          array&.#{correction}(lvar)
        RUBY
      end

      it 'registers an offense and corrects for `regexp !~ blockvar`' do
        expect_offense(<<~RUBY, method: method)
          array&.#{method} { |x| /regexp/ !~ x }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array&.#{correction}(/regexp/)
        RUBY
      end

      it 'registers an offense and corrects for `lvar !~ blockvar`' do
        expect_offense(<<~RUBY, method: method)
          lvar = /regexp/
          array&.#{method} { |x| lvar !~ x }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          lvar = /regexp/
          array&.#{correction}(lvar)
        RUBY
      end

      it 'registers an offense and corrects when there is no explicit regexp' do
        expect_offense(<<~RUBY, method: method)
          array&.#{method} { |x| x !~ y }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^ #{message}
          array&.#{method} { |x| x !~ REGEXP }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^ #{message}
          array&.#{method} { |x| x !~ foo.bar.baz(quux) }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array&.#{correction}(y)
          array&.#{correction}(REGEXP)
          array&.#{correction}(foo.bar.baz(quux))
        RUBY
      end
    end
  end

  context 'when Ruby >= 3.4', :ruby34 do
    it_behaves_like('regexp match with `itblock`s', 'select', 'grep')
    it_behaves_like('regexp match with `itblock`s', 'find_all', 'grep')
    it_behaves_like('regexp match with `itblock`s', 'filter', 'grep')
    it_behaves_like('regexp mismatch with `itblock`s', 'reject', 'grep')

    it_behaves_like('regexp match with `itblock`s', 'reject', 'grep_v')
    it_behaves_like('regexp mismatch with `itblock`s', 'select', 'grep_v')
    it_behaves_like('regexp mismatch with `itblock`s', 'find_all', 'grep_v')
    it_behaves_like('regexp mismatch with `itblock`s', 'filter', 'grep_v')
  end

  context 'when Ruby >= 2.7', :ruby27 do
    it_behaves_like('regexp match with `numblock`s', 'select', 'grep')
    it_behaves_like('regexp match with `numblock`s', 'find_all', 'grep')
    it_behaves_like('regexp match with `numblock`s', 'filter', 'grep')
    it_behaves_like('regexp mismatch with `numblock`s', 'reject', 'grep')

    it_behaves_like('regexp match with `numblock`s', 'reject', 'grep_v')
    it_behaves_like('regexp mismatch with `numblock`s', 'select', 'grep_v')
    it_behaves_like('regexp mismatch with `numblock`s', 'find_all', 'grep_v')
    it_behaves_like('regexp mismatch with `numblock`s', 'filter', 'grep_v')
  end

  context 'when Ruby >= 2.6', :ruby26 do
    it_behaves_like('regexp match', 'filter', 'grep')
    it_behaves_like('regexp match with safe navigation', 'filter', 'grep')

    it_behaves_like('regexp mismatch', 'filter', 'grep_v')
    it_behaves_like('regexp mismatch with safe navigation', 'filter', 'grep_v')
  end

  context 'when Ruby <= 2.5', :ruby25, unsupported_on: :prism do
    it 'does not register an offense when `filter` with regexp match' do
      expect_no_offenses(<<~RUBY)
        array.filter { |x| x =~ /regexp/ }
      RUBY
    end

    it 'does not register an offense when `filter` with regexp mismatch' do
      expect_no_offenses(<<~RUBY)
        array.filter { |x| x !~ /regexp/ }
      RUBY
    end
  end

  context 'when Ruby >= 2.3', :ruby23 do
    it_behaves_like('regexp match', 'select', 'grep')
    it_behaves_like('regexp match with safe navigation', 'select', 'grep')
    it_behaves_like('regexp match', 'find_all', 'grep')
    it_behaves_like('regexp match with safe navigation', 'find_all', 'grep')
    it_behaves_like('regexp mismatch', 'reject', 'grep')
    it_behaves_like('regexp mismatch with safe navigation', 'reject', 'grep')

    it_behaves_like('regexp match', 'reject', 'grep_v')
    it_behaves_like('regexp match with safe navigation', 'reject', 'grep_v')
    it_behaves_like('regexp mismatch', 'select', 'grep_v')
    it_behaves_like('regexp mismatch with safe navigation', 'select', 'grep_v')
    it_behaves_like('regexp mismatch', 'find_all', 'grep_v')
    it_behaves_like('regexp mismatch with safe navigation', 'find_all', 'grep_v')
  end

  context 'when Ruby <= 2.2', :ruby22, unsupported_on: :prism do
    it_behaves_like('regexp match', 'select', 'grep')
    it_behaves_like('regexp match', 'find_all', 'grep')
    it_behaves_like('regexp mismatch', 'reject', 'grep')

    it 'does not register an offense when `reject` with regexp match' do
      expect_no_offenses(<<~RUBY)
        array.reject { |x| x =~ /regexp/ }
      RUBY
    end

    it 'does not register an offense when `select` with regexp mismatch' do
      expect_no_offenses(<<~RUBY)
        array.select { |x| x !~ /regexp/ }
      RUBY
    end

    it 'does not register an offense when `find_all` with regexp mismatch' do
      expect_no_offenses(<<~RUBY)
        array.find_all { |x| x !~ /regexp/ }
      RUBY
    end
  end
end
