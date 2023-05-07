# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SymbolProc, :config do
  it 'registers an offense for a block with parameterless method call on param' do
    expect_offense(<<~RUBY)
      coll.map { |e| e.upcase }
               ^^^^^^^^^^^^^^^^ Pass `&:upcase` as an argument to `map` instead of a block.
    RUBY

    expect_correction(<<~RUBY)
      coll.map(&:upcase)
    RUBY
  end

  it 'registers an offense for safe navigation operator' do
    expect_offense(<<~RUBY)
      coll&.map { |e| e.upcase }
                ^^^^^^^^^^^^^^^^ Pass `&:upcase` as an argument to `map` instead of a block.
    RUBY

    expect_correction(<<~RUBY)
      coll&.map(&:upcase)
    RUBY
  end

  it 'registers an offense for a block when method in body is unary -/+' do
    expect_offense(<<~RUBY)
      something.map { |x| -x }
                    ^^^^^^^^^^ Pass `&:-@` as an argument to `map` instead of a block.
    RUBY

    expect_correction(<<~RUBY)
      something.map(&:-@)
    RUBY
  end

  it 'accepts block with more than 1 arguments' do
    expect_no_offenses('something { |x, y| x.method }')
  end

  it 'accepts lambda with 1 argument' do
    expect_no_offenses('->(x) { x.method }')
  end

  it 'accepts proc with 1 argument' do
    expect_no_offenses('proc { |x| x.method }')
  end

  it 'accepts Proc.new with 1 argument' do
    expect_no_offenses('Proc.new { |x| x.method }')
  end

  it 'accepts ::Proc.new with 1 argument' do
    expect_no_offenses('::Proc.new { |x| x.method }')
  end

  context 'when AllowedMethods is enabled' do
    let(:cop_config) { { 'AllowedMethods' => %w[respond_to] } }

    it 'accepts ignored method' do
      expect_no_offenses('respond_to { |format| format.xml }')
    end
  end

  context 'when AllowedPatterns is enabled' do
    let(:cop_config) { { 'AllowedPatterns' => ['respond_'] } }

    it 'accepts ignored method' do
      expect_no_offenses('respond_to { |format| format.xml }')
    end
  end

  it 'accepts block with no arguments' do
    expect_no_offenses('something { x.method }')
  end

  it 'accepts empty block body' do
    expect_no_offenses('something { |x| }')
  end

  it 'accepts block with more than 1 expression in body' do
    expect_no_offenses('something { |x| x.method; something_else }')
  end

  it 'accepts block when method in body is not called on block arg' do
    expect_no_offenses('something { |x| y.method }')
  end

  it 'accepts block with a block argument' do
    expect_no_offenses('something { |&x| x.call }')
  end

  it 'accepts block with splat params' do
    expect_no_offenses('something { |*x| x.first }')
  end

  it 'accepts block with adding a comma after the sole argument' do
    expect_no_offenses('something { |x,| x.first }')
  end

  it 'accepts a block with an unused argument with an method call' do
    expect_no_offenses('something { |_x| y.call }')
  end

  it 'accepts a block with an unused argument with an lvar' do
    expect_no_offenses(<<~RUBY)
      y = Y.new
      something { |_x| y.call }
    RUBY
  end

  context 'when the method has arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        method(one, 2) { |x| x.test }
                       ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `method` instead of a block.
      RUBY

      expect_correction(<<~RUBY)
        method(one, 2, &:test)
      RUBY
    end
  end

  it 'autocorrects multiple aliases with symbols as proc' do
    expect_offense(<<~RUBY)
      coll.map { |s| s.upcase }.map { |s| s.downcase }
                                    ^^^^^^^^^^^^^^^^^^ Pass `&:downcase` as an argument to `map` instead of a block.
               ^^^^^^^^^^^^^^^^ Pass `&:upcase` as an argument to `map` instead of a block.
    RUBY

    expect_correction(<<~RUBY)
      coll.map(&:upcase).map(&:downcase)
    RUBY
  end

  it 'autocorrects correctly when there are no arguments in parentheses' do
    expect_offense(<<~RUBY)
      coll.map(   ) { |s| s.upcase }
                    ^^^^^^^^^^^^^^^^ Pass `&:upcase` as an argument to `map` instead of a block.
    RUBY

    expect_correction(<<~RUBY)
      coll.map(&:upcase)
    RUBY
  end

  it 'does not crash with a bare method call' do
    run = -> { expect_no_offenses('coll.map { |s| bare_method }') }
    expect(&run).not_to raise_error
  end

  %w[reject select].each do |method|
    it "registers an offense when receiver is an array literal and using `#{method}` with a block" do
      expect_offense(<<~RUBY, method: method)
        [1, 2, 3].%{method} {|item| item.foo }
                  _{method} ^^^^^^^^^^^^^^^^^^ Pass `&:foo` as an argument to `#{method}` instead of a block.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].#{method}(&:foo)
      RUBY
    end

    it "registers an offense when receiver is some value and using `#{method}` with a block" do
      expect_offense(<<~RUBY, method: method)
        [1, 2, 3].#{method} {|item| item.foo }
                  _{method} ^^^^^^^^^^^^^^^^^^ Pass `&:foo` as an argument to `#{method}` instead of a block.
      RUBY

      expect_correction(<<~RUBY)
        [1, 2, 3].#{method}(&:foo)
      RUBY
    end

    it "does not register an offense when receiver is a hash literal and using `#{method}` with a block" do
      expect_no_offenses(<<~RUBY, method: method)
        {foo: 42}.#{method} {|item| item.foo }
      RUBY
    end
  end

  %w[min max].each do |method|
    it "registers an offense when receiver is a hash literal and using `#{method}` with a block" do
      expect_offense(<<~RUBY, method: method)
        {foo: 42}.%{method} {|item| item.foo }
                  _{method} ^^^^^^^^^^^^^^^^^^ Pass `&:foo` as an argument to `#{method}` instead of a block.
      RUBY

      expect_correction(<<~RUBY)
        {foo: 42}.#{method}(&:foo)
      RUBY
    end

    it "does not register an offense when receiver is a array literal and using `#{method}` with a block" do
      expect_no_offenses(<<~RUBY, method: method)
        [1, 2, 3].#{method} {|item| item.foo }
      RUBY
    end
  end

  context 'when `AllowMethodsWithArguments: true`' do
    let(:cop_config) { { 'AllowMethodsWithArguments' => true } }

    context 'when method has arguments' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          do_something(one, two) { |x| x.test }
        RUBY
      end
    end

    context 'when `super` has arguments' do
      it 'does not register an offense' do
        expect_no_offenses(<<~RUBY)
          super(one, two) { |x| x.test }
        RUBY
      end
    end

    context 'when method has no arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          coll.map { |e| e.upcase }
                   ^^^^^^^^^^^^^^^^ Pass `&:upcase` as an argument to `map` instead of a block.
        RUBY
      end
    end
  end

  context 'when `AllowMethodsWithArguments: false`' do
    let(:cop_config) { { 'AllowMethodsWithArguments' => false } }

    context 'when method has arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          do_something(one, two) { |x| x.test }
                                 ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `do_something` instead of a block.
        RUBY

        expect_correction(<<~RUBY)
          do_something(one, two, &:test)
        RUBY
      end
    end

    context 'when `super` has arguments' do
      it 'registers an offense' do
        expect_offense(<<~RUBY)
          super(one, two) { |x| x.test }
                          ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `super` instead of a block.
        RUBY

        expect_correction(<<~RUBY)
          super(one, two, &:test)
        RUBY
      end
    end
  end

  context 'AllowComments: true' do
    let(:cop_config) { { 'AllowComments' => true } }

    it 'registers an offense for a block with parameterless method call on param' \
       'and not contains a comment' do
      expect_offense(<<~RUBY)
        # comment a
        something do |e|
                  ^^^^^^ Pass `&:upcase` as an argument to `something` instead of a block.
          e.upcase
        end # comment b
        # comment c
      RUBY

      expect_correction(<<~RUBY)
        # comment a
        something(&:upcase) # comment b
        # comment c
      RUBY
    end

    it 'accepts block with parameterless method call on param and contains a comment' do
      expect_no_offenses(<<~RUBY)
        something do |e| # comment
          e.upcase
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        something do |e|
          # comment
          e.upcase
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        something

        something do |e|
          # comment
          e.upcase
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        something do |e|
          e.upcase # comment
        end
      RUBY

      expect_no_offenses(<<~RUBY)
        something do |e|
          e.upcase
          # comment
        end
      RUBY
    end
  end

  context 'when `super` has no arguments' do
    it 'registers an offense' do
      expect_offense(<<~RUBY)
        super { |x| x.test }
              ^^^^^^^^^^^^^^ Pass `&:test` as an argument to `super` instead of a block.
      RUBY

      expect_correction(<<~RUBY)
        super(&:test)
      RUBY
    end
  end

  it 'autocorrects correctly when args have a trailing comma' do
    expect_offense(<<~RUBY)
      mail(
        to: 'foo',
        subject: 'bar',
      ) { |format| format.text }
        ^^^^^^^^^^^^^^^^^^^^^^^^ Pass `&:text` as an argument to `mail` instead of a block.
    RUBY

    expect_correction(<<~RUBY)
      mail(
        to: 'foo',
        subject: 'bar', &:text
      )
    RUBY
  end

  context 'numblocks', :ruby27 do
    %w[reject select].each do |method|
      it "registers an offense when receiver is an array literal and using `#{method}` with a numblock" do
        expect_offense(<<~RUBY, method: method)
          [1, 2, 3].%{method} { _1.foo }
                    _{method} ^^^^^^^^^^ Pass `&:foo` as an argument to `#{method}` instead of a block.
        RUBY

        expect_correction(<<~RUBY)
          [1, 2, 3].#{method}(&:foo)
        RUBY
      end

      it "registers an offense when receiver is some value and using `#{method}` with a numblock" do
        expect_offense(<<~RUBY, method: method)
          do_something.%{method} { _1.foo }
                       _{method} ^^^^^^^^^^ Pass `&:foo` as an argument to `#{method}` instead of a block.
        RUBY

        expect_correction(<<~RUBY)
          do_something.#{method}(&:foo)
        RUBY
      end

      it "does not register an offense when receiver is a hash literal and using `#{method}` with a numblock" do
        expect_no_offenses(<<~RUBY, method: method)
          {foo: 42}.#{method} { _1.foo }
        RUBY
      end
    end

    %w[min max].each do |method|
      it "registers an offense when receiver is an hash literal and using `#{method}` with a numblock" do
        expect_offense(<<~RUBY, method: method)
          {foo: 42}.%{method} { _1.foo }
                    _{method} ^^^^^^^^^^ Pass `&:foo` as an argument to `#{method}` instead of a block.
        RUBY

        expect_correction(<<~RUBY)
          {foo: 42}.#{method}(&:foo)
        RUBY
      end

      it "does not register an offense when receiver is a array literal and using `#{method}` with a numblock" do
        expect_no_offenses(<<~RUBY, method: method)
          [1, 2, 3].#{method} { _1.foo }
        RUBY
      end
    end

    it 'registers an offense for a block with a numbered parameter' do
      expect_offense(<<~RUBY)
        something { _1.foo }
                  ^^^^^^^^^^ Pass `&:foo` as an argument to `something` instead of a block.
      RUBY

      expect_correction(<<~RUBY)
        something(&:foo)
      RUBY
    end

    it 'accepts block with multiple numbered parameters' do
      expect_no_offenses('something { _1 + _2 }')
    end

    it 'accepts lambda with 1 numbered parameter' do
      expect_no_offenses('-> { _1.method }')
    end

    it 'accepts proc with 1 numbered parameter' do
      expect_no_offenses('proc { _1.method }')
    end

    it 'accepts block with only second numbered parameter' do
      expect_no_offenses('something { _2.first }')
    end

    it 'accepts Proc.new with 1 numbered parameter' do
      expect_no_offenses('Proc.new { _1.method }')
    end

    it 'accepts ::Proc.new with 1 numbered parameter' do
      expect_no_offenses('::Proc.new { _1.method }')
    end

    context 'AllowComments: true' do
      let(:cop_config) { { 'AllowComments' => true } }

      it 'accepts blocks containing comments' do
        expect_no_offenses(<<~RUBY)
          something do
            # comment
            _1.upcase
          end
        RUBY

        expect_no_offenses(<<~RUBY)
          something do
            _1.upcase # comment
          end
        RUBY

        expect_no_offenses(<<~RUBY)
          something

          something do
            # comment
            _1.upcase
          end
        RUBY
      end
    end
  end
end
