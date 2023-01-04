# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Metrics::ParameterLists, :config do
  let(:cop_config) { { 'Max' => 4, 'CountKeywordArgs' => true, 'MaxOptionalParameters' => 3 } }

  it 'registers an offense for a method def with 5 parameters' do
    expect_offense(<<~RUBY)
      def meth(a, b, c, d, e)
              ^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [5/4]
      end
    RUBY
  end

  it 'accepts a method def with 4 parameters' do
    expect_no_offenses(<<~RUBY)
      def meth(a, b, c, d)
      end
    RUBY
  end

  it 'accepts a proc with more than 4 parameters' do
    expect_no_offenses(<<~RUBY)
      proc { |a, b, c, d, e| }
    RUBY
  end

  it 'accepts a lambda with more than 4 parameters' do
    expect_no_offenses(<<~RUBY)
      ->(a, b, c, d, e) { }
    RUBY
  end

  context 'When CountKeywordArgs is true' do
    it 'counts keyword arguments as well' do
      expect_offense(<<~RUBY)
        def meth(a, b, c, d: 1, e: 2)
                ^^^^^^^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [5/4]
        end
      RUBY
    end
  end

  context 'When CountKeywordArgs is false' do
    before { cop_config['CountKeywordArgs'] = false }

    it 'does not count keyword arguments' do
      expect_no_offenses(<<~RUBY)
        def meth(a, b, c, d: 1, e: 2)
        end
      RUBY
    end

    it 'does not count keyword arguments without default values' do
      expect_no_offenses(<<~RUBY)
        def meth(a, b, c, d:, e:)
        end
      RUBY
    end
  end

  it 'registers an offense when optargs count exceeds the maximum' do
    expect_offense(<<~RUBY)
      def foo(a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7)
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [7/4]
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method has too many optional parameters. [7/3]
      end

      def foo(a = 1, b = 2, c = 3, d = 4)
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Method has too many optional parameters. [4/3]
      end
    RUBY

    expect(cop.config_to_allow_offenses[:exclude_limit]).to eq(
      'Max' => 7,
      'MaxOptionalParameters' => 7
    )
  end

  it 'does not register an offense when method has allowed amount of optargs' do
    expect_no_offenses(<<~RUBY)
      def foo(a, b = 2, c = 3, d = 4)
      end
    RUBY
  end

  it 'does not register an offense when method has allowed amount of args with block arg' do
    expect_no_offenses(<<~RUBY)
      def foo(a, b, c, d, &block)
      end
    RUBY
  end

  it 'does not register an offense when method has no args' do
    expect_no_offenses(<<~RUBY)
      def foo
      end
    RUBY
  end

  it 'registers an offense when defining `initialize` in the `class` definition' do
    expect_offense(<<~RUBY)
      class Foo
        def initialize(one:, two:, three:, four:, five:)
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid parameter lists longer than 4 parameters. [5/4]
        end
      end
    RUBY
  end

  it 'does not register an offense when defining `initialize` in the block of `Struct.new`' do
    expect_no_offenses(<<~RUBY)
      Struct.new(:one, :two, :three, :four, :five) do
        def initialize(one:, two:, three:, four:, five:)
        end
      end
    RUBY
  end

  it 'does not register an offense when defining `initialize` in the block of `::Struct.new`' do
    expect_no_offenses(<<~RUBY)
      ::Struct.new(:one, :two, :three, :four, :five) do
        def initialize(one:, two:, three:, four:, five:)
        end
      end
    RUBY
  end

  it 'does not register an offense when defining `initialize` in the block of `Data.define`' do
    expect_no_offenses(<<~RUBY)
      Data.define(:one, :two, :three, :four, :five) do
        def initialize(one:, two:, three:, four:, five:)
        end
      end
    RUBY
  end

  it 'does not register an offense when defining `initialize` in the block of `::Data.define`' do
    expect_no_offenses(<<~RUBY)
      ::Data.define(:one, :two, :three, :four, :five) do
        def initialize(one:, two:, three:, four:, five:)
        end
      end
    RUBY
  end
end
