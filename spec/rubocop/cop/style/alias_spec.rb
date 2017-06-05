# frozen_string_literal: true

describe RuboCop::Cop::Style::Alias, :config do
  subject(:cop) { described_class.new(config) }

  context 'when EnforcedStyle is prefer_alias_method' do
    let(:cop_config) { { 'EnforcedStyle' => 'prefer_alias_method' } }

    it 'registers an offense for alias with symbol args' do
      expect_offense(<<-RUBY.strip_indent)
        alias :ala :bala
        ^^^^^ Use `alias_method` instead of `alias`.
      RUBY
    end

    it 'autocorrects alias with symbol args' do
      corrected = autocorrect_source(cop, 'alias :ala :bala')
      expect(corrected).to eq 'alias_method :ala, :bala'
    end

    it 'registers an offense for alias with bareword args' do
      expect_offense(<<-RUBY.strip_indent)
        alias ala bala
        ^^^^^ Use `alias_method` instead of `alias`.
      RUBY
    end

    it 'autocorrects alias with bareword args' do
      corrected = autocorrect_source(cop, 'alias ala bala')
      expect(corrected).to eq 'alias_method :ala, :bala'
    end

    it 'does not register an offense for alias_method' do
      expect_no_offenses('alias_method :ala, :bala')
    end

    it 'does not register an offense for alias with gvars' do
      expect_no_offenses('alias $ala $bala')
    end

    it 'does not register an offense for alias in an instance_eval block' do
      expect_no_offenses(<<-RUBY.strip_indent)
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
      expect_offense(<<-RUBY.strip_indent)
        alias :ala :bala
              ^^^^^^^^^^ Use `alias ala bala` instead of `alias :ala :bala`.
      RUBY
    end

    it 'autocorrects alias with symbol args' do
      corrected = autocorrect_source(cop, ['alias :ala :bala'])
      expect(corrected).to eq 'alias ala bala'
    end

    it 'does not register an offense for alias with bareword args' do
      expect_no_offenses('alias ala bala')
    end

    it 'registers an offense for alias_method at the top level' do
      expect_offense(<<-RUBY.strip_indent)
        alias_method :ala, :bala
        ^^^^^^^^^^^^ Use `alias` instead of `alias_method` at the top level.
      RUBY
    end

    it 'autocorrects alias_method at the top level' do
      corrected = autocorrect_source(cop, 'alias_method :ala, :bala')
      expect(corrected).to eq 'alias ala bala'
    end

    it 'registers an offense for alias_method in a class block' do
      expect_offense(<<-RUBY.strip_indent)
        class C
          alias_method :ala, :bala
          ^^^^^^^^^^^^ Use `alias` instead of `alias_method` in a class body.
        end
      RUBY
    end

    it 'autocorrects alias_method in a class block' do
      corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
        class C
          alias_method :ala, :bala
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        class C
          alias ala bala
        end
      RUBY
    end

    it 'registers an offense for alias_method in a module block' do
      expect_offense(<<-RUBY.strip_indent)
        module M
          alias_method :ala, :bala
          ^^^^^^^^^^^^ Use `alias` instead of `alias_method` in a module body.
        end
      RUBY
    end

    it 'autocorrects alias_method in a module block' do
      corrected = autocorrect_source(cop, <<-RUBY.strip_indent)
        module M
          alias_method :ala, :bala
        end
      RUBY
      expect(corrected).to eq(<<-RUBY.strip_indent)
        module M
          alias ala bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method with explicit receiver' do
      expect_no_offenses(<<-RUBY.strip_indent)
        class C
          receiver.alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method in a method def' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def method
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method in self.method def' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def self.method
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method in a block' do
      expect_no_offenses(<<-RUBY.strip_indent)
        dsl_method do
          alias_method :ala, :bala
        end
      RUBY
    end

    it 'does not register an offense for alias_method with non-literal '\
       'argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        alias_method :bar, FOO
      RUBY
    end

    it 'does not register an offense for alias_method with non-literal ' \
       'argument' do
      expect_no_offenses(<<-RUBY.strip_indent)
        alias_method :baz, foo.bar
      RUBY
    end

    it 'does not register an offense for alias in an instance_eval block' do
      expect_no_offenses(<<-RUBY.strip_indent)
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
