# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::PredicateWithKind, :config do
  shared_examples 'kind check' do |method|
    message = "Prefer `#{method}(Integer)` to `#{method} { ... }` with a kind check."

    context "with #{method}" do
      it 'registers an offense and corrects for `is_a?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.is_a?(Integer) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{method}(Integer)
        RUBY
      end

      it 'registers an offense and corrects for `kind_of?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.kind_of?(String) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message.sub('Integer', 'String')}
        RUBY

        expect_correction(<<~RUBY)
          array.#{method}(String)
        RUBY
      end

      it 'registers an offense and corrects for `instance_of?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.instance_of?(Float) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message.sub('Integer', 'Float')}
        RUBY

        expect_correction(<<~RUBY)
          array.#{method}(Float)
        RUBY
      end

      it 'registers an offense and corrects with a multiline block' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} do |x|
          ^^^^^^^{method}^^^^^^^ #{message}
            x.is_a?(Integer)
          end
        RUBY

        expect_correction(<<~RUBY)
          array.#{method}(Integer)
        RUBY
      end

      it 'registers an offense and corrects without a receiver' do
        expect_offense(<<~RUBY, method: method)
          #{method} { |x| x.is_a?(Integer) }
          ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          #{method}(Integer)
        RUBY
      end

      it 'registers an offense and corrects with namespaced class' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.is_a?(ActiveRecord::Base) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message.sub('Integer', 'ActiveRecord::Base')}
        RUBY

        expect_correction(<<~RUBY)
          array.#{method}(ActiveRecord::Base)
        RUBY
      end

      it 'does not register an offense when there is no block' do
        expect_no_offenses(<<~RUBY)
          array.#{method}
        RUBY
      end

      it 'does not register an offense when the block does not have a kind check' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| x.even? }
        RUBY
      end

      it 'does not register an offense when the block has multiple expressions' do
        expect_no_offenses(<<~RUBY)
          array.#{method} do |x|
            next if x.nil?
            x.is_a?(Integer)
          end
        RUBY
      end

      it 'does not register an offense when the block uses an external variable' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| y.is_a?(Integer) }
        RUBY
      end

      it 'does not register an offense when the predicate already has an argument' do
        expect_no_offenses(<<~RUBY)
          array.#{method}(Integer)
        RUBY
      end
    end
  end

  shared_examples 'kind check with safe navigation' do |method|
    message = "Prefer `#{method}(Integer)` to `#{method} { ... }` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { |x| x.is_a?(Integer) }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{method}(Integer)
      RUBY
    end
  end

  shared_examples 'kind check with `numblock`s' do |method|
    message = "Prefer `#{method}(Integer)` to `#{method} { ... }` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.is_a?(Integer) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{method}(Integer)
      RUBY
    end

    it 'registers an offense and corrects for `kind_of?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.kind_of?(String) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message.sub('Integer', 'String')}
      RUBY

      expect_correction(<<~RUBY)
        array.#{method}(String)
      RUBY
    end
  end

  shared_examples 'kind check with `itblock`s' do |method|
    message = "Prefer `#{method}(Integer)` to `#{method} { ... }` with a kind check."

    it 'registers an offense and corrects for `is_a?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.is_a?(Integer) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{method}(Integer)
      RUBY
    end

    it 'registers an offense and corrects for `kind_of?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.kind_of?(String) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message.sub('Integer', 'String')}
      RUBY

      expect_correction(<<~RUBY)
        array.#{method}(String)
      RUBY
    end
  end

  context 'when Ruby >= 3.4', :ruby34 do
    it_behaves_like('kind check with `itblock`s', 'any?')
    it_behaves_like('kind check with `itblock`s', 'all?')
    it_behaves_like('kind check with `itblock`s', 'none?')
    it_behaves_like('kind check with `itblock`s', 'one?')
  end

  context 'when Ruby >= 2.7', :ruby27 do
    it_behaves_like('kind check with `numblock`s', 'any?')
    it_behaves_like('kind check with `numblock`s', 'all?')
    it_behaves_like('kind check with `numblock`s', 'none?')
    it_behaves_like('kind check with `numblock`s', 'one?')
  end

  it_behaves_like('kind check', 'any?')
  it_behaves_like('kind check with safe navigation', 'any?')
  it_behaves_like('kind check', 'all?')
  it_behaves_like('kind check with safe navigation', 'all?')
  it_behaves_like('kind check', 'none?')
  it_behaves_like('kind check with safe navigation', 'none?')
  it_behaves_like('kind check', 'one?')
  it_behaves_like('kind check with safe navigation', 'one?')
end
