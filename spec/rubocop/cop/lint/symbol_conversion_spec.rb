# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::SymbolConversion, :config do
  shared_examples 'offense' do |from, to|
    it "registers an offense for #{from}" do
      expect_offense(<<~RUBY, from: from)
        #{from}
        ^{from} Unnecessary symbol conversion; use `#{to}` instead.
      RUBY

      expect_correction(<<~RUBY, loop: false)
        #{to}
      RUBY
    end
  end

  # Unnecessary `to_sym`
  it_behaves_like 'offense', ':foo.to_sym', ':foo'
  it_behaves_like 'offense', '"foo".to_sym', ':foo'
  it_behaves_like 'offense', '"foo_bar".to_sym', ':foo_bar'
  it_behaves_like 'offense', '"foo-bar".to_sym', ':"foo-bar"'

  # Unnecessary `intern`
  it_behaves_like 'offense', ':foo.intern', ':foo'
  it_behaves_like 'offense', '"foo".intern', ':foo'
  it_behaves_like 'offense', '"foo_bar".intern', ':foo_bar'
  it_behaves_like 'offense', '"foo-bar".intern', ':"foo-bar"'

  # Unnecessary quoted symbol
  it_behaves_like 'offense', ':"foo"', ':foo'
  it_behaves_like 'offense', ':"foo_bar"', ':foo_bar'

  it 'does not register an offense for a normal symbol' do
    expect_no_offenses(<<~RUBY)
      :foo
    RUBY
  end

  it 'does not register an offense for a dstr' do
    expect_no_offenses(<<~'RUBY')
      "#{foo}".to_sym
    RUBY
  end

  it 'does not register an offense for a symbol that requires quotes' do
    expect_no_offenses(<<~RUBY)
      :"foo-bar"
    RUBY
  end

  context 'in a hash' do
    context 'keys' do
      it 'does not register an offense for a normal symbol' do
        expect_no_offenses(<<~RUBY)
          { foo: 'bar' }
        RUBY
      end

      it 'does not register an offense for a require quoted symbol' do
        expect_no_offenses(<<~RUBY)
          { 'foo-bar': 'bar' }
        RUBY
      end

      it 'does not register an offense for a require quoted symbol that contains `:`' do
        expect_no_offenses(<<~RUBY)
          { 'foo:bar': 'bar' }
        RUBY
      end

      it 'does not register an offense for a require quoted symbol that ends with `=`' do
        expect_no_offenses(<<~RUBY)
          { 'foo=': 'bar' }
        RUBY
      end

      it 'registers an offense for a quoted symbol' do
        expect_offense(<<~RUBY)
          { 'foo': 'bar' }
            ^^^^^ Unnecessary symbol conversion; use `foo:` instead.
        RUBY

        expect_correction(<<~RUBY)
          { foo: 'bar' }
        RUBY
      end

      it 'registers and corrects an offense for a quoted symbol that ends with `!`' do
        expect_offense(<<~RUBY)
          { 'foo!': 'bar' }
            ^^^^^^ Unnecessary symbol conversion; use `foo!:` instead.
        RUBY

        expect_correction(<<~RUBY)
          { foo!: 'bar' }
        RUBY
      end

      it 'registers and corrects an offense for a quoted symbol that ends with `?`' do
        expect_offense(<<~RUBY)
          { 'foo?': 'bar' }
            ^^^^^^ Unnecessary symbol conversion; use `foo?:` instead.
        RUBY

        expect_correction(<<~RUBY)
          { foo?: 'bar' }
        RUBY
      end

      it 'does not register an offense for operators' do
        expect_no_offenses(<<~RUBY)
          { '==': 'bar' }
        RUBY
      end
    end

    context 'values' do
      it 'does not register an offense for a normal symbol' do
        expect_no_offenses(<<~RUBY)
          { foo: :bar }
        RUBY
      end

      it 'registers an offense for a quoted symbol key' do
        expect_offense(<<~RUBY)
          { :'foo' => :bar }
            ^^^^^^ Unnecessary symbol conversion; use `:foo` instead.
        RUBY

        expect_correction(<<~RUBY)
          { :foo => :bar }
        RUBY
      end

      it 'registers an offense for a quoted symbol value' do
        expect_offense(<<~RUBY)
          { foo: :'bar' }
                 ^^^^^^ Unnecessary symbol conversion; use `:bar` instead.
        RUBY

        expect_correction(<<~RUBY)
          { foo: :bar }
        RUBY
      end
    end
  end

  context 'in an alias' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        alias foo bar
        alias == equal
        alias eq? ==
      RUBY
    end
  end

  context 'inside a percent literal array' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        %i(foo bar foo-bar)
        %I(foo bar foo-bar)
      RUBY
    end
  end

  context 'single quoted symbol' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        :'Foo/Bar/Baz'
      RUBY
    end
  end

  context 'implicit `to_sym` call' do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        to_sym == other
      RUBY
    end
  end

  context 'EnforcedStyle: consistent' do
    let(:cop_config) { { 'EnforcedStyle' => 'consistent' } }

    context 'hash where no keys need to be quoted' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          {
            a: 1,
            b: 2
          }
        RUBY
      end
    end

    context 'hash where keys are quoted but do not need to be' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          {
            a: 1,
            'b': 2
            ^^^ Unnecessary symbol conversion; use `b:` instead.
          }
        RUBY

        expect_correction(<<~RUBY)
          {
            a: 1,
            b: 2
          }
        RUBY
      end
    end

    context 'hash where there are keys needing quoting' do
      it 'registers an offense for unquoted keys' do
        expect_offense(<<~RUBY)
          {
            a: 1,
            ^ Symbol hash key should be quoted for consistency; use `"a":` instead.
            b: 2,
            ^ Symbol hash key should be quoted for consistency; use `"b":` instead.
            'c': 3,
            'd-e': 4
          }
        RUBY

        expect_correction(<<~RUBY)
          {
            "a": 1,
            "b": 2,
            'c': 3,
            'd-e': 4
          }
        RUBY
      end
    end

    context 'with a key with =' do
      it 'requires symbols to be quoted' do
        expect_offense(<<~RUBY)
          {
            'a=': 1,
            b: 2
            ^ Symbol hash key should be quoted for consistency; use `"b":` instead.
          }
        RUBY

        expect_correction(<<~RUBY)
          {
            'a=': 1,
            "b": 2
          }
        RUBY
      end
    end

    context 'with different quote styles' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          {
            'a': 1,
            "b": 2,
            "c-d": 3,
            'e-f': 4
          }
        RUBY
      end
    end

    context 'with a mix of string and symbol keys' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          {
            'a' => 1,
            'b-c': 2
          }
        RUBY
      end
    end
  end
end
