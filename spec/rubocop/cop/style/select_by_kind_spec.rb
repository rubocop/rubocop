# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SelectByKind, :config do
  shared_examples 'class check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    context "with #{method}" do
      it 'registers an offense and corrects for `is_a?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.is_a?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo)
        RUBY
      end

      it 'registers an offense and corrects for `kind_of?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.kind_of?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo)
        RUBY
      end

      it 'registers an offense and corrects with a namespaced constant' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.is_a?(Foo::Bar) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo::Bar)
        RUBY
      end

      it 'registers an offense and corrects with a multiline block' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} do |x|
          ^^^^^^^{method}^^^^^^^ #{message}
            x.is_a?(Foo)
          end
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo)
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

      it 'does not register an offense when the block does not have a class check' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| x.even? }
        RUBY
      end

      it 'does not register an offense when the block has multiple expressions' do
        expect_no_offenses(<<~RUBY)
          array.#{method} do |x|
            next if x.nil?
            x.is_a?(Foo)
          end
        RUBY
      end

      it 'does not register an offense when the block arity is not 1' do
        expect_no_offenses(<<~RUBY)
          obj.#{method} { |x, y| y.is_a?(Foo) }
        RUBY
      end

      it 'does not register an offense when the block uses an external variable in a class check' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| y.is_a?(Foo) }
        RUBY
      end

      it 'registers an offense and corrects without a receiver' do
        expect_offense(<<~RUBY, method: method)
          #{method} { |x| x.is_a?(Foo) }
          ^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          #{correction}(Foo)
        RUBY
      end

      it 'registers an offense and corrects when the receiver is an array' do
        expect_offense(<<~RUBY, method: method)
          [].#{method} { |x| x.is_a?(Foo) }
          ^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
          foo.to_a.#{method} { |x| x.is_a?(Foo) }
          ^^^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          [].#{correction}(Foo)
          foo.to_a.#{correction}(Foo)
        RUBY
      end

      it 'does not register an offense when the receiver is a hash literal' do
        expect_no_offenses(<<~RUBY)
          {}.#{method} { |x| x.is_a?(Foo) }
          { foo: :bar }.#{method} { |x| x.is_a?(Foo) }
        RUBY
      end

      it 'does not register an offense when the receiver is `Hash.new`' do
        expect_no_offenses(<<~RUBY)
          Hash.new.#{method} { |x| x.is_a?(Foo) }
          Hash.new(:default).#{method} { |x| x.is_a?(Foo) }
          Hash.new { |hash, key| :default }.#{method} { |x| x.is_a?(Foo) }
        RUBY
      end

      it 'does not register an offense when the receiver is `Hash[]`' do
        expect_no_offenses(<<~RUBY)
          Hash[h].#{method} { |x| x.is_a?(Foo) }
          Hash[:foo, 0, :bar, 1].#{method} { |x| x.is_a?(Foo) }
        RUBY
      end

      it 'does not register an offense when the receiver is `to_h`' do
        expect_no_offenses(<<~RUBY)
          to_h.#{method} { |x| x.is_a?(Foo) }
          foo.to_h.#{method} { |x| x.is_a?(Foo) }
        RUBY
      end

      it 'does not register an offense when the receiver is `to_hash`' do
        expect_no_offenses(<<~RUBY)
          to_hash.#{method} { |x| x.is_a?(Foo) }
          foo.to_hash.#{method} { |x| x.is_a?(Foo) }
        RUBY
      end

      it 'does not register an offense when the receiver is `ENV`' do
        expect_no_offenses(<<~RUBY)
          ENV.#{method} { |x| x.is_a?(Foo) }
          ::ENV.#{method} { |x| x.is_a?(Foo) }
        RUBY
      end
    end
  end

  shared_examples 'negated class check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    context "with #{method}" do
      it 'registers an offense and corrects for negated `is_a?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.is_a?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo)
        RUBY
      end

      it 'registers an offense and corrects for negated `kind_of?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.kind_of?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo)
        RUBY
      end

      it 'registers an offense and corrects with a namespaced constant' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.is_a?(Foo::Bar) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{correction}(Foo::Bar)
        RUBY
      end
    end
  end

  shared_examples 'class check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end

    it 'registers an offense and corrects for `is_a?` with safe navigation' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { _1.is_a?(Foo) }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{correction}(Foo)
      RUBY
    end

    it 'registers an offense and corrects for `kind_of?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.kind_of?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end

    it 'does not register an offense if there is more than one numbered param' do
      expect_no_offenses(<<~RUBY)
        array.#{method} { _1.is_a?(_2) }
      RUBY
    end
  end

  shared_examples 'negated class check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for negated `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !_1.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end

    it 'registers an offense and corrects for negated `kind_of?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !_1.kind_of?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end
  end

  shared_examples 'class check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end

    it 'registers an offense and corrects for `is_a?` with safe navigation' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { it.is_a?(Foo) }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{correction}(Foo)
      RUBY
    end

    it 'registers an offense and corrects for `kind_of?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.kind_of?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end
  end

  shared_examples 'negated class check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for negated `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !it.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end

    it 'registers an offense and corrects for negated `kind_of?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !it.kind_of?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{correction}(Foo)
      RUBY
    end
  end

  shared_examples 'class check with safe navigation' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { |x| x.is_a?(Foo) }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{correction}(Foo)
      RUBY
    end

    it 'does not register an offense when the receiver is `Hash.new`' do
      expect_no_offenses(<<~RUBY)
        Hash&.new.#{method} { |x| x.is_a?(Foo) }
        Hash&.new { |hash, key| :default }.#{method} { |x| x.is_a?(Foo) }
      RUBY
    end

    it 'does not register an offense when the receiver is `to_h`' do
      expect_no_offenses(<<~RUBY)
        foo&.to_h.#{method} { |x| x.is_a?(Foo) }
      RUBY
    end

    it 'does not register an offense when the receiver is `to_hash`' do
      expect_no_offenses(<<~RUBY)
        foo&.to_hash.#{method} { |x| x.is_a?(Foo) }
      RUBY
    end
  end

  shared_examples 'find class check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    context "with #{method}" do
      it 'registers an offense and corrects for `is_a?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.is_a?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.grep(Foo).first
        RUBY
      end

      it 'registers an offense and corrects for `kind_of?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.kind_of?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.grep(Foo).first
        RUBY
      end

      it 'registers an offense and corrects with safe navigation' do
        expect_offense(<<~RUBY, method: method)
          array&.#{method} { |x| x.is_a?(Foo) }
          ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array&.grep(Foo).first
        RUBY
      end
    end
  end

  shared_examples 'negated find class check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    context "with #{method}" do
      it 'registers an offense and corrects for negated `is_a?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.is_a?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.grep_v(Foo).first
        RUBY
      end

      it 'registers an offense and corrects for negated `kind_of?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.kind_of?(Foo) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.grep_v(Foo).first
        RUBY
      end
    end
  end

  shared_examples 'find class check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.grep(Foo).first
      RUBY
    end
  end

  shared_examples 'negated find class check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for negated `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !_1.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.grep_v(Foo).first
      RUBY
    end
  end

  shared_examples 'find class check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.grep(Foo).first
      RUBY
    end
  end

  shared_examples 'negated find class check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a kind check."

    it 'registers an offense and corrects for negated `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !it.is_a?(Foo) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.grep_v(Foo).first
      RUBY
    end
  end

  context 'when Ruby >= 3.4', :ruby34 do
    it_behaves_like('class check with `itblock`s', 'select', 'grep')
    it_behaves_like('class check with `itblock`s', 'find_all', 'grep')
    it_behaves_like('class check with `itblock`s', 'filter', 'grep')
    it_behaves_like('negated class check with `itblock`s', 'reject', 'grep')

    it_behaves_like('negated class check with `itblock`s', 'select', 'grep_v')
    it_behaves_like('negated class check with `itblock`s', 'find_all', 'grep_v')
    it_behaves_like('negated class check with `itblock`s', 'filter', 'grep_v')
    it_behaves_like('class check with `itblock`s', 'reject', 'grep_v')

    it_behaves_like('find class check with `itblock`s', 'find', 'grep(...).first')
    it_behaves_like('find class check with `itblock`s', 'detect', 'grep(...).first')
    it_behaves_like('negated find class check with `itblock`s', 'find', 'grep_v(...).first')
    it_behaves_like('negated find class check with `itblock`s', 'detect', 'grep_v(...).first')
  end

  context 'when Ruby >= 2.7', :ruby27 do
    it_behaves_like('class check with `numblock`s', 'select', 'grep')
    it_behaves_like('class check with `numblock`s', 'find_all', 'grep')
    it_behaves_like('class check with `numblock`s', 'filter', 'grep')
    it_behaves_like('negated class check with `numblock`s', 'reject', 'grep')

    it_behaves_like('negated class check with `numblock`s', 'select', 'grep_v')
    it_behaves_like('negated class check with `numblock`s', 'find_all', 'grep_v')
    it_behaves_like('negated class check with `numblock`s', 'filter', 'grep_v')
    it_behaves_like('class check with `numblock`s', 'reject', 'grep_v')

    it_behaves_like('find class check with `numblock`s', 'find', 'grep(...).first')
    it_behaves_like('find class check with `numblock`s', 'detect', 'grep(...).first')
    it_behaves_like('negated find class check with `numblock`s', 'find', 'grep_v(...).first')
    it_behaves_like('negated find class check with `numblock`s', 'detect', 'grep_v(...).first')
  end

  it_behaves_like('class check', 'select', 'grep')
  it_behaves_like('class check with safe navigation', 'select', 'grep')
  it_behaves_like('class check', 'find_all', 'grep')
  it_behaves_like('class check with safe navigation', 'find_all', 'grep')
  it_behaves_like('class check', 'filter', 'grep')
  it_behaves_like('class check with safe navigation', 'filter', 'grep')
  it_behaves_like('negated class check', 'reject', 'grep')

  it_behaves_like('negated class check', 'select', 'grep_v')
  it_behaves_like('negated class check', 'find_all', 'grep_v')
  it_behaves_like('negated class check', 'filter', 'grep_v')
  it_behaves_like('class check', 'reject', 'grep_v')
  it_behaves_like('class check with safe navigation', 'reject', 'grep_v')

  it_behaves_like('find class check', 'find', 'grep(...).first')
  it_behaves_like('find class check', 'detect', 'grep(...).first')
  it_behaves_like('negated find class check', 'find', 'grep_v(...).first')
  it_behaves_like('negated find class check', 'detect', 'grep_v(...).first')
end
