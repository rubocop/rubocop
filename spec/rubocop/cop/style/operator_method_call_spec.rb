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

    it "registers an offense when using `foo.#{operator_method}bar`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.#{operator_method}bar
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

    it "registers an offense when using `foo bar.#{operator_method} baz`" do
      expect_offense(<<~RUBY)
        foo bar.#{operator_method} baz
               ^ Redundant dot detected.
      RUBY

      expect_correction(<<~RUBY)
        foo bar #{operator_method} baz
      RUBY
    end

    it "registers an offense when using `foo.#{operator_method}(bar)`" do
      expect_offense(<<~RUBY, operator_method: operator_method)
        foo.#{operator_method}(bar)
           ^ Redundant dot detected.
      RUBY

      # Redundant parentheses in `(bar)` are left to `Style/RedundantParentheses` to fix.
      expect_correction(<<~RUBY)
        foo #{operator_method} (bar)
      RUBY
    end

    unless %i[! ~].include?(operator_method)
      it "registers an offense when using `foo.#{operator_method}(bar)` as an operand" do
        expect_offense(<<~RUBY, operator_method: operator_method)
          [foo.#{operator_method}(bar)]
              ^ Redundant dot detected.
          baz && foo.#{operator_method}(bar)
                    ^ Redundant dot detected.
        RUBY

        expect_correction(<<~RUBY)
          [foo #{operator_method} (bar)]
          baz && foo #{operator_method} (bar)
        RUBY
      end

      it "registers an offense when using `foo.#{operator_method}(bar)` as the first argument" do
        expect_offense(<<~RUBY, operator_method: operator_method)
          quux(foo.#{operator_method}(bar))
                  ^ Redundant dot detected.
        RUBY

        expect_correction(<<~RUBY)
          quux(foo #{operator_method} (bar))
        RUBY
      end

      it "registers an offense when using `foo.#{operator_method}(` followed by a newline" do
        expect_offense(<<~RUBY, operator_method: operator_method)
          foo.#{operator_method}(
             ^ Redundant dot detected.
            bar
          )
        RUBY

        expect_correction(<<~RUBY)
          foo #{operator_method} (
            bar
          )
        RUBY
      end
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

    it 'does not register an offense when using multiple arguments' do
      expect_no_offenses(<<~RUBY)
        foo.#{operator_method}(bar, baz)
      RUBY
    end
  end

  it 'registers an offense when using `foo.==({})`' do
    expect_offense(<<~RUBY)
      foo.==({})
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      foo == ({})
    RUBY
  end

  it 'registers an offense and wraps the call when it is an operand of another operator' do
    expect_offense(<<~RUBY)
      a * foo.+(bar)
             ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      a * (foo + bar)
    RUBY
  end

  it 'registers offenses when the same call is the receiver and an argument' do
    expect_offense(<<~RUBY)
      foo.+(bar).baz(foo.+(bar))
                        ^ Redundant dot detected.
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      (foo + bar).baz(foo + (bar))
    RUBY
  end

  it 'registers offenses and wraps an operand without parentheses of another operator call' do
    expect_offense(<<~RUBY)
      c.- a.- b
           ^ Redundant dot detected.
       ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      c - (a - b)
    RUBY
  end

  it 'registers an offense and does not wrap an index argument' do
    expect_offense(<<~RUBY)
      c[a.+ b]
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      c[a + b]
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

  it 'registers an offense and corrects when using `foo./(bar)`' do
    expect_offense(<<~RUBY)
      foo./(bar)
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      foo / (bar)
    RUBY
  end

  it 'registers an offense and corrects when using `foo./ (bar)`' do
    expect_offense(<<~RUBY)
      foo./ (bar)
         ^ Redundant dot detected.
    RUBY

    expect_correction(<<~RUBY)
      foo / (bar)
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

  it 'does not register an offense when the operator method call has a `do` block' do
    expect_no_offenses(<<~RUBY)
      pool.<< [1, 2] do
        foo
      end
    RUBY
  end

  it 'does not register an offense when the operator method call has a brace block' do
    expect_no_offenses(<<~RUBY)
      pool.<<([1, 2]) { foo }
    RUBY
  end

  it 'does not register an offense when using named block forwarding' do
    expect_no_offenses(<<~RUBY)
      def foo(&blk)
        bar.==(&blk)
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

  it 'does not register an offense when using named rest arguments forwarding' do
    expect_no_offenses(<<~RUBY)
      def foo(*args)
        bar.==(*args)
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

  it 'does not register an offense when named anonymous keyword rest arguments forwarding' do
    expect_no_offenses(<<~RUBY)
      def foo(**kwargs)
        bar.==(**kwargs)
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
