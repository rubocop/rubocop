# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::OperatorMethodCall, :config do
  described_class::RESTRICT_ON_SEND.each do |operator_method|
    it "registers an offense when using `foo.#{operator_method} bar`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.#{operator_method} bar
           ^ Redundant dot detected.
      RUBY

      expect_correction(<<~RUBY)
        foo #{operator_method} bar
      RUBY
    end

    it "does not register an offense when using `foo #{operator_method} bar`" do
      expect_no_offenses(<<~RUBY)
        foo #{operator_method} bar
      RUBY
    end

    it "registers an offense when using `foo.#{operator_method} 42`" do
      expect_offense(<<~RUBY)
        foo.#{operator_method} 42
           ^ Redundant dot detected.
      RUBY

      expect_correction(<<~RUBY)
        foo #{operator_method} 42
      RUBY
    end

    it "registers an offense when using `foo.#{operator_method}(bar)`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.#{operator_method}(bar)
           ^ Redundant dot detected.
      RUBY

      # Redundant parentheses in `(bar)` are left to `Style/RedundantParentheses` to fix.
      expect_correction(<<~RUBY)
        foo #{operator_method}(bar)
      RUBY
    end

    it "registers an offense when chaining `foo.bar.#{operator_method}(baz).round(2)`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.bar.#{operator_method}(baz).quux(2)
               ^ Redundant dot detected.
      RUBY

      expect_correction(<<~RUBY)
        (foo.bar #{operator_method} baz).quux(2)
      RUBY
    end

    it 'registers an offense when using named block forwarding' do
      expect_offense(<<~RUBY)
        def foo(&block)
          bar.#{operator_method}(&block)
             ^ Redundant dot detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(&block)
          bar #{operator_method}(&block)
        end
      RUBY
    end

    it 'registers an offense when using named rest arguments forwarding' do
      expect_offense(<<~RUBY)
        def foo(*args)
          bar.#{operator_method}(*args)
             ^ Redundant dot detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(*args)
          bar #{operator_method}(*args)
        end
      RUBY
    end

    it 'registers an offense when using named keyword rest arguments forwarding' do
      expect_offense(<<~RUBY)
        def foo(**options)
          bar.#{operator_method}(**options)
             ^ Redundant dot detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        def foo(**options)
          bar #{operator_method}(**options)
        end
      RUBY
    end

    it 'does not register an offense when using multiple arguments' do
      expect_no_offenses(<<~RUBY)
        foo.#{operator_method}(bar, baz)
      RUBY
    end
  end

  it 'registers an offense when using `foo.+({})`' do
    expect_offense(<<~RUBY)
      foo.==({})
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      foo ==({})
    RUBY
  end

  it 'registers an offense when using `foo.+ @bar.to_s`' do
    expect_offense(<<~RUBY)
      foo.+ @bar.to_s
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      foo + @bar.to_s
    RUBY
  end

  it 'does not register an offense when using `foo.+(@bar).to_s`' do
    expect_no_offenses(<<~RUBY)
      foo.+(@bar).to_s
    RUBY
  end

  it 'does not register an offense when using `foo.+@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.+@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.-@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.-@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.!@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.!@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.~@bar`' do
    expect_no_offenses(<<~RUBY)
      foo.~@ bar
    RUBY
  end

  it 'does not register an offense when using `foo.`bar`' do
    expect_no_offenses(<<~RUBY)
      foo.` bar
    RUBY
  end

  it 'does not register an offense when using `Foo.+(bar)`' do
    expect_no_offenses(<<~RUBY)
      Foo.+(bar)
    RUBY
  end

  it 'does not register an offense when using `obj.!`' do
    expect_no_offenses(<<~RUBY)
      obj.!
    RUBY
  end

  it 'does not register an offense when using forwarding method arguments', :ruby27 do
    expect_no_offenses(<<~RUBY)
      def foo(...)
        bar.==(...)
      end
    RUBY
  end

  it 'does not register an offense when using anonymous block forwarding', :ruby31 do
    expect_no_offenses(<<~RUBY)
      def foo(&)
        bar.==(&)
      end
    RUBY
  end

  it 'does not register an offense when using anonymous rest arguments forwarding', :ruby32 do
    expect_no_offenses(<<~RUBY)
      def foo(*)
        bar.==(*)
      end
    RUBY
  end

  it 'does not register an offense when using anonymous keyword rest arguments forwarding', :ruby32 do
    expect_no_offenses(<<~RUBY)
      def foo(**)
        bar.==(**)
      end
    RUBY
  end
end
