# frozen_string_literal: true

describe RuboCop::Cop::Style::AndOr, :config do
  context 'when style is conditionals' do
    cop_config = {
      'EnforcedStyle' => 'conditionals'
    }

    subject(:cop) { described_class.new(config) }

    let(:cop_config) { cop_config }

    %w[and or].each do |operator|
      it "accepts \"#{operator}\" outside of conditional" do
        inspect_source("x = a + b #{operator} return x")
        expect(cop.offenses.empty?).to be(true)
      end

      {
        'if'                     => 'if %<condition>s; %<body>s; end',
        'while'                  => 'while %<condition>s; %<body>s; end',
        'until'                  => 'until %<condition>s; %<body>s; end',
        'post-conditional while' => 'begin; %<body>s; end while %<condition>s',
        'post-conditional until' => 'begin; %<body>s; end until %<condition>s'
      }.each do |type, snippet_format|
        it "registers an offense for \"#{operator}\" in #{type} conditional" do
          elements = {
            condition: "a #{operator} b",
            body:      'do_something'
          }
          source = format(snippet_format, elements)

          inspect_source(source)
          expect(cop.offenses.size).to eq(1)
        end

        it "accepts \"#{operator}\" in #{type} body" do
          elements = {
            condition: 'some_condition',
            body:      "do_something #{operator} return"
          }
          source = format(snippet_format, elements)

          inspect_source(source)
          expect(cop.offenses.empty?).to be(true)
        end
      end
    end

    %w[&& ||].each do |operator|
      it "accepts #{operator} inside of conditional" do
        inspect_source("test if a #{operator} b")
        expect(cop.offenses.empty?).to be(true)
      end

      it "accepts #{operator} outside of conditional" do
        inspect_source("x = a #{operator} b")
        expect(cop.offenses.empty?).to be(true)
      end
    end
  end

  context 'when style is always' do
    cop_config = {
      'EnforcedStyle' => 'always'
    }

    subject(:cop) { described_class.new(config) }

    let(:cop_config) { cop_config }

    it 'registers an offense for "or"' do
      expect_offense(<<-RUBY.strip_indent)
        test if a or b
                  ^^ Use `||` instead of `or`.
      RUBY
    end

    it 'registers an offense for "and"' do
      expect_offense(<<-RUBY.strip_indent)
        test if a and b
                  ^^^ Use `&&` instead of `and`.
      RUBY
    end

    it 'accepts ||' do
      expect_no_offenses('test if a || b')
    end

    it 'accepts &&' do
      expect_no_offenses('test if a && b')
    end

    it 'auto-corrects "and" with &&' do
      new_source = autocorrect_source('true and false')
      expect(new_source).to eq('true && false')
    end

    it 'auto-corrects "or" with ||' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        x = 12345
        true or false
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        x = 12345
        true || false
      RUBY
    end

    it 'auto-corrects "or" with || inside def' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        def z(a, b)
          return true if a or b
        end
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        def z(a, b)
          return true if a || b
        end
      RUBY
    end

    it 'autocorrects "or" with an assignment on the left' do
      src = "x = y or teststring.include? 'b'"
      new_source = autocorrect_source(src)
      expect(new_source).to eq("(x = y) || teststring.include?('b')")
    end

    it 'autocorrects "or" with an assignment on the right' do
      src = "teststring.include? 'b' or x = y"
      new_source = autocorrect_source(src)
      expect(new_source).to eq("teststring.include?('b') || (x = y)")
    end

    it 'autocorrects "and" with an assignment and return on either side' do
      src = 'x = a + b and return x'
      new_source = autocorrect_source(src)
      expect(new_source).to eq('(x = a + b) && (return x)')
    end

    it 'autocorrects "and" with an Enumerable accessor on either side' do
      src = 'foo[:bar] and foo[:baz]'
      new_source = autocorrect_source(src)
      expect(new_source).to eq('foo[:bar] && foo[:baz]')
    end

    it 'warns on short-circuit (and)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b and return x
                  ^^^ Use `&&` instead of `and`.
      RUBY
    end

    it 'also warns on non short-circuit (and)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b if a and b
                       ^^^ Use `&&` instead of `and`.
      RUBY
    end

    it 'also warns on non short-circuit (and) (unless)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b unless a and b
                           ^^^ Use `&&` instead of `and`.
      RUBY
    end

    it 'warns on short-circuit (or)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b or return x
                  ^^ Use `||` instead of `or`.
      RUBY
    end

    it 'also warns on non short-circuit (or)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b if a or b
                       ^^ Use `||` instead of `or`.
      RUBY
    end

    it 'also warns on non short-circuit (or) (unless)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b unless a or b
                           ^^ Use `||` instead of `or`.
      RUBY
    end

    it 'also warns on while (or)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b while a or b
                          ^^ Use `||` instead of `or`.
      RUBY
    end

    it 'also warns on until (or)' do
      expect_offense(<<-RUBY.strip_indent)
        x = a + b until a or b
                          ^^ Use `||` instead of `or`.
      RUBY
    end

    it 'auto-corrects "or" with || in method calls' do
      new_source = autocorrect_source('method a or b')
      expect(new_source).to eq('method(a) || b')
    end

    it 'auto-corrects "or" with || in method calls (2)' do
      new_source = autocorrect_source('method a,b or b')
      expect(new_source).to eq('method(a,b) || b')
    end

    it 'auto-corrects "or" with || in method calls (3)' do
      new_source = autocorrect_source('obj.method a or b')
      expect(new_source).to eq('obj.method(a) || b')
    end

    it 'auto-corrects "or" with || in method calls (4)' do
      new_source = autocorrect_source('obj.method a,b or b')
      expect(new_source).to eq('obj.method(a,b) || b')
    end

    it 'auto-corrects "or" with || and doesn\'t add extra parentheses' do
      new_source = autocorrect_source('method(a, b) or b')
      expect(new_source).to eq('method(a, b) || b')
    end

    it 'auto-corrects "or" with || and adds parentheses to expr' do
      new_source = autocorrect_source('b or method a,b')
      expect(new_source).to eq('b || method(a,b)')
    end

    it 'auto-corrects "and" with && in method calls' do
      new_source = autocorrect_source('method a and b')
      expect(new_source).to eq('method(a) && b')
    end

    it 'auto-corrects "and" with && in method calls (2)' do
      new_source = autocorrect_source('method a,b and b')
      expect(new_source).to eq('method(a,b) && b')
    end

    it 'auto-corrects "and" with && in method calls (3)' do
      new_source = autocorrect_source('obj.method a and b')
      expect(new_source).to eq('obj.method(a) && b')
    end

    it 'auto-corrects "and" with && in method calls (4)' do
      new_source = autocorrect_source('obj.method a,b and b')
      expect(new_source).to eq('obj.method(a,b) && b')
    end

    it 'auto-corrects "and" with && and doesn\'t add extra parentheses' do
      new_source = autocorrect_source('method(a, b) and b')
      expect(new_source).to eq('method(a, b) && b')
    end

    it 'auto-corrects "and" with && and adds parentheses to expr' do
      new_source = autocorrect_source('b and method a,b')
      expect(new_source).to eq('b && method(a,b)')
    end

    context 'with !obj.method arg on right' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('x and !obj.method arg')
        expect(new_source).to eq('x && !obj.method(arg)')
      end
    end

    context 'with !obj.method arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('!obj.method arg and x')
        expect(new_source).to eq('!obj.method(arg) && x')
      end
    end

    context 'with obj.method = arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('obj.method = arg and x')
        expect(new_source).to eq('(obj.method = arg) && x')
      end
    end

    context 'with obj.method= arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('obj.method= arg and x')
        expect(new_source).to eq('(obj.method= arg) && x')
      end
    end

    context 'with predicate method with arg without space on right' do
      it 'autocorrects "or" with || and adds parens' do
        new_source = autocorrect_source('false or 3.is_a?Integer')
        expect(new_source).to eq('false || 3.is_a?(Integer)')
      end

      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('false and 3.is_a?Integer')
        expect(new_source).to eq('false && 3.is_a?(Integer)')
      end
    end

    context 'with two predicate methods with args without spaces on right' do
      it 'autocorrects "or" with || and adds parens' do
        new_source = autocorrect_source("'1'.is_a?Integer " \
                                             'or 1.is_a?Integer')
        expect(new_source).to eq('\'1\'.is_a?(Integer) || 1.is_a?(Integer)')
      end

      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source("'1'.is_a?Integer and" \
                                             ' 1.is_a?Integer')
        expect(new_source).to eq('\'1\'.is_a?(Integer) && 1.is_a?(Integer)')
      end
    end

    context 'with one predicate method without space on right and another ' \
            'method' do
      it 'autocorrects "or" with || and adds parens' do
        new_source = autocorrect_source("'1'.is_a?Integer or" \
                                             ' 1.is_a? Integer')
        expect(new_source).to eq("'1'.is_a?(Integer) || 1.is_a?(Integer)")
      end

      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source("'1'.is_a?Integer " \
                                              'and 1.is_a? Integer')
        expect(new_source).to eq('\'1\'.is_a?(Integer) && 1.is_a?(Integer)')
      end
    end

    context 'with `not` expression on right' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('x and not arg')
        expect(new_source).to eq('x && (not arg)')
      end
    end

    context 'with `not` expression on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source('not arg and x')
        expect(new_source).to eq('(not arg) && x')
      end
    end

    context 'with !variable on left' do
      it "doesn't crash and burn" do
        # regression test; see GH issue 2482
        expect_offense(<<-RUBY.strip_indent)
          !var or var.empty?
               ^^ Use `||` instead of `or`.
        RUBY
      end
    end

    context 'within a nested begin node' do
      # regression test; see GH issue 2531
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          def x
          end

          def y
            a = b and a.c
          end
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          def x
          end

          def y
            (a = b) && a.c
          end
        RUBY
      end
    end

    context 'when left hand side is a comparison method' do
      # Regression: https://github.com/bbatsov/rubocop/issues/4451
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          foo == bar and baz
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          (foo == bar) && baz
        RUBY
      end
    end

    context 'within a nested begin node with one child only' do
      # regression test; see GH issue 2531
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          (def y
            a = b and a.c
          end)
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          (def y
            (a = b) && a.c
          end)
        RUBY
      end
    end

    context 'with a file which contains __FILE__' do
      let(:source) do
        <<-RUBY.strip_indent
          APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
          system('bundle check') or system!('bundle install')
        RUBY
      end

      # regression test; see GH issue 2609
      it 'autocorrects "or" with ||' do
        new_source = autocorrect_source(source)
        expect(new_source).to eq(
          <<-RUBY.strip_indent
            APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
            system('bundle check') || system!('bundle install')
          RUBY
        )
      end
    end
  end
end
