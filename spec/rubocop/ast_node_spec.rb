# encoding: utf-8

require 'spec_helper'

describe Astrolabe::Node do
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
    let(:node) { RuboCop::ProcessedSource.new(src).ast }

    before(:all) do
      module Astrolabe
        class Node
          # Let's make our predicate matchers read better
          def used?
            value_used?
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
end
