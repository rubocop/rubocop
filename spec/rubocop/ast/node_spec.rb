# frozen_string_literal: true

describe RuboCop::AST::Node do
  describe '#asgn_method_call?' do
    it 'does not match ==' do
      parsed = parse_source('Object.new == value')
      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match !=' do
      parsed = parse_source('Object.new != value')
      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match <=' do
      parsed = parse_source('Object.new <= value')
      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match >=' do
      parsed = parse_source('Object.new >= value')
      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'does not match ===' do
      parsed = parse_source('Object.new === value')
      expect(parsed.ast.asgn_method_call?).to be(false)
    end

    it 'matches =' do
      parsed = parse_source('Object.new = value')
      expect(parsed.ast.asgn_method_call?).to be(true)
    end
  end

  describe '#value_used?' do
    let(:node) { RuboCop::ProcessedSource.new(src, ruby_version).ast }

    before(:all) do
      module RuboCop
        module AST
          class Node
            # Let's make our predicate matchers read better
            def used?
              value_used?
            end
          end
        end
      end
    end

    context 'at the top level' do
      let(:src) { 'expr' }

      it 'is false' do
        expect(node).not_to be_used
      end
    end

    context 'within a method call node' do
      let(:src) { 'obj.method(arg1, arg2, arg3)' }

      it 'is always true' do
        expect(node.child_nodes).to all(be_used)
      end
    end

    context 'at the end of a block' do
      let(:src) { 'obj.method { blah; expr }' }

      it 'is always true' do
        expect(node.children.last).to be_used
      end
    end

    context 'within a class definition node' do
      let(:src) { 'class C < Super; def a; 1; end; self; end' }

      it 'is always true' do
        expect(node.child_nodes).to all(be_used)
      end
    end

    context 'within a module definition node' do
      let(:src) { 'module M; def method; end; 1; end' }

      it 'is always true' do
        expect(node.child_nodes).to all(be_used)
      end
    end

    context 'within a singleton class node' do
      let(:src) { 'class << obj; 1; 2; end' }

      it 'is always true' do
        expect(node.child_nodes).to all(be_used)
      end
    end

    context 'within an if...else..end node' do
      context 'nested in a method call' do
        let(:src) { 'obj.method(if a then b else c end)' }

        it 'is always true' do
          if_node = node.children[2]
          expect(if_node.child_nodes).to all(be_used)
        end
      end

      context 'at the top level' do
        let(:src) { 'if a then b else c end' }

        it 'is true only for the condition' do
          condition, true_branch, false_branch = *node
          expect(condition).to be_used
          expect(true_branch).not_to be_used
          expect(false_branch).not_to be_used
        end
      end
    end

    context 'within an array literal' do
      context 'assigned to an ivar' do
        let(:src) { '@var = [a, b, c]' }

        it 'is always true' do
          ary_node = node.children[1]
          expect(ary_node.child_nodes).to all(be_used)
        end
      end

      context 'at the top level' do
        let(:src) { '[a, b, c]' }

        it 'is always false' do
          expect(node.child_nodes.map(&:used?)).to all(be false)
        end
      end
    end

    context 'within a while node' do
      let(:src) { 'while a; b; end' }

      it 'is true only for the condition' do
        condition, body = *node
        expect(condition).to be_used
        expect(body).not_to be_used
      end
    end
  end

  describe '#recursive_basic_literal?' do
    let(:node) { RuboCop::ProcessedSource.new(src, ruby_version).ast }

    shared_examples :literal do |source|
      let(:src) { source }
      it "returns true for `#{source}`" do
        expect(node).to be_recursive_literal
      end
    end

    it_behaves_like :literal, '!true'
    it_behaves_like :literal, '"#{2}"'
    it_behaves_like :literal, '(1)'
    it_behaves_like :literal, '(false && true)'
    it_behaves_like :literal, '(false <=> true)'
    it_behaves_like :literal, '(false or true)'
    it_behaves_like :literal, '[1, 2, 3]'
    it_behaves_like :literal, '{ :a => 1, :b => 2 }'
    it_behaves_like :literal, '{ a: 1, b: 2 }'
    it_behaves_like :literal, '/./'
    it_behaves_like :literal, '%r{abx}ixo'
    it_behaves_like :literal, '1.0'
    it_behaves_like :literal, '1'
    it_behaves_like :literal, 'false'
    it_behaves_like :literal, 'nil'
    it_behaves_like :literal, "'str'"

    shared_examples :non_literal do |source|
      let(:src) { source }
      it "returns false for `#{source}`" do
        expect(node).not_to be_recursive_literal
      end
    end

    it_behaves_like :non_literal, '(x && false)'
    it_behaves_like :non_literal, '(x == false)'
    it_behaves_like :non_literal, '(x or false)'
    it_behaves_like :non_literal, '[some_method_call]'
    it_behaves_like :non_literal, '{ :sym => some_method_call }'
    it_behaves_like :non_literal, '{ some_method_call => :sym }'
    it_behaves_like :non_literal, '/.#{some_method_call}/'
    it_behaves_like :non_literal, '%r{abx#{foo}}ixo'
    it_behaves_like :non_literal, 'some_method_call'
    it_behaves_like :non_literal, 'some_method_call(x, y)'
  end

  describe '#pure?' do
    let(:node) { RuboCop::ProcessedSource.new(src, ruby_version).ast }

    context 'for a method call' do
      let(:src) { 'obj.method(arg1, arg2)' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for an integer literal' do
      let(:src) { '100' }

      it 'returns true' do
        expect(node).to be_pure
      end
    end

    context 'for an array literal' do
      context 'with only literal children' do
        let(:src) { '[1..100, false, :symbol, "string", 1.0]' }

        it 'returns true' do
          expect(node).to be_pure
        end
      end

      context 'which contains a method call' do
        let(:src) { '[1, 2, 3, 3 + 4]' }

        it 'returns false' do
          expect(node).not_to be_pure
        end
      end
    end

    context 'for a hash literal' do
      context 'with only literal children' do
        let(:src) { '{range: 1..100, bool: false, str: "string", float: 1.0}' }

        it 'returns true' do
          expect(node).to be_pure
        end
      end

      context 'which contains a method call' do
        let(:src) { '{a: 1, b: 2, c: Kernel.exit}' }

        it 'returns false' do
          expect(node).not_to be_pure
        end
      end
    end

    context 'for a nested if' do
      context 'where the innermost descendants are local vars and literals' do
        let(:src) do
          ['lvar1, lvar2 = method1, method2',
           'if $global',
           '  if @initialized',
           '    [lvar1, lvar2, true]',
           '  else',
           '    :symbol',
           '  end',
           'else',
           '  lvar1',
           'end'].join("\n")
        end

        it 'returns true' do
          if_node = node.children[1]
          expect(if_node.type).to be :if
          expect(if_node).to be_pure
        end
      end

      context 'where one branch contains a method call' do
        let(:src) { 'if $DEBUG then puts "hello" else nil end' }

        it 'returns false' do
          expect(node).not_to be_pure
        end
      end

      context 'where one branch contains an assignment statement' do
        let(:src) { 'if @a then 1 else $global = "str" end' }

        it 'returns false' do
          expect(node).not_to be_pure
        end
      end
    end

    context 'for an ivar assignment' do
      let(:src) { '@var = 1' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for a gvar assignment' do
      let(:src) { '$var = 1' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for a cvar assignment' do
      let(:src) { '@@var = 1' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for an lvar assignment' do
      let(:src) { 'var = 1' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for a class definition' do
      let(:src) { 'class C < Super; def method; end end' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for a module definition' do
      let(:src) { 'module M; def method; end end' }

      it 'returns false' do
        expect(node).not_to be_pure
      end
    end

    context 'for a regexp' do
      let(:opts) { '' }
      let(:body) { '' }
      let(:src) { "/#{body}/#{opts}" }

      context 'with interpolated segments' do
        let(:body) { '#{x}' }
        it 'returns false' do
          expect(node).not_to be_pure
        end
      end

      context 'with no interpolation' do
        let(:src) { URI::Parser.new.make_regexp.inspect }
        it 'returns true' do
          expect(node).to be_pure
        end
      end

      context 'with options' do
        let(:opts) { 'oix' }
        it 'returns true' do
          expect(node).to be_pure
        end
      end
    end
  end

  describe '#sibling_index' do
    let(:node) { RuboCop::ProcessedSource.new(src, ruby_version).ast }

    let(:src) do
      [
        'def foo; end',
        'def bar; end',
        'def baz; end'
      ].join("\n")
    end

    it 'returns its sibling index' do
      (0..2).each do |n|
        expect(node.children[n].sibling_index).to eq(n)
      end
    end
  end
end
