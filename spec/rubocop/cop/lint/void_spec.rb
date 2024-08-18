# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::Void, :config do
  described_class::BINARY_OPERATORS.each do |op|
    it "registers an offense for void op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        a %{op} b
          ^{op} Operator `#{op}` used in void context.
        a %{op} b
          ^{op} Operator `#{op}` used in void context.
        a %{op} b
      RUBY

      expect_correction(<<~RUBY)
        a
        b
        a
        b
        a #{op} b
      RUBY
    end

    it "accepts void op #{op} if on last line" do
      expect_no_offenses(<<~RUBY)
        something
        a #{op} b
      RUBY
    end

    it "accepts void op #{op} by itself without a begin block" do
      expect_no_offenses("a #{op} b")
    end

    it "registers an offense for parenthesized void op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        (a %{op} b)
           ^{op} Operator `#{op}` used in void context.
        ((a %{op} b))
            ^{op} Operator `#{op}` used in void context.
        (((a %{op} b)))
      RUBY

      # NOTE: Redundant parentheses in `(var)` are left to `Style/RedundantParentheses` to fix.
      expect_correction(<<~RUBY)
        (a
        b)
        ((a
        b))
        (((a #{op} b)))
      RUBY
    end

    it "accepts parenthesized void op #{op} if on last line" do
      expect_no_offenses(<<~RUBY)
        something
        (a #{op} b)
      RUBY
    end

    it "accepts parenthesized void op #{op} by itself without a begin block" do
      expect_no_offenses("(a #{op} b)")
    end
  end

  sign_unary_operators = %i[+ -]
  other_unary_operators = %i[~ !]
  unary_operators = sign_unary_operators + other_unary_operators

  sign_unary_operators.each do |op|
    it "registers an offense for void sign op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        %{op}b
        ^{op} Operator `#{op}@` used in void context.
        %{op}b
        ^{op} Operator `#{op}@` used in void context.
        %{op}b
      RUBY

      expect_correction(<<~RUBY)
        b
        b
        #{op}b
      RUBY
    end
  end

  other_unary_operators.each do |op|
    it "registers an offense for void unary op #{op} if not on last line" do
      expect_offense(<<~RUBY, op: op)
        %{op}b
        ^{op} Operator `#{op}` used in void context.
        %{op}b
        ^{op} Operator `#{op}` used in void context.
        %{op}b
      RUBY

      expect_correction(<<~RUBY)
        b
        b
        #{op}b
      RUBY
    end
  end

  unary_operators.each do |op|
    it "accepts void unary op #{op} if on last line" do
      expect_no_offenses(<<~RUBY)
        something
        #{op}b
      RUBY
    end

    it "accepts void unary op #{op} by itself without a begin block" do
      expect_no_offenses("#{op}b")
    end
  end

  %w[var @var @@var $var].each do |var|
    it "registers an offense for void var #{var} if not on last line" do
      expect_offense(<<~RUBY, var: var)
        %{var} = 5
        %{var}
        ^{var} Variable `#{var}` used in void context.
        top
      RUBY

      expect_correction(<<~RUBY)
        #{var} = 5
        top
      RUBY
    end

    it "registers an offense for void var #{var} with guard clause if not on last line" do
      expect_offense(<<~RUBY, var: var)
        %{var} = 5
        %{var} unless condition
        ^{var} Variable `#{var}` used in void context.
        top
      RUBY

      # `var unless condition` might indicate missing `return` in `return var unless condition`,
      # so for convenience, the code will not be autocorrected by deletion.
      expect_no_corrections
    end
  end

  it 'registers an offense for void constant `CONST` if not on last line' do
    expect_offense(<<~RUBY)
      CONST = 5
      CONST
      ^^^^^ Constant `CONST` used in void context.
      top
    RUBY

    expect_correction(<<~RUBY)
      CONST = 5
      top
    RUBY
  end

  it 'registers an offense for void constant `CONST` with guard condition if not on last line' do
    expect_offense(<<~RUBY)
      CONST = 5
      CONST unless condition
      ^^^^^ Constant `CONST` used in void context.
      top
    RUBY

    # `CONST unless condition` might indicate missing `return` in `return CONST unless condition`,
    # so for convenience, the code will not be autocorrected by deletion.
    expect_no_corrections
  end

  %w(1 2.0 :test /test/ [1] {}).each do |lit|
    it "registers an offense for void lit #{lit} if not on last line" do
      expect_offense(<<~RUBY, lit: lit)
        %{lit}
        ^{lit} Literal `#{lit}` used in void context.
        top
      RUBY

      expect_correction(<<~RUBY)
        #{''}
        top
      RUBY
    end

    it "registers an offense for void lit #{lit} with guard condition if not on last line" do
      expect_offense(<<~RUBY, lit: lit)
        %{lit} unless condition
        ^{lit} Literal `#{lit}` used in void context.
        top
      RUBY

      # `42 unless condition` might indicate missing `return` in `return 42 unless condition`,
      # so for convenience, the code will not be autocorrected by deletion.
      expect_no_corrections
    end
  end

  it 'registers an offense for void `self` if not on last line' do
    expect_offense(<<~RUBY)
      self; top
      ^^^^ `self` used in void context.
    RUBY

    expect_correction(<<~RUBY)
      ; top
    RUBY
  end

  it 'registers an offense for void `defined?` if not on last line' do
    expect_offense(<<~RUBY)
      defined?(x)
      ^^^^^^^^^^^ `defined?(x)` used in void context.
      top
    RUBY

    expect_correction(<<~RUBY)

      top
    RUBY
  end

  it 'registers an offense for void `-> { bar }` if not on last line' do
    expect_offense(<<~RUBY)
      def foo
        -> { bar }
        ^^^^^^^^^^ `-> { bar }` used in void context.
        top
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        top
      end
    RUBY
  end

  it 'does not register an offense for void `-> { bar }` if on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        top
        -> { bar }
      end
    RUBY
  end

  it 'does not register an offense for void `-> { bar }.call` if not on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        -> { bar }.call
        top
      end
    RUBY
  end

  it 'registers an offense for void `lambda { bar }` if not on last line' do
    expect_offense(<<~RUBY)
      def foo
        lambda { bar }
        ^^^^^^^^^^^^^^ `lambda { bar }` used in void context.
        top
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        top
      end
    RUBY
  end

  it 'does not register an offense for void `lambda { bar }` if on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        top
        lambda { bar }
      end
    RUBY
  end

  it 'does not register an offense for void `lambda { bar }.call` if not on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        lambda { bar }.call
        top
      end
    RUBY
  end

  it 'registers an offense for void `proc { bar }` if not on last line' do
    expect_offense(<<~RUBY)
      def foo
        proc { bar }
        ^^^^^^^^^^^^ `proc { bar }` used in void context.
        top
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        top
      end
    RUBY
  end

  it 'does not register an offense for void `proc { bar }` if on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        top
        proc { bar }
      end
    RUBY
  end

  it 'does not register an offense for void `proc { bar }.call` if not on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        proc { bar }.call
        top
      end
    RUBY
  end

  it 'registers an offense for void `Proc.new { bar }` if not on last line' do
    expect_offense(<<~RUBY)
      def foo
        Proc.new { bar }
        ^^^^^^^^^^^^^^^^ `Proc.new { bar }` used in void context.
        top
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        top
      end
    RUBY
  end

  it 'does not register an offense for void `Proc.new { bar }` if on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        top
        Proc.new { bar }
      end
    RUBY
  end

  it 'does not register an offense for void `Proc.new { bar }.call` if not on last line' do
    expect_no_offenses(<<~RUBY)
      def foo
        Proc.new { bar }.call
        top
      end
    RUBY
  end

  context 'when checking for methods with no side effects' do
    let(:config) do
      RuboCop::Config.new('Lint/Void' => { 'CheckForMethodsWithNoSideEffects' => true })
    end

    it 'registers offense for nonmutating method that takes a block' do
      expect_offense(<<~RUBY)
        [1,2,3].collect do |n|
        ^^^^^^^^^^^^^^^^^^^^^^ Method `#collect` used in void context. Did you mean `#each`?
          n.to_s
        end
        "done"
      RUBY

      expect_correction(<<~RUBY)
        [1,2,3].each do |n|
          n.to_s
        end
        "done"
      RUBY
    end

    context 'Ruby 2.7', :ruby27 do
      it 'registers offense for nonmutating method that takes a numbered parameter block' do
        expect_offense(<<~RUBY)
          [1,2,3].map do
          ^^^^^^^^^^^^^^ Method `#map` used in void context. Did you mean `#each`?
            _1.to_s
          end
          "done"
        RUBY

        expect_correction(<<~RUBY)
          [1,2,3].each do
            _1.to_s
          end
          "done"
        RUBY
      end
    end

    it 'registers an offense if not on last line' do
      expect_offense(<<~RUBY)
        x.sort
        ^^^^^^ Method `#sort` used in void context. Did you mean `#sort!`?
        top(x)
      RUBY

      expect_correction(<<~RUBY)
        x.sort!
        top(x)
      RUBY
    end

    it 'registers an offense for chained methods' do
      expect_offense(<<~RUBY)
        x.sort.flatten
        ^^^^^^^^^^^^^^ Method `#flatten` used in void context. Did you mean `#flatten!`?
        top(x)
      RUBY

      expect_correction(<<~RUBY)
        x.sort.flatten!
        top(x)
      RUBY
    end

    it 'does not register an offense assigning variable' do
      expect_no_offenses(<<~RUBY)
        foo = bar
        baz
      RUBY
    end

    it 'does not register an offense when using a method definition' do
      expect_no_offenses(<<~RUBY)
        def merge
        end

        42
      RUBY
    end
  end

  context 'when not checking for methods with no side effects' do
    let(:config) do
      RuboCop::Config.new('Lint/Void' => { 'CheckForMethodsWithNoSideEffects' => false })
    end

    it 'does not register an offense for void nonmutating methods' do
      expect_no_offenses(<<~RUBY)
        x.sort
        top(x)
      RUBY
    end
  end

  it 'does not register an offense for an array literal that includes non-literal elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        [foo, bar]
        baz
      end
    RUBY
  end

  it 'does not register an offense for a nested array literal that includes non-literal elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        [1, 2, [foo, bar]]
        baz
      end
    RUBY
  end

  it 'registers an offense for an array literal composed entirely of literals in a method definition' do
    expect_offense(<<~RUBY)
      def something
        [1, 2]
        ^^^^^^ Literal `[1, 2]` used in void context.
        baz
      end
    RUBY
  end

  it 'registers an offense for a nested array literal composed entirely of literals in a method definition' do
    expect_offense(<<~RUBY)
      def something
        [1, 2, [3]]
        ^^^^^^^^^^^ Literal `[1, 2, [3]]` used in void context.
        baz
      end
    RUBY
  end

  it 'registers an offense for a frozen literal in a method definition' do
    expect_offense(<<~RUBY)
      def something
        'foo'.freeze
        ^^^^^^^^^^^^ Literal `'foo'.freeze` used in void context.
        baz
      end
    RUBY
  end

  it 'registers an offense for a literal frozen via safe navigation in a method definition' do
    expect_offense(<<~RUBY)
      def something
        'foo'&.freeze
        ^^^^^^^^^^^^^ Literal `'foo'&.freeze` used in void context.
        baz
      end
    RUBY
  end

  it 'does not register an offense for frozen non-literal in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        foo.freeze
        baz
      end
    RUBY
  end

  it 'registers an offense for a nested array literal composed of frozen and unfrozen literals in a method definition' do
    expect_offense(<<~RUBY)
      def something
        [1, ['foo'.freeze]]
        ^^^^^^^^^^^^^^^^^^^ Literal `[1, ['foo'.freeze]]` used in void context.
        baz
      end
    RUBY
  end

  it 'does not register an offense for a nested array literal that includes frozen non-literal value elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        [1, [foo.freeze]]
        baz
      end
    RUBY
  end

  it 'does not register an offense for a hash literal that includes non-literal value elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        {k1: foo, k2: bar}
        baz
      end
    RUBY
  end

  it 'does not register an offense for a nested hash literal that includes non-literal value elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        {k0: {k1: foo, k2: bar}}
        baz
      end
    RUBY
  end

  it 'does not register an offense for a hash literal that includes non-literal key elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        {foo => 1, bar => 2}
        baz
      end
    RUBY
  end

  it 'does not register an offense for a nested hash literal that includes non-literal key elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        {foo: 1, bar: {baz => 2}}
        baz
      end
    RUBY
  end

  it 'registers an offense for a hash literal composed entirely of literals in a method definition' do
    expect_offense(<<~RUBY)
      def something
        {k1: 1, k2: 2}
        ^^^^^^^^^^^^^^ Literal `{k1: 1, k2: 2}` used in void context.
        baz
      end
    RUBY

    expect_correction(<<~RUBY)
      def something
        baz
      end
    RUBY
  end

  it 'registers an offense for a nested hash literal composed entirely of literals in a method definition' do
    expect_offense(<<~RUBY)
      def something
        {x: {k1: 1, k2: 2}}
        ^^^^^^^^^^^^^^^^^^^ Literal `{x: {k1: 1, k2: 2}}` used in void context.
        baz
      end
    RUBY

    expect_correction(<<~RUBY)
      def something
        baz
      end
    RUBY
  end

  it 'does not register an offense for a hash literal that includes array literal key within non-literal elements in a method definition' do
    expect_no_offenses(<<~RUBY)
      def something
        {[foo, bar] => :foo}
        baz
      end
    RUBY
  end

  it 'registers an offense for a hash literal that includes array literal key within literal elements in a method definition' do
    expect_offense(<<~RUBY)
      def something
        {[1, 2] => :foo}
        ^^^^^^^^^^^^^^^^ Literal `{[1, 2] => :foo}` used in void context.
        baz
      end
    RUBY
  end

  it 'registers an offense for void literal in a method definition' do
    expect_offense(<<~RUBY)
      def something
        42
        ^^ Literal `42` used in void context.
        42
      end
    RUBY

    expect_correction(<<~RUBY)
      def something
        42
      end
    RUBY
  end

  it 'registers two offenses for void literals in an initialize method' do
    expect_offense(<<~RUBY)
      def initialize
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      def initialize
      end
    RUBY
  end

  it 'registers two offenses for void literals in a setter method' do
    expect_offense(<<~RUBY)
      def foo=(rhs)
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo=(rhs)
      end
    RUBY
  end

  it 'registers two offenses for void literals in a class setter method' do
    expect_offense(<<~RUBY)
      def self.foo=(rhs)
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      def self.foo=(rhs)
      end
    RUBY
  end

  it 'registers two offenses for void literals in a `#each` method' do
    expect_offense(<<~RUBY)
      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each do |_item|
      end
    RUBY
  end

  it 'registers an offenses for void constant in a `#each` method' do
    expect_offense(<<~RUBY)
      array.each do |_item|
        CONST
        ^^^^^ Constant `CONST` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each do |_item|
      end
    RUBY
  end

  it 'handles `#each` block with single expression' do
    expect_offense(<<~RUBY)
      array.each do |_item|
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      array.each do |_item|
      end
    RUBY
  end

  it 'does not register `#each` block with conditional expression' do
    expect_no_offenses(<<~RUBY)
      enumerator_as_filter.each do |item|
        # The `filter` method is used to filter for matches with `42`.
        # In this case, it's not void.
        item == 42
      end
    RUBY
  end

  it 'does not register `#each` block with conditional expressions that has multiple statements' do
    expect_no_offenses(<<~RUBY)
      enumerator_as_filter.each do |item|
        puts item

        # The `filter` method is used to filter for matches with `42`.
        # In this case, it's not void.
        item == 42
      end
    RUBY
  end

  context 'Ruby 2.7', :ruby27 do
    it 'registers two offenses for void literals in `#tap` method' do
      expect_offense(<<~RUBY)
        foo.tap do
          _1
          ^^ Variable `_1` used in void context.
          42
          ^^ Literal `42` used in void context.
        end
      RUBY

      expect_correction(<<~RUBY)
        foo.tap do
        end
      RUBY
    end
  end

  it 'registers two offenses for void literals in `#tap` method with a numbered block' do
    expect_offense(<<~RUBY)
      foo.tap do
        _1
        ^^ Variable `_1` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      foo.tap do
      end
    RUBY
  end

  it 'accepts empty block' do
    expect_no_offenses(<<~RUBY)
      array.each { |_item| }
    RUBY
  end

  it 'registers two offenses for void literals in `#tap` method' do
    expect_offense(<<~RUBY)
      foo.tap do |x|
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      foo.tap do |x|
      end
    RUBY
  end

  it 'registers two offenses for void literals in a `for`' do
    expect_offense(<<~RUBY)
      for _item in array do
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      for _item in array do
      end
    RUBY
  end

  it 'registers two offense for void literals in an `ensure`' do
    expect_offense(<<~RUBY)
      def foo
      ensure
        bar
        42
        ^^ Literal `42` used in void context.
        42
        ^^ Literal `42` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
      ensure
        bar
      end
    RUBY
  end

  it 'registers an offense when the body of `ensure` is a literal' do
    expect_offense(<<~RUBY)
      def foo
        bar
      ensure
        [1, 2, [3]]
        ^^^^^^^^^^^ Literal `[1, 2, [3]]` used in void context.
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        bar
      ensure
      end
    RUBY
  end

  it 'handles explicit begin blocks' do
    expect_offense(<<~RUBY)
      begin
       1
       ^ Literal `1` used in void context.
       2
      end
    RUBY

    expect_correction(<<~RUBY)
      begin
       2
      end
    RUBY
  end

  it 'accepts short call syntax' do
    expect_no_offenses(<<~RUBY)
      lambda.(a)
      top
    RUBY
  end

  it 'accepts backtick commands' do
    expect_no_offenses(<<~RUBY)
      `touch x`
      nil
    RUBY
  end

  it 'accepts percent-x commands' do
    expect_no_offenses(<<~RUBY)
      %x(touch x)
      nil
    RUBY
  end

  it 'accepts method with irange block' do
    expect_no_offenses(<<~RUBY)
      def foo
        1..100.times.each { puts 1 }
        do_something
      end
    RUBY
  end

  it 'accepts method with erange block' do
    expect_no_offenses(<<~RUBY)
      def foo
        1...100.times.each { puts 1 }
        do_something
      end
    RUBY
  end

  it 'registers offense when using special __ENCODING__' do
    expect_offense(<<~RUBY)
      def foo
        __ENCODING__
        ^^^^^^^^^^^^ Variable `__ENCODING__` used in void context.
        42
      end
    RUBY

    expect_correction(<<~RUBY)
      def foo
        42
      end
    RUBY
  end
end
