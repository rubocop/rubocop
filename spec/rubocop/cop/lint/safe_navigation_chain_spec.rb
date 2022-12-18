# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SafeNavigationChain, :config do
  shared_examples 'accepts' do |name, code|
    it "accepts usages of #{name}" do
      expect_no_offenses(code)
    end
  end

  context 'TargetRubyVersion >= 2.3', :ruby23 do
    [
      ['ordinary method chain', 'x.foo.bar.baz'],
      ['ordinary method chain with argument', 'x.foo(x).bar(y).baz(z)'],
      ['method chain with safe navigation only', 'x&.foo&.bar&.baz'],
      ['method chain with safe navigation only with argument',
       'x&.foo(x)&.bar(y)&.baz(z)'],
      ['safe navigation at last only', 'x.foo.bar&.baz'],
      ['safe navigation at last only with argument', 'x.foo(x).bar(y)&.baz(z)'],
      ['safe navigation with == operator', 'x&.foo == bar'],
      ['safe navigation with === operator', 'x&.foo === bar'],
      ['safe navigation with || operator', 'x&.foo || bar'],
      ['safe navigation with && operator', 'x&.foo && bar'],
      ['safe navigation with | operator', 'x&.foo | bar'],
      ['safe navigation with & operator', 'x&.foo & bar'],
      ['safe navigation with `nil?` method', 'x&.foo.nil?'],
      ['safe navigation with `present?` method', 'x&.foo.present?'],
      ['safe navigation with `blank?` method', 'x&.foo.blank?'],
      ['safe navigation with `try` method', 'a&.b.try(:c)'],
      ['safe navigation with assignment method', 'x&.foo = bar'],
      ['safe navigation with self assignment method', 'x&.foo += bar'],
      ['safe navigation with `to_d` method', 'x&.foo.to_d'],
      ['safe navigation with `in?` method', 'x&.foo.in?([:baz, :qux])'],
      ['safe navigation with `+@` method', '+str&.to_i'],
      ['safe navigation with `-@` method', '-str&.to_i']
    ].each do |name, code|
      include_examples 'accepts', name, code
    end

    it 'registers an offense for ordinary method call exists after safe navigation method call' do
      expect_offense(<<~RUBY)
        x&.foo.bar
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.bar
      RUBY
    end

    it 'registers an offense for ordinary method call exists after ' \
       'safe navigation method call with an argument' do
      expect_offense(<<~RUBY)
        x&.foo(x).bar(y)
                 ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo(x)&.bar(y)
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after safe navigation method call' do
      expect_offense(<<~RUBY)
        something
        x&.foo.bar.baz
              ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with an argument' do
      expect_offense(<<~RUBY)
        x&.foo(x).bar(y).baz(z)
                 ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo(x)&.bar(y)&.baz(z)
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block-pass' do
      expect_offense(<<~RUBY)
        something
        x&.select(&:foo).bar
                        ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select(&:foo)&.bar
      RUBY
    end

    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block' do
      expect_offense(<<~RUBY)
        something
        x&.select { |x| foo(x) }.bar
                                ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select { |x| foo(x) }&.bar
      RUBY
    end

    it 'registers an offense for safe navigation with < operator' do
      expect_offense(<<~RUBY)
        x&.foo < bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. < bar
      RUBY
    end

    it 'registers an offense for safe navigation with > operator' do
      expect_offense(<<~RUBY)
        x&.foo > bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. > bar
      RUBY
    end

    it 'registers an offense for safe navigation with <= operator' do
      expect_offense(<<~RUBY)
        x&.foo <= bar
              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. <= bar
      RUBY
    end

    it 'registers an offense for safe navigation with >= operator' do
      expect_offense(<<~RUBY)
        x&.foo >= bar
              ^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. >= bar
      RUBY
    end

    it 'registers an offense for safe navigation with + operator' do
      expect_offense(<<~RUBY)
        x&.foo + bar
              ^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&. + bar
      RUBY
    end

    it 'registers an offense for safe navigation with [] operator' do
      expect_offense(<<~RUBY)
        x&.foo[bar]
              ^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.[](bar)
      RUBY
    end

    it 'registers an offense for safe navigation with [] operator followed by method chain' do
      expect_offense(<<~RUBY)
        x&.foo[bar].to_s
              ^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.[](bar).to_s
      RUBY
    end

    it 'registers an offense for safe navigation with []= operator' do
      expect_offense(<<~RUBY)
        x&.foo[bar] = baz
              ^^^^^^^^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x&.foo&.[]=(bar, baz)
      RUBY
    end

    it 'registers an offense for [] operator followed by a safe navigation and method chain' do
      expect_offense(<<~RUBY)
        foo[bar]&.x.y
                   ^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        foo[bar]&.x&.y
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `+`' do
      expect_offense(<<~RUBY)
        x + foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x + foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `-`' do
      expect_offense(<<~RUBY)
        x - foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x - foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `*`' do
      expect_offense(<<~RUBY)
        x * foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x * foo&.bar&.baz
      RUBY
    end

    it 'registers an offense for safe navigation on the right-hand side of the `/`' do
      expect_offense(<<~RUBY)
        x / foo&.bar.baz
                    ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        x / foo&.bar&.baz
      RUBY
    end

    context 'proper highlighting' do
      it 'when there are methods before' do
        expect_offense(<<~RUBY)
          something
          x&.foo.bar.baz
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        RUBY

        expect_correction(<<~RUBY)
          something
          x&.foo&.bar&.baz
        RUBY
      end

      it 'when there are methods after' do
        expect_offense(<<~RUBY)
          x&.foo.bar.baz
                ^^^^ Do not chain ordinary method call after safe navigation operator.
          something
        RUBY

        expect_correction(<<~RUBY)
          x&.foo&.bar&.baz
          something
        RUBY
      end

      it 'when in a method' do
        expect_offense(<<~RUBY)
          def something
            x&.foo.bar.baz
                  ^^^^ Do not chain ordinary method call after safe navigation operator.
          end
        RUBY

        expect_correction(<<~RUBY)
          def something
            x&.foo&.bar&.baz
          end
        RUBY
      end

      it 'when in a begin' do
        expect_offense(<<~RUBY)
          begin
            x&.foo.bar.baz
                  ^^^^ Do not chain ordinary method call after safe navigation operator.
          end
        RUBY

        expect_correction(<<~RUBY)
          begin
            x&.foo&.bar&.baz
          end
        RUBY
      end

      it 'when used with a modifier if' do
        expect_offense(<<~RUBY)
          x&.foo.bar.baz if something
                ^^^^ Do not chain ordinary method call after safe navigation operator.
        RUBY

        expect_correction(<<~RUBY)
          x&.foo&.bar&.baz if something
        RUBY
      end
    end
  end

  context '>= Ruby 2.7', :ruby27 do
    it 'registers an offense for ordinary method chain exists after ' \
       'safe navigation method call with a block using numbered parameter' do
      expect_offense(<<~RUBY)
        something
        x&.select { foo(_1) }.bar
                             ^^^^ Do not chain ordinary method call after safe navigation operator.
      RUBY

      expect_correction(<<~RUBY)
        something
        x&.select { foo(_1) }&.bar
      RUBY
    end
  end
end
