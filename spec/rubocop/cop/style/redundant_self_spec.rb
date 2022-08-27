# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::RedundantSelf, :config do
  it 'reports an offense a self receiver on an rvalue' do
    expect_offense(<<~RUBY)
      a = self.b
          ^^^^ Redundant `self` detected.
    RUBY

    expect_correction(<<~RUBY)
      a = b
    RUBY
  end

  it 'does not report an offense when receiver and lvalue have the same name' do
    expect_no_offenses('a = self.a')
  end

  it 'accepts when nested receiver and lvalue have the name name' do
    expect_no_offenses('a = self.a || b || c')
  end

  it 'does not report an offense when receiver and multiple assigned lvalue have the same name' do
    expect_no_offenses('a, b = self.a')
  end

  it 'does not report an offense when lvasgn name is used in `if`' do
    expect_no_offenses('a = self.a if self.a')
  end

  it 'does not report an offense when masgn name is used in `if`' do
    expect_no_offenses('a, b = self.a if self.a')
  end

  it 'does not report an offense when lvasgn name is used in `unless`' do
    expect_no_offenses('a = self.a unless self.a')
  end

  it 'does not report an offense when masgn name is used in `unless`' do
    expect_no_offenses('a, b = self.a unless self.a')
  end

  it 'does not report an offense when lvasgn name is used in `while`' do
    expect_no_offenses('a = self.a while self.a')
  end

  it 'does not report an offense when masgn name is used in `while`' do
    expect_no_offenses('a, b = self.a while self.a')
  end

  it 'does not report an offense when lvasgn name is used in `until`' do
    expect_no_offenses('a = self.a until self.a')
  end

  it 'does not report an offense when masgn name is used in `until`' do
    expect_no_offenses('a, b = self.a until self.a')
  end

  it 'does not report an offense when lvasgn name is nested below `if`' do
    expect_no_offenses('a = self.a if foo(self.a)')
  end

  it 'reports an offense when a different lvasgn name is used in `if`' do
    expect_offense(<<~RUBY)
      a = x if self.b
               ^^^^ Redundant `self` detected.
    RUBY
  end

  it 'reports an offense when a different masgn name is used in `if`' do
    expect_offense(<<~RUBY)
      a, b, c = x if self.d
                     ^^^^ Redundant `self` detected.
    RUBY
  end

  it 'does not report an offense when self receiver in a method argument and ' \
     'lvalue have the same name' do
    expect_no_offenses('a = do_something(self.a)')
  end

  it 'does not report an offense when self receiver in a method argument and ' \
     'multiple assigned lvalue have the same name' do
    expect_no_offenses('a, b = do_something(self.a)')
  end

  it 'accepts a self receiver on an lvalue of an assignment' do
    expect_no_offenses('self.a = b')
  end

  it 'accepts a self receiver on an lvalue of a parallel assignment' do
    expect_no_offenses('a, self.b = c, d')
  end

  it 'accepts a self receiver on an lvalue of an or-assignment' do
    expect_no_offenses('self.logger ||= Rails.logger')
  end

  it 'accepts a self receiver on an lvalue of an and-assignment' do
    expect_no_offenses('self.flag &&= value')
  end

  it 'accepts a self receiver on an lvalue of a plus-assignment' do
    expect_no_offenses('self.sum += 10')
  end

  it 'accepts a self receiver with the square bracket operator' do
    expect_no_offenses('self[a]')
  end

  it 'accepts a self receiver with the double less-than operator' do
    expect_no_offenses('self << a')
  end

  it 'accepts a self receiver for methods named like ruby keywords' do
    expect_no_offenses(<<~RUBY)
      a = self.class
      self.for(deps, [], true)
      self.and(other)
      self.or(other)
      self.alias
      self.begin
      self.break
      self.case
      self.def
      self.defined?
      self.do
      self.else
      self.elsif
      self.end
      self.ensure
      self.false
      self.if
      self.in
      self.module
      self.next
      self.nil
      self.not
      self.redo
      self.rescue
      self.retry
      self.return
      self.self
      self.super
      self.then
      self.true
      self.undef
      self.unless
      self.until
      self.when
      self.while
      self.yield
      self.__FILE__
      self.__LINE__
      self.__ENCODING__
    RUBY
  end

  it 'accepts a self receiver used to distinguish from argument of block' do
    expect_no_offenses(<<~RUBY)
      %w[draft preview moderation approved rejected].each do |state|
        self.state == state
        define_method "\#{state}?" do
          self.state == state
        end
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers offense for self usage in numblocks' do
      expect_offense(<<~RUBY)
        %w[x y z].select do
          self.axis == _1
          ^^^^ Redundant `self` detected.
        end
      RUBY

      expect_correction(<<~RUBY)
        %w[x y z].select do
          axis == _1
        end
      RUBY
    end
  end

  describe 'instance methods' do
    it 'accepts a self receiver used to distinguish from blockarg' do
      expect_no_offenses(<<~RUBY)
        def requested_specs(&groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from argument' do
      expect_no_offenses(<<~RUBY)
        def requested_specs(groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from optional argument' do
      expect_no_offenses(<<~RUBY)
        def requested_specs(final = true)
          something if self.final != final
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from local variable' do
      expect_no_offenses(<<~RUBY)
        def requested_specs
          @requested_specs ||= begin
            groups = self.groups - Bundler.settings.without
            groups.map! { |g| g.to_sym }
            specs_for(groups)
          end
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from an argument' do
      expect_no_offenses(<<~RUBY)
        def foo(bar)
          puts bar, self.bar
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from an argument ' \
       'when an inner method is defined' do
      expect_no_offenses(<<~RUBY)
        def foo(bar)
          def inner_method(); end
          puts bar, self.bar
        end
      RUBY
    end
  end

  describe 'class methods' do
    it 'accepts a self receiver used to distinguish from blockarg' do
      expect_no_offenses(<<~RUBY)
        def self.requested_specs(&groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from argument' do
      expect_no_offenses(<<~RUBY)
        def self.requested_specs(groups)
          some_method(self.groups)
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from optional argument' do
      expect_no_offenses(<<~RUBY)
        def self.requested_specs(final = true)
          something if self.final != final
        end
      RUBY
    end

    it 'accepts a self receiver used to distinguish from local variable' do
      expect_no_offenses(<<~RUBY)
        def self.requested_specs
          @requested_specs ||= begin
            groups = self.groups - Bundler.settings.without
            groups.map! { |g| g.to_sym }
            specs_for(groups)
          end
        end
      RUBY
    end
  end

  it 'accepts a self receiver used to distinguish from constant' do
    expect_no_offenses('self.Foo')
  end

  it 'accepts a self receiver of .()' do
    expect_no_offenses('self.()')
  end

  it 'reports an offense a self receiver of .call' do
    expect_offense(<<~RUBY)
      self.call
      ^^^^ Redundant `self` detected.
    RUBY

    expect_correction(<<~RUBY)
      call
    RUBY
  end

  it 'accepts a self receiver of methods also defined on `Kernel`' do
    expect_no_offenses('self.open')
  end

  it 'accepts a self receiver on an lvalue of mlhs arguments' do
    expect_no_offenses(<<~RUBY)
      def do_something((a, b)) # This method expects Array that has 2 elements as argument.
        self.a = a
        self.b.some_method_call b
      end
    RUBY
  end

  context 'with ruby >= 2.7', :ruby27 do
    context 'with pattern matching' do
      it 'accepts a self receiver on an `match-var`' do
        expect_no_offenses(<<~RUBY)
          case foo
            in Integer => bar
              self.bar + bar
          end
        RUBY
      end

      it 'accepts a self receiver on a `hash-pattern`' do
        expect_no_offenses(<<~RUBY)
          case pattern
            in {x: foo}
              self.foo + foo
          end
        RUBY
      end

      it 'accepts a self receiver on a `array-pattern`' do
        expect_no_offenses(<<~RUBY)
          case pattern
            in [foo, bar]
              self.foo + foo
          end
        RUBY
      end

      it 'accepts a self receiver with a `match-alt`' do
        expect_no_offenses(<<~RUBY)
          case pattern
            in [foo] | { x: bar }
              self.foo + self.bar + foo + bar
          end
        RUBY
      end

      it 'accepts a self receiver in a nested pattern`' do
        expect_no_offenses(<<~RUBY)
          case pattern
            in { foo: [bar, baz] }
              self.bar + self.baz
          end
        RUBY
      end

      it 'accepts a self receiver in a conditional pattern' do
        expect_no_offenses(<<~RUBY)
          case pattern
            in a, b if b == a * 2
              self.a + b
          end
        RUBY
      end

      it 'accepts a self receiver in a `if-guard`' do
        expect_no_offenses(<<~RUBY)
          case pattern
            in a, b if b == self.a * 2
              a + b
          end
        RUBY
      end

      it 'registers an offense when using a self receiver with a pin' do
        expect_offense(<<~RUBY)
          foo = 17
          case pattern
            in ^foo, *bar
              self.foo + self.bar + foo + bar
              ^^^^ Redundant `self` detected.
          end
        RUBY
      end

      it 'registers an offense when using self with a different match var' do
        expect_offense(<<~RUBY)
          case foo
            in Integer => bar
              self.bar + bar
            in Float => baz
              self.bar + baz
              ^^^^ Redundant `self` detected.
          end
        RUBY

        expect_correction(<<~RUBY)
          case foo
            in Integer => bar
              self.bar + bar
            in Float => baz
              bar + baz
          end
        RUBY
      end
    end
  end
end
