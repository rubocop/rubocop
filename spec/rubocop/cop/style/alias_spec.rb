# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::Alias, :config do
  context 'when EnforcedStyle is prefer_alias_method' do
    let(:cop_config) { { 'EnforcedStyle' => 'prefer_alias_method' } }

    it 'registers an offense for alias with symbol args' do
      expect_offense(<<~RUBY)
        alias :ala :bala
        ^^^^^ Use `alias_method` instead of `alias`.
      RUBY

      expect_correction(<<~RUBY)
        alias_method :ala, :bala
      RUBY
    end

    it 'registers an offense for alias with bareword args' do
      expect_offense(<<~RUBY)
        alias ala bala
        ^^^^^ Use `alias_method` instead of `alias`.
      RUBY

      expect_correction(<<~RUBY)
        alias_method :ala, :bala
      RUBY
    end

    it 'does not register an offense for alias_method' do
      expect_no_offenses('alias_method :ala, :bala')
    end

    it 'does not register an offense for alias with gvars' do
      expect_no_offenses('alias $ala $bala')
    end

    it 'does not register an offense for alias in an instance_eval block' do
      expect_no_offenses(<<~RUBY)
        module M
          def foo
            instance_eval {
              alias bar baz
            }
          end
        end
      RUBY
    end
  end

  context 'when EnforcedStyle is prefer_alias' do
    let(:cop_config) { { 'EnforcedStyle' => 'prefer_alias' } }

    it 'registers an offense for alias with symbol args' do
      expect_offense(<<~RUBY)
        alias :ala :bala
              ^^^^^^^^^^ Use `alias ala bala` instead of `alias :ala :bala`.
      RUBY

      expect_correction(<<~RUBY)
        alias ala bala
      RUBY
    end

    it 'does not register an offense for alias with bareword args' do
      expect_no_offenses('alias ala bala')
    end

    it 'registers an offense for alias_method at the top level' do
      expect_offense(<<~RUBY)
        alias_method :ala, :bala
        ^^^^^^^^^^^^ Use `alias` instead of `alias_method` at the top level.
      RUBY

      expect_correction(<<~RUBY)
        alias ala bala
      RUBY
    end

    it 'registers an offense for alias_method in a class block' do
      expect_offense(<<~RUBY)
        class C
          alias_method :ala, :bala
          ^^^^^^^^^^^^ Use `alias` instead of `alias_method` in a class body.
        end
      RUBY

      expect_correction(<<~RUBY)
        class C
          alias ala bala
        end
      RUBY
    end

    it 'registers an offense for alias_method in a module block' do
      expect_offense(<<~RUBY)
        module M
          alias_method :ala, :bala
          ^^^^^^^^^^^^ Use `alias` instead of `alias_method` in a module body.
        end
      RUBY

      expect_correction(<<~RUBY)
        module M
          alias ala bala
        end
      RUBY
    end

    it 'does not register registers an offense for alias in a def' do
      expect_no_offenses(<<~RUBY)
        def foo
          alias :ala :bala
        end
      RUBY
    end

    it 'registers an offense for alias in a defs' do
      expect_offense(<<~RUBY)
        def some_obj.foo
          alias :ala :bala
          ^^^^^ Use `alias_method` instead of `alias`.
        end
      RUBY

      expect_correction(<<~RUBY)
        def some_obj.foo
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'registers an offense for alias in a block' do
      expect_offense(<<~RUBY)
        included do
          alias :ala :bala
          ^^^^^ Use `alias_method` instead of `alias`.
        end
      RUBY

      expect_correction(<<~RUBY)
        included do
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method with explicit receiver' do
      expect_no_offenses(<<~RUBY)
        class C
          receiver.alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method in self.method def' do
      expect_no_offenses(<<~RUBY)
        def self.method
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method in a block' do
      expect_no_offenses(<<~RUBY)
        dsl_method do
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method with non-literal constant argument' do
      expect_no_offenses(<<~RUBY)
        alias_method :bar, FOO
      RUBY
    end

    it 'does not register an offense for alias_method with non-literal method call argument' do
      expect_no_offenses(<<~RUBY)
        alias_method :baz, foo.bar
      RUBY
    end

    it 'does not register an offense for alias in an instance_eval block' do
      expect_no_offenses(<<~RUBY)
        module M
          def foo
            instance_eval {
              alias bar baz
            }
          end
        end
      RUBY
    end
  end
end
