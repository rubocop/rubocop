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
        inspect_source(cop, "x = a + b #{operator} return x")
        expect(cop.offenses).to be_empty
      end

      {
        'if'                     => 'if %{conditional}; %{body}; end',
        'while'                  => 'while %{conditional}; %{body}; end',
        'until'                  => 'until %{conditional}; %{body}; end',
        'post-conditional while' => 'begin; %{body}; end while %{conditional}',
        'post-conditional until' => 'begin; %{body}; end until %{conditional}'
      }.each do |type, snippet_format|
        it "registers an offense for \"#{operator}\" in #{type} conditional" do
          elements = {
            conditional: "a #{operator} b",
            body:        'do_something'
          }
          source = format(snippet_format, elements)

          inspect_source(cop, source)
          expect(cop.offenses.size).to eq(1)
        end

        it "accepts \"#{operator}\" in #{type} body" do
          elements = {
            conditional: 'some_condition',
            body:        "do_something #{operator} return"
          }
          source = format(snippet_format, elements)

          inspect_source(cop, source)
          expect(cop.offenses).to be_empty
        end
      end
    end

    %w[&& ||].each do |operator|
      it "accepts #{operator} inside of conditional" do
        inspect_source(cop, "test if a #{operator} b")
        expect(cop.offenses).to be_empty
      end

      it "accepts #{operator} outside of conditional" do
        inspect_source(cop, "x = a #{operator} b")
        expect(cop.offenses).to be_empty
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
      inspect_source(cop, 'test if a or b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'registers an offense for "and"' do
      inspect_source(cop, 'test if a and b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'accepts ||' do
      inspect_source(cop, 'test if a || b')
      expect(cop.offenses).to be_empty
    end

    it 'accepts &&' do
      inspect_source(cop, 'test if a && b')
      expect(cop.offenses).to be_empty
    end

    it 'auto-corrects "and" with &&' do
      new_source = autocorrect_source(cop, 'true and false')
      expect(new_source).to eq('true && false')
    end

    it 'auto-corrects "or" with ||' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        x = 12345
        true or false
      END
      expect(new_source).to eq(<<-END.strip_indent)
        x = 12345
        true || false
      END
    end

    it 'auto-corrects "or" with || inside def' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        def z(a, b)
          return true if a or b
        end
      END
      expect(new_source).to eq(<<-END.strip_indent)
        def z(a, b)
          return true if a || b
        end
      END
    end

    it 'autocorrects "or" with an assignment on the left' do
      src = "x = y or teststring.include? 'b'"
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq("(x = y) || teststring.include?('b')")
    end

    it 'autocorrects "or" with an assignment on the right' do
      src = "teststring.include? 'b' or x = y"
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq("teststring.include?('b') || (x = y)")
    end

    it 'autocorrects "and" with an assignment and return on either side' do
      src = 'x = a + b and return x'
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq('(x = a + b) && (return x)')
    end

    it 'warns on short-circuit (and)' do
      inspect_source(cop, 'x = a + b and return x')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'also warns on non short-circuit (and)' do
      inspect_source(cop, 'x = a + b if a and b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'also warns on non short-circuit (and) (unless)' do
      inspect_source(cop, 'x = a + b unless a and b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `&&` instead of `and`.'])
    end

    it 'warns on short-circuit (or)' do
      inspect_source(cop, 'x = a + b or return x')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on non short-circuit (or)' do
      inspect_source(cop, 'x = a + b if a or b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on non short-circuit (or) (unless)' do
      inspect_source(cop, 'x = a + b unless a or b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on while (or)' do
      inspect_source(cop, 'x = a + b while a or b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'also warns on until (or)' do
      inspect_source(cop, 'x = a + b until a or b')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `||` instead of `or`.'])
    end

    it 'auto-corrects "or" with || in method calls' do
      new_source = autocorrect_source(cop, 'method a or b')
      expect(new_source).to eq('method(a) || b')
    end

    it 'auto-corrects "or" with || in method calls (2)' do
      new_source = autocorrect_source(cop, 'method a,b or b')
      expect(new_source).to eq('method(a,b) || b')
    end

    it 'auto-corrects "or" with || in method calls (3)' do
      new_source = autocorrect_source(cop, 'obj.method a or b')
      expect(new_source).to eq('obj.method(a) || b')
    end

    it 'auto-corrects "or" with || in method calls (4)' do
      new_source = autocorrect_source(cop, 'obj.method a,b or b')
      expect(new_source).to eq('obj.method(a,b) || b')
    end

    it 'auto-corrects "or" with || and doesn\'t add extra parentheses' do
      new_source = autocorrect_source(cop, 'method(a, b) or b')
      expect(new_source).to eq('method(a, b) || b')
    end

    it 'auto-corrects "or" with || and adds parentheses to expr' do
      new_source = autocorrect_source(cop, 'b or method a,b')
      expect(new_source).to eq('b || method(a,b)')
    end

    it 'auto-corrects "and" with && in method calls' do
      new_source = autocorrect_source(cop, 'method a and b')
      expect(new_source).to eq('method(a) && b')
    end

    it 'auto-corrects "and" with && in method calls (2)' do
      new_source = autocorrect_source(cop, 'method a,b and b')
      expect(new_source).to eq('method(a,b) && b')
    end

    it 'auto-corrects "and" with && in method calls (3)' do
      new_source = autocorrect_source(cop, 'obj.method a and b')
      expect(new_source).to eq('obj.method(a) && b')
    end

    it 'auto-corrects "and" with && in method calls (4)' do
      new_source = autocorrect_source(cop, 'obj.method a,b and b')
      expect(new_source).to eq('obj.method(a,b) && b')
    end

    it 'auto-corrects "and" with && and doesn\'t add extra parentheses' do
      new_source = autocorrect_source(cop, 'method(a, b) and b')
      expect(new_source).to eq('method(a, b) && b')
    end

    it 'auto-corrects "and" with && and adds parentheses to expr' do
      new_source = autocorrect_source(cop, 'b and method a,b')
      expect(new_source).to eq('b && method(a,b)')
    end

    context 'with !obj.method arg on right' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, 'x and !obj.method arg')
        expect(new_source).to eq('x && !obj.method(arg)')
      end
    end

    context 'with !obj.method arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, '!obj.method arg and x')
        expect(new_source).to eq('!obj.method(arg) && x')
      end
    end

    context 'with obj.method = arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, 'obj.method = arg and x')
        expect(new_source).to eq('(obj.method = arg) && x')
      end
    end

    context 'with obj.method= arg on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, 'obj.method= arg and x')
        expect(new_source).to eq('(obj.method= arg) && x')
      end
    end

    context 'with predicate method with arg without space on right' do
      it 'autocorrects "or" with || and adds parens' do
        new_source = autocorrect_source(cop, 'false or 3.is_a?Integer')
        expect(new_source).to eq('false || 3.is_a?(Integer)')
      end

      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, 'false and 3.is_a?Integer')
        expect(new_source).to eq('false && 3.is_a?(Integer)')
      end
    end

    context 'with two predicate methods with args without spaces on right' do
      it 'autocorrects "or" with || and adds parens' do
        new_source = autocorrect_source(cop, "'1'.is_a?Integer " \
                                             'or 1.is_a?Integer')
        expect(new_source).to eq('\'1\'.is_a?(Integer) || 1.is_a?(Integer)')
      end

      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, "'1'.is_a?Integer and" \
                                             ' 1.is_a?Integer')
        expect(new_source).to eq('\'1\'.is_a?(Integer) && 1.is_a?(Integer)')
      end
    end

    context 'with one predicate method without space on right and another ' \
            'method' do
      it 'autocorrects "or" with || and adds parens' do
        new_source = autocorrect_source(cop, "'1'.is_a?Integer or" \
                                             ' 1.is_a? Integer')
        expect(new_source).to eq("'1'.is_a?(Integer) || 1.is_a?(Integer)")
      end

      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, "'1'.is_a?Integer " \
                                              'and 1.is_a? Integer')
        expect(new_source).to eq('\'1\'.is_a?(Integer) && 1.is_a?(Integer)')
      end
    end

    context 'with `not` expression on right' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, 'x and not arg')
        expect(new_source).to eq('x && (not arg)')
      end
    end

    context 'with `not` expression on left' do
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, 'not arg and x')
        expect(new_source).to eq('(not arg) && x')
      end
    end

    context 'with !variable on left' do
      it "doesn't crash and burn" do
        # regression test; see GH issue 2482
        inspect_source(cop, '!var or var.empty?')
        expect(cop.offenses.size).to eq(1)
      end
    end

    context 'within a nested begin node' do
      # regression test; see GH issue 2531
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          def x
          end

          def y
            a = b and a.c
          end
        END
        expect(new_source).to eq(<<-END.strip_indent)
          def x
          end

          def y
            (a = b) && a.c
          end
        END
      end
    end

    context 'within a nested begin node with one child only' do
      # regression test; see GH issue 2531
      it 'autocorrects "and" with && and adds parens' do
        new_source = autocorrect_source(cop, <<-END.strip_indent)
          (def y
            a = b and a.c
          end)
        END
        expect(new_source).to eq(<<-END.strip_indent)
          (def y
            (a = b) && a.c
          end)
        END
      end
    end

    context 'with a file which contains __FILE__' do
      let(:source) do
        <<-END.strip_indent
          APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
          system('bundle check') or system!('bundle install')
        END
      end

      # regression test; see GH issue 2609
      it 'autocorrects "or" with ||' do
        new_source = autocorrect_source(cop, source)
        expect(new_source).to eq(
          <<-END.strip_indent
            APP_ROOT = Pathname.new File.expand_path('../../', __FILE__)
            system('bundle check') || system!('bundle install')
          END
        )
      end
    end
  end
end
