# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SingleLineMethods, :config do
  let(:config) do
    RuboCop::Config.new('AllCops' => all_cops_config,
                        'Style/SingleLineMethods' => cop_config,
                        'Layout/IndentationWidth' => { 'Width' => 2 },
                        'Style/EndlessMethod' => { 'Enabled' => false })
  end
  let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

  it 'registers an offense for a single-line method' do
    expect_offense(<<~RUBY)
      def some_method; body end
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def link_to(name, url); {:name => name}; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      def @table.columns; super; end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<~RUBY)
      def some_method;#{trailing_whitespace}
        body#{trailing_whitespace}
      end
      def link_to(name, url);#{trailing_whitespace}
        {:name => name};#{trailing_whitespace}
      end
      def @table.columns;#{trailing_whitespace}
        super;#{trailing_whitespace}
      end
    RUBY
  end

  it 'registers an offense for a single-line method and method body is enclosed in parentheses' do
    expect_offense(<<~RUBY)
      def foo() (do_something) end
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<~RUBY)
      def foo()#{trailing_whitespace}
        (do_something)#{trailing_whitespace}
      end
    RUBY
  end

  context 'when AllowIfMethodIsEmpty is disabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => false } }

    it 'registers an offense for an empty method' do
      expect_offense(<<~RUBY)
        def no_op; end
        ^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def self.resource_class=(klass); end
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
        def @table.columns; end
        ^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
      RUBY

      expect_correction(<<~RUBY)
        def no_op;#{trailing_whitespace}
        end
        def self.resource_class=(klass);#{trailing_whitespace}
        end
        def @table.columns;#{trailing_whitespace}
        end
      RUBY
    end
  end

  context 'when AllowIfMethodIsEmpty is enabled' do
    let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

    it 'accepts a single-line empty method' do
      expect_no_offenses(<<~RUBY)
        def no_op; end
        def self.resource_class=(klass); end
        def @table.columns; end
      RUBY
    end
  end

  it 'accepts a multi-line method' do
    expect_no_offenses(<<~RUBY)
      def some_method
        body
      end
    RUBY
  end

  it 'does not crash on an method with a capitalized name' do
    expect_no_offenses(<<~RUBY)
      def NoSnakeCase
      end
    RUBY
  end

  it 'autocorrects def with semicolon after method name' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method; body end # Cmnt
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  # Cmnt
      |  def some_method;#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end#{trailing_whitespace}
    RUBY
  end

  it 'autocorrects defs with parentheses after method name' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def self.some_method() body end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def self.some_method()#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'autocorrects def with argument in parentheses' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method(arg) body end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method(arg)#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'autocorrects def with argument and no parentheses' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method arg; body end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method arg;#{trailing_whitespace}
      |    body#{trailing_whitespace}
      |  end
    RUBY
  end

  it 'autocorrects def with semicolon before end' do
    expect_offense(<<-RUBY.strip_margin('|'))
      |  def some_method; b1; b2; end
      |  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid single-line method definitions.
    RUBY

    expect_correction(<<-RUBY.strip_margin('|'))
      |  def some_method;#{trailing_whitespace}
      |    b1;#{trailing_whitespace}
      |    b2;#{trailing_whitespace}
      |  end
    RUBY
  end

  context 'endless methods', :ruby30 do
    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        def some_method() = x
      RUBY
    end
  end

  context 'when `Style/EndlessMethod` is enabled', :ruby30 do
    before { config['Style/EndlessMethod'] = { 'Enabled' => true }.merge(endless_method_config) }

    shared_examples 'convert to endless method' do
      it 'corrects to an endless method definition' do
        expect_correction(<<~RUBY.strip, source: 'def some_method; body end')
          def some_method() = body
        RUBY
      end

      it 'corrects to an endless class method definition' do
        expect_correction(<<~RUBY.strip, source: 'def self.some_method; body end')
          def self.some_method() = body
        RUBY
      end

      it 'retains comments' do
        source = 'def some_method; body end # comment'
        expect_correction(<<~RUBY.strip, source: source)
          def some_method() = body # comment
        RUBY
      end

      it 'handles arguments properly' do
        expect_correction(<<~RUBY.strip, source: 'def some_method(a, b, c) body end')
          def some_method(a, b, c) = body
        RUBY
      end

      it 'corrects to an endless method definition when method body is a literal' do
        expect_correction(<<~RUBY.strip, source: 'def some_method; 42 end')
          def some_method() = 42
        RUBY
      end

      it 'corrects to an endless method definition when single line method call with parentheses' do
        expect_correction(<<~RUBY.strip, source: 'def index() head(:ok) end')
          def index() = head(:ok)
        RUBY
      end

      it 'corrects to an endless method definition when single line method call without parentheses' do
        expect_correction(<<~RUBY.strip, source: 'def index() head :ok end')
          def index() = head(:ok)
        RUBY
      end

      it 'does not add parens if they are already present' do
        expect_correction(<<~RUBY.strip, source: 'def some_method() body end')
          def some_method() = body
        RUBY
      end

      RuboCop::AST::Node::COMPARISON_OPERATORS.each do |op|
        it "corrects to an endless class method definition when using #{op}" do
          expect_correction(<<~RUBY.strip, source: "def #{op}(other) self #{op} other end")
            def #{op}(other) = self #{op} other
          RUBY
        end
      end

      it 'does not to an endless class method definition when using `return`' do
        expect_correction(<<~RUBY.strip, source: 'def foo(argument) return bar(argument); end')
          def foo(argument)#{trailing_whitespace}
            return bar(argument);#{trailing_whitespace}
          end
        RUBY
      end

      it 'does not to an endless class method definition when using `break`' do
        expect_correction(<<~RUBY.strip, source: 'def foo(argument) break bar(argument); end')
          def foo(argument)#{trailing_whitespace}
            break bar(argument);#{trailing_whitespace}
          end
        RUBY
      end

      it 'does not to an endless class method definition when using `next`' do
        expect_correction(<<~RUBY.strip, source: 'def foo(argument) next bar(argument); end')
          def foo(argument)#{trailing_whitespace}
            next bar(argument);#{trailing_whitespace}
          end
        RUBY
      end

      # NOTE: Setter method cannot be defined in the endless method definition.
      it 'corrects to multiline method definition when defining setter method' do
        expect_correction(<<~RUBY.chop, source: 'def foo=(foo) @foo = foo end')
          def foo=(foo)#{trailing_whitespace}
            @foo = foo#{trailing_whitespace}
          end
        RUBY
      end

      it 'corrects to a normal method if the method body contains multiple statements' do
        expect_correction(<<~RUBY.strip, source: 'def some_method; foo; bar end')
          def some_method;#{trailing_whitespace}
            foo;#{trailing_whitespace}
            bar#{trailing_whitespace}
          end
        RUBY
      end

      context 'with AllowIfMethodIsEmpty: false' do
        let(:cop_config) { { 'AllowIfMethodIsEmpty' => false } }

        it 'does not turn a method with no body into an endless method' do
          expect_correction(<<~RUBY.strip, source: 'def some_method; end')
            def some_method;#{trailing_whitespace}
            end
          RUBY
        end
      end

      context 'with AllowIfMethodIsEmpty: true' do
        let(:cop_config) { { 'AllowIfMethodIsEmpty' => true } }

        it 'does not correct' do
          expect_no_offenses('def some_method; end')
        end
      end
    end

    context 'with `disallow` style' do
      let(:endless_method_config) { { 'EnforcedStyle' => 'disallow' } }

      it 'corrects to an normal method' do
        expect_correction(<<~RUBY.strip, source: 'def some_method; body end')
          def some_method;#{trailing_whitespace}
            body#{trailing_whitespace}
          end
        RUBY
      end
    end

    context 'with `allow_single_line` style' do
      let(:endless_method_config) { { 'EnforcedStyle' => 'allow_single_line' } }

      it_behaves_like 'convert to endless method'
    end

    context 'with `allow_always` style' do
      let(:endless_method_config) { { 'EnforcedStyle' => 'allow_always' } }

      it_behaves_like 'convert to endless method'
    end

    context 'prior to ruby 3.0', :ruby27 do
      let(:endless_method_config) { { 'EnforcedStyle' => 'allow_always' } }

      it 'corrects to a multiline method' do
        expect_correction(<<~RUBY.strip, source: 'def some_method; body end')
          def some_method;#{trailing_whitespace}
            body#{trailing_whitespace}
          end
        RUBY
      end
    end
  end

  context 'when `Style/EndlessMethod` is disabled', :ruby30 do
    before { config['Style/EndlessMethod'] = { 'Enabled' => false } }

    it 'corrects to an normal method' do
      expect_correction(<<~RUBY.strip, source: 'def some_method; body end')
        def some_method;#{trailing_whitespace}
          body#{trailing_whitespace}
        end
      RUBY
    end
  end
end
