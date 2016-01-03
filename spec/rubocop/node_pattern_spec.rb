# encoding: utf-8

require 'spec_helper'
require 'parser/current'

describe RuboCop::NodePattern do
  let(:root_node) do
    buffer = Parser::Source::Buffer.new('(string)', 1)
    buffer.source = ruby
    builder = Astrolabe::Builder.new
    Parser::CurrentRuby.new(builder).parse(buffer)
  end

  let(:node) { root_node }
  let(:params) { [] }

  shared_examples :matching do
    include AST::Sexp
    it 'matches' do
      expect(RuboCop::NodePattern.new(pattern).match(node, *params)).to be true
    end
  end

  shared_examples :nonmatching do
    it "doesn't match" do
      expect(RuboCop::NodePattern.new(pattern).match(node, *params)).to be_nil
    end
  end

  shared_examples :invalid do
    it 'is invalid' do
      expect { RuboCop::NodePattern.new(pattern) }
        .to raise_error(RuboCop::NodePattern::Invalid)
    end
  end

  shared_examples :single_capture do
    include AST::Sexp
    it 'yields captured value(s) and returns true if there is a block' do
      expect do |probe|
        compiled = RuboCop::NodePattern.new(pattern)
        retval = compiled.match(node, *params) do |capture|
          probe.to_proc.call(capture)
          :retval_from_block
        end
        expect(retval).to be :retval_from_block
      end.to yield_with_args(captured_val)
    end

    it 'returns captured values if there is no block' do
      retval = RuboCop::NodePattern.new(pattern).match(node, *params)
      expect(retval).to eq captured_val
    end
  end

  shared_examples :multiple_capture do
    include AST::Sexp
    it 'yields captured value(s) and returns true if there is a block' do
      expect do |probe|
        compiled = RuboCop::NodePattern.new(pattern)
        retval = compiled.match(node, *params) do |*captures|
          probe.to_proc.call(captures)
          :retval_from_block
        end
        expect(retval).to be :retval_from_block
      end.to yield_with_args(captured_vals)
    end

    it 'returns captured values if there is no block' do
      retval = RuboCop::NodePattern.new(pattern).match(node, *params)
      expect(retval).to eq captured_vals
    end
  end

  describe 'bare node type' do
    let(:pattern) { 'send' }

    context 'on a node with the same type' do
      let(:ruby) { 'obj.method' }
      it_behaves_like :matching
    end

    context 'on a node with a different type' do
      let(:ruby) { '@ivar' }
      it_behaves_like :nonmatching
    end
  end

  describe 'simple sequence' do
    let(:pattern) { '(send int :+ int)' }

    context 'on a node with the same type and matching children' do
      let(:ruby) { '1 + 1' }
      it_behaves_like :matching
    end

    context 'on a node with a different type' do
      let(:ruby) { 'a = 1' }
      it_behaves_like :nonmatching
    end

    context 'on a node with the same type and non-matching children' do
      context 'with non-matching selector' do
        let(:ruby) { '1 - 1' }
        it_behaves_like :nonmatching
      end

      context 'with non-matching receiver type' do
        let(:ruby) { '1.0 + 1' }
        it_behaves_like :nonmatching
      end
    end

    context 'on a node with too many children' do
      let(:pattern) { '(send int :blah int)' }
      let(:ruby) { '1.blah(1, 2)' }
      it_behaves_like :nonmatching
    end

    context 'with a nested sequence in head position' do
      let(:pattern) { '((send) int :blah)' }
      it_behaves_like :invalid
    end

    context 'with a nested sequence in non-head position' do
      let(:pattern) { '(send (send _ :a) :b)' }
      let(:ruby) { 'obj.a.b' }
      it_behaves_like :matching
    end
  end

  describe 'sequence with trailing ...' do
    let(:pattern) { '(send int :blah ...)' }

    context 'on a node with the same type and exact number of children' do
      let(:ruby) { '1.blah' }
      it_behaves_like :matching
    end

    context 'on a node with the same type and more children' do
      context 'with 1 child more' do
        let(:ruby) { '1.blah(1)' }
        it_behaves_like :matching
      end

      context 'with 2 children more' do
        let(:ruby) { '1.blah(1, :something)' }
        it_behaves_like :matching
      end
    end

    context 'on a node with the same type and fewer children' do
      let(:pattern) { '(send int :blah int int ...)' }
      let(:ruby) { '1.blah(2)' }
      it_behaves_like :nonmatching
    end

    context 'on a node with fewer children, with a wildcard preceding' do
      let(:pattern) { '(hash _ ...)' }
      let(:ruby) { '{}' }
      it_behaves_like :nonmatching
    end

    context 'on a node with a different type' do
      let(:ruby) { 'A = 1' }
      it_behaves_like :nonmatching
    end

    context 'on a node with non-matching children' do
      let(:ruby) { '1.foo' }
      it_behaves_like :nonmatching
    end
  end

  describe 'wildcards' do
    describe 'unnamed wildcards' do
      context 'at the root level' do
        let(:pattern) { '_' }
        let(:ruby) { 'class << self; def something; 1; end end.freeze' }
        it_behaves_like :matching
      end

      context 'within a sequence' do
        let(:pattern) { '(const _ _)' }
        let(:ruby) { 'Const' }
        it_behaves_like :matching
      end

      context 'within a sequence with other patterns intervening' do
        let(:pattern) { '(ivasgn _ (int _))' }
        let(:ruby) { '@abc = 22' }
        it_behaves_like :matching
      end

      context 'in head position of a sequence' do
        let(:pattern) { '(_ int ...)' }
        let(:ruby) { '1 + a' }
        it_behaves_like :matching
      end

      context 'negated' do
        let(:pattern) { '!_' }
        let(:ruby) { '123' }
        it_behaves_like :nonmatching
      end
    end

    describe 'named wildcards' do
      # unification is done on named wildcards!
      context 'at the root level' do
        let(:pattern) { '_node' }
        let(:ruby) { 'class << self; def something; 1; end end.freeze' }
        it_behaves_like :matching
      end

      context 'within a sequence' do
        context 'with values which can be unified' do
          let(:pattern) { '(send _num :+ _num)' }
          let(:ruby) { '5 + 5' }
          it_behaves_like :matching
        end

        context 'with values which cannot be unified' do
          let(:pattern) { '(send _num :+ _num)' }
          let(:ruby) { '5 + 4' }
          it_behaves_like :nonmatching
        end

        context 'unifying the node type with an argument' do
          let(:pattern) { '(_type _ _type)' }
          let(:ruby) { 'obj.send' }
          it_behaves_like :matching
        end
      end

      context 'within a sequence with other patterns intervening' do
        let(:pattern) { '(ivasgn _ivar (int _val))' }
        let(:ruby) { '@abc = 22' }
        it_behaves_like :matching
      end

      context 'in head position of a sequence' do
        let(:pattern) { '(_type int ...)' }
        let(:ruby) { '1 + a' }
        it_behaves_like :matching
      end
    end
  end

  describe 'sets' do
    context 'at the top level' do
      context 'containing symbol literals' do
        context 'when the AST has a matching symbol' do
          let(:pattern) { '(send _ {:a :b})' }
          let(:ruby) { 'obj.b' }
          it_behaves_like :matching
        end

        context 'when the AST does not have a matching symbol' do
          let(:pattern) { '(send _ {:a :b})' }
          let(:ruby) { 'obj.c' }
          it_behaves_like :nonmatching
        end
      end

      context 'containing integer literals' do
        let(:pattern) { '(send (int {1 10}) :abs)' }
        let(:ruby) { '10.abs' }
        it_behaves_like :matching
      end

      context 'containing multiple []' do
        let(:pattern) { '{[(int odd?) int] [!nil float]}' }

        context 'on a node which meets all requirements of the first []' do
          let(:ruby) { '3' }
          it_behaves_like :matching
        end

        context 'on a node which meets all requirements of the second []' do
          let(:ruby) { '2.2' }
          it_behaves_like :matching
        end

        context 'on a node which meets some requirements but not all' do
          let(:ruby) { '2' }
          it_behaves_like :nonmatching
        end
      end
    end

    context 'nested inside a sequence' do
      let(:pattern) { '(send {const int} ...)' }
      let(:ruby) { 'Const.method' }
      it_behaves_like :matching
    end

    context 'with a nested sequence' do
      let(:pattern) { '{(send int ...) (send const ...)}' }
      let(:ruby) { 'Const.method' }
      it_behaves_like :matching
    end
  end

  describe 'captures on a wildcard' do
    context 'at the root level' do
      let(:pattern) { '$_' }
      let(:ruby) { 'begin; raise StandardError; rescue Exception => e; end' }
      let(:captured_val) { node }
      it_behaves_like :single_capture
    end

    context 'in head position in a sequence' do
      let(:pattern) { '($_ ...)' }
      let(:ruby) { 'A.method' }
      let(:captured_val) { :send }
      it_behaves_like :single_capture
    end

    context 'in non-head position in a sequence' do
      let(:pattern) { '(send $_ ...)' }
      let(:ruby) { 'A.method' }
      let(:captured_val) { s(:const, nil, :A) }
      it_behaves_like :single_capture
    end

    context 'in a nested sequence' do
      let(:pattern) { '(send (const nil $_) ...)' }
      let(:ruby) { 'A.method' }
      let(:captured_val) { :A }
      it_behaves_like :single_capture
    end
  end

  describe 'captures which also perform a match' do
    context 'on a sequence' do
      let(:pattern) { '(send $(send _ :keys) :each)' }
      let(:ruby) { '{}.keys.each' }
      let(:captured_val) { s(:send, s(:hash), :keys) }
      it_behaves_like :single_capture
    end

    context 'on a set' do
      let(:pattern) { '(send _ ${:inc :dec})' }
      let(:ruby) { '1.dec' }
      let(:captured_val) { :dec }
      it_behaves_like :single_capture
    end

    context 'on []' do
      let(:pattern) { '(send (int $[!odd? !zero?]) :inc)' }
      let(:ruby) { '2.inc' }
      let(:captured_val) { 2 }
      it_behaves_like :single_capture
    end

    context 'on a node type' do
      let(:pattern) { '(send $int :inc)' }
      let(:ruby) { '5.inc' }
      let(:captured_val) { s(:int, 5) }
      it_behaves_like :single_capture
    end

    context 'on a literal' do
      let(:pattern) { '(send int $:inc)' }
      let(:ruby) { '5.inc' }
      let(:captured_val) { :inc }
      it_behaves_like :single_capture
    end

    context 'when nested' do
      let(:pattern) { '(send $(int $_) :inc)' }
      let(:ruby) { '5.inc' }
      let(:captured_vals) { [s(:int, 5), 5] }
      it_behaves_like :multiple_capture
    end
  end

  describe 'captures on ...' do
    context 'with no remaining pattern at the end' do
      let(:pattern) { '(send $...)' }
      let(:ruby) { '5.inc' }
      let(:captured_val) { [s(:int, 5), :inc] }
      it_behaves_like :single_capture
    end

    context 'with a remaining node type at the end' do
      let(:pattern) { '(send $... int)' }
      let(:ruby) { '5 + 4' }
      let(:captured_val) { [s(:int, 5), :+] }
      it_behaves_like :single_capture
    end

    context 'with a remaining sequence at the end' do
      let(:pattern) { '(send $... (int 4))' }
      let(:ruby) { '5 + 4' }
      let(:captured_val) { [s(:int, 5), :+] }
      it_behaves_like :single_capture
    end

    context 'with a remaining set at the end' do
      let(:pattern) { '(send $... {int float})' }
      let(:ruby) { '5 + 4' }
      let(:captured_val) { [s(:int, 5), :+] }
      it_behaves_like :single_capture
    end

    context 'with a remaining [] at the end' do
      let(:pattern) { '(send $... [(int even?) (int zero?)])' }
      let(:ruby) { '5 + 0' }
      let(:captured_val) { [s(:int, 5), :+] }
      it_behaves_like :single_capture
    end

    context 'with a remaining literal at the end' do
      let(:pattern) { '(send $... :inc)' }
      let(:ruby) { '5.inc' }
      let(:captured_val) { [s(:int, 5)] }
      it_behaves_like :single_capture
    end

    context 'with a remaining wildcard at the end' do
      let(:pattern) { '(send $... _)' }
      let(:ruby) { '5.inc' }
      let(:captured_val) { [s(:int, 5)] }
      it_behaves_like :single_capture
    end

    context 'with a remaining capture at the end' do
      let(:pattern) { '(send $... $_)' }
      let(:ruby) { '5 + 4' }
      let(:captured_vals) { [[s(:int, 5), :+], s(:int, 4)] }
      it_behaves_like :multiple_capture
    end

    context 'at the very beginning of a sequence' do
      let(:pattern) { '($... (int 1))' }
      let(:ruby) { '10 * 1' }
      let(:captured_val) { [s(:int, 10), :*] }
      it_behaves_like :single_capture
    end
  end

  describe 'captures within sets' do
    context 'on simple subpatterns' do
      let(:pattern) { '{$send $int $float}' }
      let(:ruby) { '2.0' }
      let(:captured_val) { s(:float, 2.0) }
      it_behaves_like :single_capture
    end

    context 'within nested sequences' do
      let(:pattern) { '{(send $_ $_) (const $_ $_)}' }
      let(:ruby) { 'Namespace::CONST' }
      let(:captured_vals) { [s(:const, nil, :Namespace), :CONST] }
      it_behaves_like :multiple_capture
    end

    context 'with complex nesting' do
      let(:pattern) do
        '{(send {$int $float} {$:inc $:dec}) ' \
        '[!nil {($_ sym $_) (send ($_ $_) :object_id)}]}'
      end
      let(:ruby) { '10.object_id' }
      let(:captured_vals) { [:int, 10] }
      it_behaves_like :multiple_capture
    end

    context 'with a different number of captures in each branch' do
      let(:pattern) { '{(send $...) (int $...) (send $_ $_)}' }
      it_behaves_like :invalid
    end
  end

  describe 'negation' do
    context 'on a symbol' do
      let(:pattern) { '(send _ !:abc)' }

      context 'with a matching symbol' do
        let(:ruby) { 'obj.abc' }
        it_behaves_like :nonmatching
      end

      context 'with a non-matching symbol' do
        let(:ruby) { 'obj.xyz' }
        it_behaves_like :matching
      end

      context 'with a non-matching symbol, but too many children' do
        let(:ruby) { 'obj.xyz(1)' }
        it_behaves_like :nonmatching
      end
    end

    context 'on a set' do
      let(:pattern) { '(ivasgn _ !(int {1 2}))' }

      context 'with a matching value' do
        let(:ruby) { '@a = 1' }
        it_behaves_like :nonmatching
      end

      context 'with a non-matching value' do
        let(:ruby) { '@a = 3' }
        it_behaves_like :matching
      end
    end

    context 'on a sequence' do
      let(:pattern) { '!(ivasgn :@a ...)' }

      context 'with a matching node' do
        let(:ruby) { '@a = 1' }
        it_behaves_like :nonmatching
      end

      context 'with a node of different type' do
        let(:ruby) { '@@a = 1' }
        it_behaves_like :matching
      end

      context 'with a node with non-matching children' do
        let(:ruby) { '@b = 1' }
        it_behaves_like :matching
      end
    end

    context 'on square brackets' do
      let(:pattern) { '![!int !float]' }

      context 'with a node which meets all requirements of []' do
        let(:ruby) { '"abc"' }
        it_behaves_like :nonmatching
      end

      context 'with a node which meets only 1 requirement of []' do
        let(:ruby) { '1' }
        it_behaves_like :matching
      end
    end

    context 'when nested in complex ways' do
      let(:pattern) { '!(send !{int float} !:+ !(send _ :to_i))' }

      context 'with (send str :+ (send str :to_i))' do
        let(:ruby) { '"abc" + "1".to_i' }
        it_behaves_like :matching
      end

      context 'with (send int :- int)' do
        let(:ruby) { '1 - 1' }
        it_behaves_like :matching
      end

      context 'with (send str :<< str)' do
        let(:ruby) { '"abc" << "xyz"' }
        it_behaves_like :nonmatching
      end
    end
  end

  describe 'ellipsis' do
    context 'preceding a capture' do
      let(:pattern) { '(send array :push ... $_)' }
      let(:ruby) { '[1].push(2, 3, 4)' }
      let(:captured_val) { s(:int, 4) }
      it_behaves_like :single_capture
    end

    context 'with a wildcard at the end, but no remaining child to match it' do
      let(:pattern) { '(send array :zip array ... _)' }
      let(:ruby) { '[1,2].zip([3,4])' }
      it_behaves_like :nonmatching
    end

    context 'with a nodetype at the end, but no remaining child to match it' do
      let(:pattern) { '(send array :zip array ... array)' }
      let(:ruby) { '[1,2].zip([3,4])' }
      it_behaves_like :nonmatching
    end

    context 'with a nested sequence at the end, but no remaining child' do
      let(:pattern) { '(send array :zip array ... (array ...))' }
      let(:ruby) { '[1,2].zip([3,4])' }
      it_behaves_like :nonmatching
    end

    context 'with a set at the end, but no remaining child to match it' do
      let(:pattern) { '(send array :zip array ... {array})' }
      let(:ruby) { '[1,2].zip([3,4])' }
      it_behaves_like :nonmatching
    end

    context 'with [] at the end, but no remaining child to match it' do
      let(:pattern) { '(send array :zip array ... [array !nil])' }
      let(:ruby) { '[1,2].zip([3,4])' }
      it_behaves_like :nonmatching
    end

    context 'at the very beginning of a sequence' do
      let(:pattern) { '(... (int 1))' }
      let(:ruby) { '10 * 1' }
      it_behaves_like :matching
    end
  end

  describe 'predicates' do
    context 'in root position' do
      let(:pattern) { 'send_type?' }
      let(:ruby) { '1.inc' }
      it_behaves_like :matching
    end

    context 'at head position of a sequence' do
      # called on the type symbol
      let(:pattern) { '(!nil? int ...)' }
      let(:ruby) { '1.inc' }
      it_behaves_like :matching
    end

    context 'applied to an integer for which the predicate is true' do
      let(:pattern) { '(send (int odd?) :inc)' }
      let(:ruby) { '1.inc' }
      it_behaves_like :matching
    end

    context 'applied to an integer for which the predicate is false' do
      let(:pattern) { '(send (int odd?) :inc)' }
      let(:ruby) { '2.inc' }
      it_behaves_like :nonmatching
    end

    context 'when captured' do
      let(:pattern) { '(send (int $odd?) :inc)' }
      let(:ruby) { '1.inc' }
      let(:captured_val) { 1 }
      it_behaves_like :single_capture
    end

    context 'when negated' do
      let(:pattern) { '(send int !nil?)' }
      let(:ruby) { '1.inc' }
      it_behaves_like :matching
    end

    context 'when in last-child position, but all children have already ' \
            'been matched' do
      let(:pattern) { '(send int :inc ... !nil?)' }
      let(:ruby) { '1.inc' }
      it_behaves_like :nonmatching
    end

    context 'with one extra argument' do
      let(:pattern) { '(send (int equal?(%1)) ...)' }
      let(:ruby) { '1 + 2' }

      context 'for which the predicate is true' do
        let(:params) { [1] }
        it_behaves_like :matching
      end

      context 'for which the predicate is false' do
        let(:params) { [2] }
        it_behaves_like :nonmatching
      end
    end
  end

  describe 'params' do
    context 'in root position' do
      let(:pattern) { '%1' }
      let(:params) { [s(:int, 10)] }
      let(:ruby) { '10' }
      it_behaves_like :matching
    end

    context 'in a nested sequence' do
      let(:pattern) { '(send (send _ %2) %1)' }
      let(:params) { [:inc, :dec] }
      let(:ruby) { '5.dec.inc' }
      it_behaves_like :matching
    end

    context 'when preceded by ...' do
      let(:pattern) { '(send ... %1)' }
      let(:params) { [s(:int, 10)] }
      let(:ruby) { '1 + 10' }
      it_behaves_like :matching
    end

    context 'when preceded by $...' do
      let(:pattern) { '(send $... %1)' }
      let(:params) { [s(:int, 10)] }
      let(:ruby) { '1 + 10' }
      let(:captured_val) { [s(:int, 1), :+] }
      it_behaves_like :single_capture
    end

    context 'when captured' do
      let(:pattern) { '(const _ $%1)' }
      let(:params) { [:A] }
      let(:ruby) { 'Namespace::A' }
      let(:captured_val) { :A }
      it_behaves_like :single_capture
    end

    context 'when negated, with a matching value' do
      let(:pattern) { '(const _ !%1)' }
      let(:params) { [:A] }
      let(:ruby) { 'Namespace::A' }
      it_behaves_like :nonmatching
    end

    context 'when negated, with a nonmatching value' do
      let(:pattern) { '(const _ !%1)' }
      let(:params) { [:A] }
      let(:ruby) { 'Namespace::B' }
      it_behaves_like :matching
    end

    context 'without explicit number' do
      let(:pattern) { '(const %2 %)' }
      let(:params) { [:A, s(:const, nil, :Namespace)] }
      let(:ruby) { 'Namespace::A' }
      it_behaves_like :matching
    end

    context 'when inside a union, with a matching value' do
      let(:pattern) { '{str (int %)}' }
      let(:params) { [10] }
      let(:ruby) { '10' }
      it_behaves_like :matching
    end

    context 'when inside a union, with a nonmatching value' do
      let(:pattern) { '{str (int %)}' }
      let(:params) { [10] }
      let(:ruby) { '1.0' }
      it_behaves_like :nonmatching
    end

    context 'when inside an intersection' do
      let(:pattern) { '(int [!%1 %2 !zero?])' }
      let(:params) { [10, 20] }
      let(:ruby) { '20' }
      it_behaves_like :matching
    end

    context 'param number zero' do
      # refers to original target node passed to #match
      let(:pattern) { '^(send %0 :+ (int 2))' }
      let(:ruby) { '1 + 2' }

      context 'in a position which matches original target node' do
        let(:node) { root_node.children[0] }
        it_behaves_like :matching
      end

      context 'in a position which does not match original target node' do
        let(:node) { root_node.children[2] }
        it_behaves_like :nonmatching
      end
    end
  end

  describe 'caret (ascend)' do
    context 'used with a node type' do
      let(:ruby) { '1.inc' }
      let(:node) { root_node.children[0] }

      context 'which matches' do
        let(:pattern) { '^send' }
        it_behaves_like :matching
      end

      context "which doesn't match" do
        let(:pattern) { '^const' }
        it_behaves_like :nonmatching
      end
    end

    context 'repeated twice' do
      # ascends to grandparent node
      let(:pattern) { '^^block' }
      let(:ruby) { '1.inc { something }' }
      let(:node) { root_node.children[0].children[0] }
      it_behaves_like :matching
    end

    context 'inside an intersection' do
      let(:pattern) { '^[!nil send ^(block ...)]' }
      let(:ruby) { '1.inc { something }' }
      let(:node) { root_node.children[0].children[0] }
      it_behaves_like :matching
    end

    context 'inside a union' do
      let(:pattern) { '{^send ^^send}' }
      let(:ruby) { '"str".concat(local += "abc")' }
      let(:node) { root_node.children[2].children[2] }
    end

    # NOTE!! a pitfall of doing this is that unification is done using #==
    # This means that 'identical' AST nodes, which are not really identical
    # because they have different metadata, will still unify
    context 'using unification to match self within parent' do
      let(:pattern) { '[_self ^(send _ _ _self)]' }
      let(:ruby) { '1 + 2' }

      context 'with self in the right position' do
        let(:node) { root_node.children[2] }
        it_behaves_like :matching
      end

      context 'with self in the wrong position' do
        let(:node) { root_node.children[0] }
        it_behaves_like :nonmatching
      end
    end
  end

  describe 'funcalls' do
    module RuboCop
      class NodePattern
        def goodmatch(_arg1)
          true
        end

        def badmatch(_arg1)
          false
        end

        def witharg(_arg1, arg2)
          arg2
        end

        def withargs(_arg1, _arg2, arg3)
          arg3
        end
      end
    end

    context 'without extra arguments' do
      let(:pattern) { '(lvasgn #goodmatch ...)' }
      let(:ruby) { 'a = 1' }
      it_behaves_like :matching
    end
  end

  describe 'commas' do
    # commas are just whitespace
    context 'with commas randomly strewn around' do
      let(:pattern) { ',,(,send,, ,int,:+, int ), ' }
      let(:ruby) { '1 + 2' }
      it_behaves_like :matching
    end
  end

  describe 'bad syntax' do
    context 'with empty parentheses' do
      let(:pattern) { '()' }
      it_behaves_like :invalid
    end

    context 'with unmatched opening paren' do
      let(:pattern) { '(send (const)' }
      it_behaves_like :invalid
    end

    context 'with unmatched closing paren' do
      let(:pattern) { '(send (const)))' }
      it_behaves_like :invalid
    end

    context 'with unmatched opening curly' do
      let(:pattern) { '{send const' }
      it_behaves_like :invalid
    end

    context 'with unmatched closing curly' do
      let(:pattern) { '{send const}}' }
      it_behaves_like :invalid
    end

    context 'with negated closing paren' do
      let(:pattern) { '(send (const) !)' }
      it_behaves_like :invalid
    end

    context 'with negated closing curly' do
      let(:pattern) { '{send const !}' }
      it_behaves_like :invalid
    end

    context 'with negated ellipsis' do
      let(:pattern) { '(send !...)' }
      it_behaves_like :invalid
    end

    context 'with doubled ellipsis' do
      let(:pattern) { '(send ... ...)' }
      it_behaves_like :invalid
    end
  end
end
