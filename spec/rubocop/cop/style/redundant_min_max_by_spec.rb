# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantMinMaxBy, :config do
  shared_examples 'redundant method' do |method, replacement|
    it "autocorrects array.#{method} { |x| x }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array.#{method} { |x| x }
              ^{method}^^^^^^^^^^ Use `%{replacement}` instead of `%{method} { |x| x }`.
      RUBY

      expect_correction(<<~RUBY)
        array.#{replacement}
      RUBY
    end

    it "autocorrects array&.#{method} { |x| x }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array&.#{method} { |x| x }
               ^{method}^^^^^^^^^^ Use `%{replacement}` instead of `%{method} { |x| x }`.
      RUBY

      expect_correction(<<~RUBY)
        array&.#{replacement}
      RUBY
    end

    it "autocorrects array.#{method} { |y| y }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array.#{method} { |y| y }
              ^{method}^^^^^^^^^^ Use `%{replacement}` instead of `%{method} { |y| y }`.
      RUBY

      expect_correction(<<~RUBY)
        array.#{replacement}
      RUBY
    end

    it "autocorrects array.#{method} do |x| x end" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array.#{method} do |x|
              ^{method}^^^^^^^ Use `%{replacement}` instead of `%{method} { |x| x }`.
          x
        end
      RUBY

      expect_correction(<<~RUBY)
        array.#{replacement}
      RUBY
    end

    it "does not register an offense for array.#{method} { |x| x.foo }" do
      expect_no_offenses(<<~RUBY)
        array.#{method} { |x| x.foo }
      RUBY
    end

    it "does not register an offense for array.#{method} { |x| -x }" do
      expect_no_offenses(<<~RUBY)
        array.#{method} { |x| -x }
      RUBY
    end

    it "does not register an offense for array.#{method}(&:foo)" do
      expect_no_offenses(<<~RUBY)
        array.#{method}(&:foo)
      RUBY
    end
  end

  shared_examples 'redundant method with numblock' do |method, replacement|
    it "autocorrects array.#{method} { _1 }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array.#{method} { _1 }
              ^{method}^^^^^^^ Use `%{replacement}` instead of `%{method} { _1 }`.
      RUBY

      expect_correction(<<~RUBY)
        array.#{replacement}
      RUBY
    end

    it "autocorrects array&.#{method} { _1 }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array&.#{method} { _1 }
               ^{method}^^^^^^^ Use `%{replacement}` instead of `%{method} { _1 }`.
      RUBY

      expect_correction(<<~RUBY)
        array&.#{replacement}
      RUBY
    end
  end

  shared_examples 'redundant method with itblock' do |method, replacement|
    it "autocorrects array.#{method} { it }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array.#{method} { it }
              ^{method}^^^^^^^ Use `%{replacement}` instead of `%{method} { it }`.
      RUBY

      expect_correction(<<~RUBY)
        array.#{replacement}
      RUBY
    end

    it "autocorrects array&.#{method} { it }" do
      expect_offense(<<~RUBY, method: method, replacement: replacement)
        array&.#{method} { it }
               ^{method}^^^^^^^ Use `%{replacement}` instead of `%{method} { it }`.
      RUBY

      expect_correction(<<~RUBY)
        array&.#{replacement}
      RUBY
    end
  end

  it_behaves_like('redundant method', 'max_by', 'max')
  it_behaves_like('redundant method', 'min_by', 'min')
  it_behaves_like('redundant method', 'minmax_by', 'minmax')

  context 'Ruby 2.7', :ruby27 do
    it_behaves_like('redundant method with numblock', 'max_by', 'max')
    it_behaves_like('redundant method with numblock', 'min_by', 'min')
    it_behaves_like('redundant method with numblock', 'minmax_by', 'minmax')
  end

  context 'Ruby 3.4', :ruby34 do
    it_behaves_like('redundant method with itblock', 'max_by', 'max')
    it_behaves_like('redundant method with itblock', 'min_by', 'min')
    it_behaves_like('redundant method with itblock', 'minmax_by', 'minmax')
  end
end
