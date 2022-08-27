# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::InverseMethods, :config do
  let(:config) do
    RuboCop::Config.new(
      'Style/InverseMethods' => {
        'InverseMethods' => {
          any?: :none?,
          even?: :odd?,
          present?: :blank?,
          include?: :exclude?,
          :== => :!=,
          :=~ => :!~,
          :< => :>=,
          :> => :<=
        },
        'InverseBlocks' => {
          select: :reject,
          select!: :reject!
        }
      }
    )
  end

  it 'registers an offense for calling !.none? with a symbol proc' do
    expect_offense(<<~RUBY)
      !foo.none?(&:even?)
      ^^^^^^^^^^^^^^^^^^^ Use `any?` instead of inverting `none?`.
    RUBY

    expect_correction(<<~RUBY)
      foo.any?(&:even?)
    RUBY
  end

  it 'registers an offense for calling !.none? with a block' do
    expect_offense(<<~RUBY)
      !foo.none? { |f| f.even? }
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead of inverting `none?`.
    RUBY

    expect_correction(<<~RUBY)
      foo.any? { |f| f.even? }
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers an offense for calling !.none? with a numblock' do
      expect_offense(<<~RUBY)
        !foo.none? { _1.even? }
        ^^^^^^^^^^^^^^^^^^^^^^^ Use `any?` instead of inverting `none?`.
      RUBY

      expect_correction(<<~RUBY)
        foo.any? { _1.even? }
      RUBY
    end
  end

  it 'registers an offense for calling !.any? inside parens' do
    expect_offense(<<~RUBY)
      !(foo.any? &:working?)
      ^^^^^^^^^^^^^^^^^^^^^^ Use `none?` instead of inverting `any?`.
    RUBY

    expect_correction(<<~RUBY)
      foo.none? &:working?
    RUBY
  end

  it 'allows a method call without a not' do
    expect_no_offenses('foo.none?')
  end

  it 'allows an inverse method when double negation is used' do
    expect_no_offenses('!!(string =~ /^\w+$/)')
  end

  it 'allows an inverse method with a block when double negation is used' do
    expect_no_offenses('!!foo.reject { |e| !e }')
  end

  it 'allows an inverse method in a block with next' do
    expect_no_offenses(<<~RUBY)
      class TestClass
        def test_method
          [1, 2, 3, 4].select do |number|
            next if number == 4

            number != 2
          end
        end
      end
    RUBY
  end

  shared_examples 'all variable types' do |variable|
    it "registers an offense for calling !#{variable}.none?" do
      expect_offense(<<~RUBY, variable: variable)
        !%{variable}.none?
        ^^{variable}^^^^^^ Use `any?` instead of inverting `none?`.
      RUBY

      expect_correction(<<~RUBY)
        #{variable}.any?
      RUBY
    end

    it "registers an offense for calling not #{variable}.none?" do
      expect_offense(<<~RUBY, variable: variable)
        not %{variable}.none?
        ^^^^^{variable}^^^^^^ Use `any?` instead of inverting `none?`.
      RUBY

      expect_correction(<<~RUBY)
        #{variable}.any?
      RUBY
    end
  end

  it_behaves_like 'all variable types', 'foo'
  it_behaves_like 'all variable types', '$foo'
  it_behaves_like 'all variable types', '@foo'
  it_behaves_like 'all variable types', '@@foo'
  it_behaves_like 'all variable types', 'FOO'
  it_behaves_like 'all variable types', 'FOO::BAR'
  it_behaves_like 'all variable types', 'foo["bar"]'
  it_behaves_like 'all variable types', 'foo.bar'

  { any?: :none?,
    even?: :odd?,
    present?: :blank?,
    include?: :exclude?,
    none?: :any?,
    odd?: :even?,
    blank?: :present?,
    exclude?: :include? }.each do |method, inverse|
      it "registers an offense for !foo.#{method}" do
        expect_offense(<<~RUBY, method: method)
          !foo.%{method}
          ^^^^^^{method} Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse}
        RUBY
      end
    end

  { :== => :!=,
    :!= => :==,
    :=~ => :!~,
    :!~ => :=~,
    :< => :>=,
    :> => :<= }.each do |method, inverse|
    it "registers an offense for !(foo #{method} bar)" do
      expect_offense(<<~RUBY, method: method)
        !(foo %{method} bar)
        ^^^^^^^{method}^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
      RUBY

      expect_correction(<<~RUBY)
        foo #{inverse} bar
      RUBY
    end

    it "registers an offense for not (foo #{method} bar)" do
      expect_offense(<<~RUBY, method: method)
        not (foo %{method} bar)
        ^^^^^^^^^^{method}^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
      RUBY

      expect_correction(<<~RUBY)
        foo #{inverse} bar
      RUBY
    end
  end

  it 'allows comparing camel case constants on the right' do
    expect_no_offenses(<<~RUBY)
      klass = self.class
      !(klass < BaseClass)
    RUBY
  end

  it 'allows comparing camel case constants on the left' do
    expect_no_offenses(<<~RUBY)
      klass = self.class
      !(BaseClass < klass)
    RUBY
  end

  it 'registers an offense for comparing snake case constants on the right' do
    expect_offense(<<~RUBY)
      klass = self.class
      !(klass < FOO_BAR)
      ^^^^^^^^^^^^^^^^^^ Use `>=` instead of inverting `<`.
    RUBY

    expect_correction(<<~RUBY)
      klass = self.class
      klass >= FOO_BAR
    RUBY
  end

  it 'registers an offense for comparing snake case constants on the left' do
    expect_offense(<<~RUBY)
      klass = self.class
      !(FOO_BAR < klass)
      ^^^^^^^^^^^^^^^^^^ Use `>=` instead of inverting `<`.
    RUBY

    expect_correction(<<~RUBY)
      klass = self.class
      FOO_BAR >= klass
    RUBY
  end

  context 'inverse blocks' do
    { select: :reject,
      reject: :select,
      select!: :reject!,
      reject!: :select! }.each do |method, inverse|
      it "registers an offense for foo.#{method} { |e| !e }" do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} { |e| !e }
          ^^^^^{method}^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} { |e| e }
        RUBY
      end

      it 'registers an offense for a multiline method call where the last method is inverted' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} do |e|
          ^^^^^{method}^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
            something
            !e.bar
          end
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} do |e|
            something
            e.bar
          end
        RUBY
      end

      it 'registers an offense for an inverted equality block' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} { |e| e != 2 }
          ^^^^^{method}^^^^^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} { |e| e == 2 }
        RUBY
      end

      it 'registers an offense for a multiline inverted equality block' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} do |e|
          ^^^^^{method}^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
            something
            something_else
            e != 2
          end
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} do |e|
            something
            something_else
            e == 2
          end
        RUBY
      end

      it 'registers a single offense for nested inverse method calls' do
        expect_offense(<<~RUBY, method: method)
          y.%{method} { |key, _value| !(key =~ /c\\d/) }
          ^^^{method}^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          y.#{inverse} { |key, _value| (key =~ /c\\d/) }
        RUBY
      end

      it 'corrects an inverted method call' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} { |e| !e.bar? }
          ^^^^^{method}^^^^^^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} { |e| e.bar? }
        RUBY
      end

      it 'corrects an inverted method call when using `BasicObject#!`' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} { |e| e.bar?.! }
          ^^^^^{method}^^^^^^^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} { |e| e.bar? }
        RUBY
      end

      it 'corrects an inverted method call when using `BasicObject#!` with spaces before the method call' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} { |e| e.bar?.  ! }
          ^^^^^{method}^^^^^^^^^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} { |e| e.bar? }
        RUBY
      end

      it 'corrects a complex inverted method call' do
        expect_offense(<<~RUBY, method: method)
          puts 1 if !foo.%{method} { |e| !e.bar? }
                     ^^^^^{method}^^^^^^^^^^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
        RUBY

        expect_correction(<<~RUBY)
          puts 1 if !foo.#{inverse} { |e| e.bar? }
        RUBY
      end

      it 'corrects an inverted do end method call' do
        expect_offense(<<~RUBY, method: method)
          foo.%{method} do |e|
          ^^^^^{method}^^^^^^^ Use `#{inverse}` instead of inverting `#{method}`.
            !e.bar
          end
        RUBY

        expect_correction(<<~RUBY)
          foo.#{inverse} do |e|
            e.bar
          end
        RUBY
      end
    end
  end
end
