# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Naming::PredicateMethod, :config do
  let(:allowed_methods) { [] }
  let(:allowed_patterns) { [] }
  let(:allow_bang_methods) { false }
  let(:wayward_predicates) { [] }
  let(:cop_config) do
    {
      'Mode' => mode,
      'AllowedMethods' => allowed_methods,
      'AllowedPatterns' => allowed_patterns,
      'AllowBangMethods' => allow_bang_methods,
      'WaywardPredicates' => wayward_predicates
    }
  end

  shared_examples 'predicate' do |return_statement, implicit: true, explicit: true|
    if implicit
      context 'implicit return' do
        it 'registers an offense when the method name does not end with `?`' do
          expect_offense(<<~RUBY)
            def foo
                ^^^ Predicate method names should end with `?`.
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when the method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo?
              #{return_statement}
            end
          RUBY
        end

        it 'registers an offense when a `defs` method name does not end with `?`' do
          expect_offense(<<~RUBY)
            def self.foo
                     ^^^ Predicate method names should end with `?`.
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo?
              #{return_statement}
            end
          RUBY
        end
      end
    end

    if explicit
      context 'explicit return' do
        it 'registers an offense when the method name does not end with `?`' do
          expect_offense(<<~RUBY)
            def foo
                ^^^ Predicate method names should end with `?`.
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when the method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo?
              return #{return_statement}
            end
          RUBY
        end

        it 'registers an offense when a `defs` method name does not end with `?`' do
          expect_offense(<<~RUBY)
            def self.foo
                     ^^^ Predicate method names should end with `?`.
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo?
              return #{return_statement}
            end
          RUBY
        end
      end
    end
  end

  shared_examples 'non-predicate' do |return_statement, implicit: true, explicit: true|
    if implicit
      context 'implicit return' do
        it 'registers an offense when the method name ends with `?`' do
          expect_offense(<<~RUBY)
            def foo?
                ^^^^ Non-predicate method names should not end with `?`.
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when the method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo
              #{return_statement}
            end
          RUBY
        end

        it 'registers an offense when a `defs` method name ends with `?`' do
          expect_offense(<<~RUBY)
            def self.foo?
                     ^^^^ Non-predicate method names should not end with `?`.
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo
              #{return_statement}
            end
          RUBY
        end
      end
    end

    if explicit
      context 'explicit return' do
        it 'registers an offense when the method name ends with `?`' do
          expect_offense(<<~RUBY)
            def foo?
                ^^^^ Non-predicate method names should not end with `?`.
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when the method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo
              return #{return_statement}
            end
          RUBY
        end

        it 'registers an offense when a `defs` method name ends with `?`' do
          expect_offense(<<~RUBY)
            def self.foo?
                     ^^^^ Non-predicate method names should not end with `?`.
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo
              return #{return_statement}
            end
          RUBY
        end
      end
    end
  end

  shared_examples 'acceptable' do |return_statement, implicit: true, explicit: true|
    if implicit
      context 'implicit return' do
        it 'does not register an offense when the method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo?
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when the method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo?
              #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo
              #{return_statement}
            end
          RUBY
        end
      end
    end

    if explicit
      context 'explicit return' do
        it 'does not register an offense when the method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo?
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when the method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo?
              return #{return_statement}
            end
          RUBY
        end

        it 'does not register an offense when a `defs` method name does not end with `?`' do
          expect_no_offenses(<<~RUBY)
            def self.foo
              return #{return_statement}
            end
          RUBY
        end
      end
    end
  end

  shared_examples 'common functionality' do
    it 'does not register an offense for a `def` without a body' do
      expect_no_offenses(<<~RUBY)
        def foo
        end
      RUBY
    end

    it 'does not register an offense for a `defs` without a body' do
      expect_no_offenses(<<~RUBY)
        def self.foo
        end
      RUBY
    end

    it 'does not register an offense for a `def` with empty parentheses body' do
      expect_no_offenses(<<~RUBY)
        def foo
          ()
        end
      RUBY
    end

    it 'does not register an offense for a `defs` with empty parentheses body' do
      expect_no_offenses(<<~RUBY)
        def self.foo
          ()
        end
      RUBY
    end

    it 'does not register an offense for an `in` pattern with empty parentheses body' do
      expect_no_offenses(<<~RUBY)
        def foo
          case expr
          in pattern
            ()
          end
        end
      RUBY
    end

    context 'bare return' do
      it_behaves_like 'non-predicate', '', implicit: false

      it 'does not register an offense for a method that has a bare return and an implicit return value' do
        expect_no_offenses(<<~RUBY)
          def foo
            return if bar

            false
          end
        RUBY
      end
    end

    context 'methods returning comparisons' do
      %i[== === != <= >= > <].each do |method|
        context "when returning a `#{method}` comparison" do
          it_behaves_like 'predicate', "bar #{method} baz"
        end
      end

      context 'compound comparisons' do
        it_behaves_like 'predicate', 'a > b && c < d'
        it_behaves_like 'predicate', 'a > b && c < d && e != f'
        it_behaves_like 'predicate', 'a > b || c < d'
        it_behaves_like 'predicate', 'a > b || c < d || e != f'
        it_behaves_like 'predicate', 'a > b && c < d || e != f'
      end
    end

    context 'methods returning negations' do
      ['5', 'true', 'false', 'nil', '[]', 'a', 'a?', '(a == b)'].each do |value|
        it_behaves_like 'predicate', "!#{value}"
        it_behaves_like 'predicate', "(not #{value})"
      end
    end

    context 'methods returning boolean literals' do
      it_behaves_like 'predicate', 'true'
      it_behaves_like 'predicate', 'false'
    end

    context 'methods returning non-boolean literals' do
      it_behaves_like 'non-predicate', 'nil'
      it_behaves_like 'non-predicate', '5'
      it_behaves_like 'non-predicate', '5.0'
      it_behaves_like 'non-predicate', '5r'
      it_behaves_like 'non-predicate', '5i'
      it_behaves_like 'non-predicate', '"string"'
      it_behaves_like 'non-predicate', '"#{string}"'
      it_behaves_like 'non-predicate', '`string`'
      it_behaves_like 'non-predicate', ':sym'
      it_behaves_like 'non-predicate', ':"#{sym}"'
      it_behaves_like 'non-predicate', '[]'
      it_behaves_like 'non-predicate', '{}'
      it_behaves_like 'non-predicate', '/regexp/'
      it_behaves_like 'non-predicate', '(1..2)'
      it_behaves_like 'non-predicate', '(1...2)'
    end

    context 'conditionals' do
      it_behaves_like 'predicate', <<~RUBY, explicit: false
        if x
          true
        elsif y
          true
        else
          false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        if x
          return true
        elsif y
          return true
        else
          return false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        unless x
          true
        else
          false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        unless x
          return true
        else
          return false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        case x
        when y
          true
        when z
          true
        else
          false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        case x
        when y
          return true
        when z
          return true
        else
          return false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        case x
          in y then true
          else false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        case x
          in y then return true
          else return false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        while x
          false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        while x
          return false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        until x
          false
        end
      RUBY

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        until x
          return false
        end
      RUBY

      context 'conditional containing compound comparison' do
        it_behaves_like 'predicate', <<~RUBY, explicit: false
          if x
            a > b && c < d
          else
            false
          end
        RUBY
      end

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        if foo?
          return bar
        else
          return baz
        end
      RUBY

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        if x
          bar
        else
          baz
        end
      RUBY
    end

    context 'super' do
      it_behaves_like 'predicate', 'super == bar'

      it_behaves_like 'acceptable', 'super'
      it_behaves_like 'acceptable', 'super()'
      it_behaves_like 'acceptable', 'super(var)'
    end

    context 'method calls' do
      it_behaves_like 'acceptable', 'bar'
      it_behaves_like 'acceptable', 'bar()'
      it_behaves_like 'acceptable', 'bar(baz)'
    end

    context 'methods returning other predicates' do
      it_behaves_like 'predicate', 'bar?'
      it_behaves_like 'predicate', 'bar?()'
      it_behaves_like 'predicate', 'bar?(baz)'
      it_behaves_like 'predicate', 'bar.baz?'

      it_behaves_like 'predicate', <<~RUBY, explicit: false
        if bar
          baz?
        else
          false
        end
      RUBY
    end

    context 'variables' do
      it_behaves_like 'acceptable', 'bar = x; bar'
      it_behaves_like 'acceptable', '@bar'
      it_behaves_like 'acceptable', '@@bar'
      it_behaves_like 'acceptable', '$bar'
    end

    context 'multiple return' do
      it_behaves_like 'non-predicate', '1, 2', implicit: false
      it_behaves_like 'non-predicate', '[1, 2]'
    end

    context '`initialize` method' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          def initialize
            foo?
          end
        RUBY
      end
    end

    context 'operator methods' do
      it 'does not register an offense if it would otherwise be treated as a predicate' do
        expect_no_offenses(<<~RUBY)
          def ==(other)
            hash == other.hash
          end
        RUBY
      end
    end

    context 'endless methods', :ruby30 do
      it 'registers an offense for predicates without a `?`' do
        expect_offense(<<~RUBY)
          def foo = true
              ^^^ Predicate method names should end with `?`.
        RUBY
      end

      it 'registers an offense for non-predicates with a `?`' do
        expect_offense(<<~RUBY)
          def foo? = 5
              ^^^^ Non-predicate method names should not end with `?`.
        RUBY
      end
    end

    context 'with AllowedMethods' do
      let(:allowed_methods) { %w[on_defined?] }

      it 'does not register an offense for an allowed method name' do
        expect_no_offenses(<<~RUBY)
          def on_defined?(node)
            add_offense(node)
          end
        RUBY
      end
    end

    context 'with AllowedPatterns' do
      let(:allowed_patterns) { %w[\Afoo] }

      it 'does not register an offense for a method name that matches the pattern' do
        expect_no_offenses(<<~RUBY)
          def foo?
            'foo'
          end
        RUBY
      end

      it 'registers an offense for a method name that does not match the pattern' do
        expect_offense(<<~RUBY)
          def barfoo?
              ^^^^^^^ Non-predicate method names should not end with `?`.
            'bar'
          end
        RUBY
      end
    end

    context 'with AllowBangMethods: true' do
      let(:allow_bang_methods) { true }

      it 'does not register an offense for a bang method that returns a boolean' do
        expect_no_offenses(<<~RUBY)
          def save!
            true
          end
        RUBY
      end
    end

    context 'with AllowBangMethods: false' do
      let(:allow_bang_methods) { false }

      it 'registers an offense for a bang method that returns a boolean' do
        expect_offense(<<~RUBY)
          def save!
              ^^^^^ Predicate method names should end with `?`.
            true
          end
        RUBY
      end
    end

    context 'with WaywardPredicates' do
      let(:wayward_predicates) { %w[nonzero?] }

      it_behaves_like 'acceptable', 'nonzero?'
    end
  end

  context 'with Mode: conservative' do
    let(:mode) { :conservative }

    it_behaves_like 'common functionality'

    context 'methods returning mixed values' do
      context 'when the implicit return is boolean' do
        it 'does not register an offense when the method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo?
              return 5 if bar?
              true
            end
          RUBY
        end
      end

      context 'when the implicit return is not boolean' do
        it 'does not register an offense when the method name ends with `?`' do
          expect_no_offenses(<<~RUBY)
            def foo?
              return true if bar?
              5
            end
          RUBY
        end
      end
    end

    context 'conditionals' do
      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        if bar?
          baz
        else
          nil
        end
      RUBY
    end

    context 'conditionals with empty branches' do
      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        if x
        else
          false
        end
      RUBY

      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        while x
        end
      RUBY
    end

    context 'conditionals without else' do
      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        true if x
      RUBY

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        if x
          true
        end
      RUBY

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        case x
          when y then true
        end
      RUBY

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        case x
          in y then true
        end
      RUBY
    end

    context 'super' do
      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        return if something
        super
      RUBY

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        return if something
        super()
      RUBY
    end

    context 'method calls' do
      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        return if something
        true
      RUBY

      it_behaves_like 'acceptable', <<~RUBY, explicit: false
        return if something
        bar?
      RUBY
    end
  end

  context 'with Mode: aggressive' do
    let(:mode) { :aggressive }

    it_behaves_like 'common functionality'

    context 'when the implicit return is boolean' do
      it 'registers an offense when the method name ends with `?`' do
        expect_offense(<<~RUBY)
          def foo?
              ^^^^ Non-predicate method names should not end with `?`.
            return 5 if bar?
            true
          end
        RUBY
      end
    end

    context 'when the implicit return is not boolean' do
      it 'registers an offense when the method name ends with `?`' do
        expect_offense(<<~RUBY)
          def foo?
              ^^^^ Non-predicate method names should not end with `?`.
            return true if bar?
            5
          end
        RUBY
      end
    end

    context 'conditionals' do
      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        if bar?
          baz
        else
          nil
        end
      RUBY
    end

    context 'conditionals with empty branches' do
      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        if x
        else
          false
        end
      RUBY
    end

    context 'conditionals without else' do
      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        true if x
      RUBY

      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        if x
          true
        end
      RUBY

      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        case x
          when y then true
        end
      RUBY

      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        case x
          in y then true
        end
      RUBY
    end

    context 'mixed comparisons' do
      it_behaves_like 'non-predicate', 'a > b && "yes"'
    end

    context 'super' do
      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        return if something
        super
      RUBY

      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        return if something
        super()
      RUBY
    end

    context 'method calls' do
      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        return if something
        true
      RUBY

      it_behaves_like 'non-predicate', <<~RUBY, explicit: false
        return if something
        bar?
      RUBY
    end
  end
end
