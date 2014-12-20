# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::AndOr, :config do
  context 'when style is conditionals' do
    cop_config = {
      'EnforcedStyle' => 'conditionals'
    }

    subject(:cop) { described_class.new(config) }
    let(:cop_config) { cop_config }

    %w(and or).each do |operator|
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

    %w(&& ||).each do |operator|
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
      new_source = autocorrect_source(cop, ['x = 12345',
                                            'true or false'])
      expect(new_source).to eq(['x = 12345',
                                'true || false'].join("\n"))
    end

    it 'auto-corrects "or" with || inside def' do
      new_source = autocorrect_source(cop, ['def z(a, b)',
                                            '  return true if a or b',
                                            'end'])
      expect(new_source).to eq(['def z(a, b)',
                                '  return true if a || b',
                                'end'].join("\n"))
    end

    it 'leaves *or* as is if auto-correction changes the meaning' do
      src = "x = y or teststring.include? 'b'"
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
    end

    it 'leaves *and* as is if auto-correction changes the meaning' do
      src = 'x = a + b and return x'
      new_source = autocorrect_source(cop, src)
      expect(new_source).to eq(src)
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

    it 'auto-corrects "or" with || and doesn\'t add extra parenthesis' do
      new_source = autocorrect_source(cop, 'method(a, b) or b')
      expect(new_source).to eq('method(a, b) || b')
    end

    it 'auto-corrects "or" with || and add parenthesis on left expr' do
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

    it 'auto-corrects "and" with && and doesn\'t add extra parenthesis' do
      new_source = autocorrect_source(cop, 'method(a, b) and b')
      expect(new_source).to eq('method(a, b) && b')
    end

    it 'auto-corrects "and" with && and add parenthesis on left expr' do
      new_source = autocorrect_source(cop, 'b and method a,b')
      expect(new_source).to eq('b && method(a,b)')
    end
  end
end
