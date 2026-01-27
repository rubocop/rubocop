# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SelectByRange, :config do
  shared_examples 'range check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    context "with #{method}" do
      it 'registers an offense and corrects for `between?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.between?(1, 10) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for `Range#cover?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| (1..10).cover?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for `Range#include?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| (1..10).include?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for exclusive range' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| (1...10).cover?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        exclusive_correction = if correction.include?('(...)')
                                 correction.sub('(...)', '(1...10)')
                               else
                                 "#{correction}(1...10)"
                               end
        expect_correction(<<~RUBY)
          array.#{exclusive_correction}
        RUBY
      end

      it 'registers an offense and corrects with a multiline block' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} do |x|
          ^^^^^^^{method}^^^^^^^ #{message}
            x.between?(1, 10)
          end
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'does not register an offense when there is no block' do
        expect_no_offenses(<<~RUBY)
          array.#{method}
        RUBY
      end

      it 'does not register an offense when the block does not have a range check' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| x.even? }
        RUBY
      end

      it 'does not register an offense when the block has multiple expressions' do
        expect_no_offenses(<<~RUBY)
          array.#{method} do |x|
            next if x.even?
            x.between?(1, 10)
          end
        RUBY
      end

      it 'does not register an offense when the block uses an external variable in a range check' do
        expect_no_offenses(<<~RUBY)
          array.#{method} { |x| y.between?(1, 10) }
        RUBY
      end

      it 'registers an offense and corrects without a receiver' do
        expect_offense(<<~RUBY, method: method)
          #{method} { |x| x.between?(1, 10) }
          ^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          #{actual_correction}
        RUBY
      end

      it 'does not register an offense when the receiver is a hash literal' do
        expect_no_offenses(<<~RUBY)
          {}.#{method} { |x| x.between?(1, 10) }
          { foo: :bar }.#{method} { |x| x.between?(1, 10) }
        RUBY
      end

      it 'does not register an offense when the receiver is `Hash.new`' do
        expect_no_offenses(<<~RUBY)
          Hash.new.#{method} { |x| x.between?(1, 10) }
          Hash.new(:default).#{method} { |x| x.between?(1, 10) }
        RUBY
      end

      it 'does not register an offense when the receiver is `to_h`' do
        expect_no_offenses(<<~RUBY)
          to_h.#{method} { |x| x.between?(1, 10) }
          foo.to_h.#{method} { |x| x.between?(1, 10) }
        RUBY
      end

      it 'does not register an offense when the receiver is `ENV`' do
        expect_no_offenses(<<~RUBY)
          ENV.#{method} { |x| x.between?(1, 10) }
        RUBY
      end
    end
  end

  shared_examples 'negated range check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    context "with #{method}" do
      it 'registers an offense and corrects for negated `between?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.between?(1, 10) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for negated `Range#cover?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !(1..10).cover?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for negated `Range#include?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !(1..10).include?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end
    end
  end

  shared_examples 'range check with safe navigation' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    it 'registers an offense and corrects for `between?`' do
      expect_offense(<<~RUBY, method: method)
        array&.#{method} { |x| x.between?(1, 10) }
        ^^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array&.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'range check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    it 'registers an offense and corrects for `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end

    it 'registers an offense and corrects for `Range#cover?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { (1..10).cover?(_1) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'negated range check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    it 'registers an offense and corrects for negated `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !_1.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end

    it 'registers an offense and corrects for negated `Range#cover?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !(1..10).cover?(_1) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'range check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    it 'registers an offense and corrects for `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end

    it 'registers an offense and corrects for `Range#cover?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { (1..10).cover?(it) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'negated range check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    it 'registers an offense and corrects for negated `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !it.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end

    it 'registers an offense and corrects for negated `Range#cover?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !(1..10).cover?(it) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'find range check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = if correction.include?('(...)')
                          correction.sub('(...)', '(1..10)')
                        else
                          "#{correction}(1..10)"
                        end

    context "with #{method}" do
      it 'registers an offense and corrects for `between?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| x.between?(1, 10) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for `Range#cover?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| (1..10).cover?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end
    end
  end

  shared_examples 'negated find range check' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = correction.sub('(...)', '(1..10)')

    context "with #{method}" do
      it 'registers an offense and corrects for negated `between?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !x.between?(1, 10) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end

      it 'registers an offense and corrects for negated `Range#cover?`' do
        expect_offense(<<~RUBY, method: method)
          array.#{method} { |x| !(1..10).cover?(x) }
          ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
        RUBY

        expect_correction(<<~RUBY)
          array.#{actual_correction}
        RUBY
      end
    end
  end

  shared_examples 'find range check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = correction.sub('(...)', '(1..10)')

    it 'registers an offense and corrects for `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { _1.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'negated find range check with `numblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = correction.sub('(...)', '(1..10)')

    it 'registers an offense and corrects for negated `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !_1.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'find range check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = correction.sub('(...)', '(1..10)')

    it 'registers an offense and corrects for `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { it.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  shared_examples 'negated find range check with `itblock`s' do |method, correction|
    message = "Prefer `#{correction}` to `#{method}` with a range check."
    actual_correction = correction.sub('(...)', '(1..10)')

    it 'registers an offense and corrects for negated `between?`' do
      expect_offense(<<~RUBY, method: method)
        array.#{method} { !it.between?(1, 10) }
        ^^^^^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^ #{message}
      RUBY

      expect_correction(<<~RUBY)
        array.#{actual_correction}
      RUBY
    end
  end

  context 'when Ruby >= 3.4', :ruby34 do
    it_behaves_like('range check with `itblock`s', 'select', 'grep')
    it_behaves_like('range check with `itblock`s', 'find_all', 'grep')
    it_behaves_like('range check with `itblock`s', 'filter', 'grep')
    it_behaves_like('negated range check with `itblock`s', 'reject', 'grep')

    it_behaves_like('negated range check with `itblock`s', 'select', 'grep_v')
    it_behaves_like('negated range check with `itblock`s', 'find_all', 'grep_v')
    it_behaves_like('negated range check with `itblock`s', 'filter', 'grep_v')
    it_behaves_like('range check with `itblock`s', 'reject', 'grep_v')

    it_behaves_like('find range check with `itblock`s', 'find', 'grep(...).first')
    it_behaves_like('find range check with `itblock`s', 'detect', 'grep(...).first')
    it_behaves_like('negated find range check with `itblock`s', 'find', 'grep_v(...).first')
    it_behaves_like('negated find range check with `itblock`s', 'detect', 'grep_v(...).first')
  end

  context 'when Ruby >= 2.7', :ruby27 do
    it_behaves_like('range check with `numblock`s', 'select', 'grep')
    it_behaves_like('range check with `numblock`s', 'find_all', 'grep')
    it_behaves_like('range check with `numblock`s', 'filter', 'grep')
    it_behaves_like('negated range check with `numblock`s', 'reject', 'grep')

    it_behaves_like('negated range check with `numblock`s', 'select', 'grep_v')
    it_behaves_like('negated range check with `numblock`s', 'find_all', 'grep_v')
    it_behaves_like('negated range check with `numblock`s', 'filter', 'grep_v')
    it_behaves_like('range check with `numblock`s', 'reject', 'grep_v')

    it_behaves_like('find range check with `numblock`s', 'find', 'grep(...).first')
    it_behaves_like('find range check with `numblock`s', 'detect', 'grep(...).first')
    it_behaves_like('negated find range check with `numblock`s', 'find', 'grep_v(...).first')
    it_behaves_like('negated find range check with `numblock`s', 'detect', 'grep_v(...).first')
  end

  it_behaves_like('range check', 'select', 'grep')
  it_behaves_like('range check with safe navigation', 'select', 'grep')
  it_behaves_like('range check', 'find_all', 'grep')
  it_behaves_like('range check with safe navigation', 'find_all', 'grep')
  it_behaves_like('range check', 'filter', 'grep')
  it_behaves_like('range check with safe navigation', 'filter', 'grep')
  it_behaves_like('negated range check', 'reject', 'grep')

  it_behaves_like('negated range check', 'select', 'grep_v')
  it_behaves_like('negated range check', 'find_all', 'grep_v')
  it_behaves_like('negated range check', 'filter', 'grep_v')
  it_behaves_like('range check', 'reject', 'grep_v')
  it_behaves_like('range check with safe navigation', 'reject', 'grep_v')

  it_behaves_like('find range check', 'find', 'grep(...).first')
  it_behaves_like('find range check', 'detect', 'grep(...).first')
  it_behaves_like('negated find range check', 'find', 'grep_v(...).first')
  it_behaves_like('negated find range check', 'detect', 'grep_v(...).first')
end
