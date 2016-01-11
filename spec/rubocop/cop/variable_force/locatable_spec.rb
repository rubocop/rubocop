# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::VariableForce::Locatable do
  include AST::Sexp

  class LocatableObject
    include RuboCop::Cop::VariableForce::Locatable

    attr_reader :node, :scope

    def initialize(node, scope)
      @node = node
      @scope = scope
    end
  end

  let(:ast) do
    RuboCop::ProcessedSource.new(source, ruby_version).ast
  end

  let(:def_node) { ast.each_node.find(&:def_type?) }
  let(:lvasgn_node) { ast.each_node.find(&:lvasgn_type?) }

  let(:scope) { RuboCop::Cop::VariableForce::Scope.new(def_node) }
  let(:assignment) { LocatableObject.new(lvasgn_node, scope) }

  context 'incomplete implementation' do
    class IncompleteLocatable
      include RuboCop::Cop::VariableForce::Locatable
    end

    it '#node raises an exception' do
      expect { IncompleteLocatable.new.node }
        .to raise_error(RuntimeError, '#node must be declared!')
    end

    it '#scope raises an exception' do
      expect { IncompleteLocatable.new.scope }
        .to raise_error(RuntimeError, '#scope must be declared!')
    end
  end

  describe '#branch_point_node' do
    context 'when it is not in branch' do
      let(:source) do
        <<-END
          def some_method(flag)
            foo = 1
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_point_node).to be_nil
      end
    end

    context 'when it is inside of if' do
      let(:source) do
        <<-END
          def some_method(flag)
            if flag
              foo = 1
            end
          end
        END
      end

      it 'returns the if node' do
        expect(assignment.branch_point_node.type).to eq(:if)
      end
    end

    context 'when it is inside of else of if' do
      let(:source) do
        <<-END
          def some_method(flag)
            if flag
            else
              foo = 1
            end
          end
        END
      end

      it 'returns the if node' do
        expect(assignment.branch_point_node.type).to eq(:if)
      end
    end

    context 'when it is inside of if condition' do
      let(:source) do
        <<-END
          def some_method(flag)
            if foo = 1
              do_something
            end
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_point_node).to be_nil
      end
    end

    context 'when multiple if are nested' do
      context 'and it is inside of inner if' do
        let(:source) do
          <<-END
            def some_method(a, b)
              if a
                if b
                  foo = 1
                end
              end
            end
          END
        end

        it 'returns inner if node' do
          if_node = assignment.branch_point_node
          expect(if_node.type).to eq(:if)
          condition_node = if_node.children.first
          expect(condition_node).to eq(s(:lvar, :b))
        end
      end

      context 'and it is inside of inner if condition' do
        let(:source) do
          <<-END
            def some_method(a, b)
              if a
                if foo = 1
                  do_something
                end
              end
            end
          END
        end

        it 'returns the next outer if node' do
          if_node = assignment.branch_point_node
          expect(if_node.type).to eq(:if)
          condition_node = if_node.children.first
          expect(condition_node).to eq(s(:lvar, :a))
        end
      end
    end

    context 'when it is inside of when of case' do
      let(:source) do
        <<-END
          def some_method(flag)
            case flag
            when 1
              foo = 1
            end
          end
        END
      end

      it 'returns the case node' do
        expect(assignment.branch_point_node.type).to eq(:case)
      end
    end

    context 'when it is on the left side of &&' do
      let(:source) do
        <<-END
          def some_method
            (foo = 1) && do_something
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_point_node).to be_nil
      end
    end

    context 'when it is on the right side of &&' do
      let(:source) do
        <<-END
          def some_method
            do_something && (foo = 1)
          end
        END
      end

      it 'returns the and node' do
        expect(assignment.branch_point_node.type).to eq(:and)
      end
    end

    context 'when it is on the left side of ||' do
      let(:source) do
        <<-END
          def some_method
            (foo = 1) || do_something
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_point_node).to be_nil
      end
    end

    context 'when it is on the right side of ||' do
      let(:source) do
        <<-END
          def some_method
            do_something || (foo = 1)
          end
        END
      end

      it 'returns the or node' do
        expect(assignment.branch_point_node.type).to eq(:or)
      end
    end

    context 'when multiple && are chained' do
      context 'and it is on the right side of the right &&' do
        let(:source) do
          <<-END
            def some_method
              do_something && do_anything && (foo = 1)
            end
          END
        end

        it 'returns the right and node' do
          and_node = assignment.branch_point_node
          expect(and_node.type).to eq(:and)
          right_side_node = and_node.children[1]
          expect(right_side_node.type).to eq(:begin)
        end
      end

      context 'and it is on the right side of the left &&' do
        let(:source) do
          <<-END
            def some_method
              do_something && (foo = 1) && do_anything
            end
          END
        end

        it 'returns the left and node' do
          and_node = assignment.branch_point_node
          expect(and_node.type).to eq(:and)
          right_side_node = and_node.children[1]
          expect(right_side_node.type).to eq(:begin)
        end
      end
    end

    context 'when it is inside of begin with rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            rescue
              do_something
            end
          end
        END
      end

      it 'returns the rescue node' do
        expect(assignment.branch_point_node.type).to eq(:rescue)
      end
    end

    context 'when it is inside of rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              do_something
            rescue
              foo = 1
            end
          end
        END
      end

      it 'returns the rescue node' do
        expect(assignment.branch_point_node.type).to eq(:rescue)
      end
    end

    context 'when it is inside of begin with ensure' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            ensure
              do_something
            end
          end
        END
      end

      it 'returns the ensure node' do
        expect(assignment.branch_point_node.type).to eq(:ensure)
      end
    end

    context 'when it is inside of ensure' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              do_something
            ensure
              foo = 1
            end
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_point_node).to be_nil
      end
    end

    context 'when it is inside of begin without rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            end
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_point_node).to be_nil
      end
    end
  end

  describe '#branch_body_node' do
    context 'when it is not in branch' do
      let(:source) do
        <<-END
          def some_method(flag)
            foo = 1
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_body_node).to be_nil
      end
    end

    context 'when it is inside body of if' do
      let(:source) do
        <<-END
          def some_method(flag)
            if flag
              foo = 1
              puts foo
            end
          end
        END
      end

      it 'returns the body node' do
        expect(assignment.branch_body_node.type).to eq(:begin)
      end
    end

    context 'when it is inside body of else of if' do
      let(:source) do
        <<-END
          def some_method(flag)
            if flag
              do_something
            else
              foo = 1
              puts foo
            end
          end
        END
      end

      it 'returns the body node' do
        expect(assignment.branch_body_node.type).to eq(:begin)
      end
    end

    context 'when it is on the right side of &&' do
      let(:source) do
        <<-END
          def some_method
            do_something && (foo = 1)
          end
        END
      end

      it 'returns the right side node' do
        expect(assignment.branch_body_node.type).to eq(:begin)
      end
    end

    context 'when it is on the right side of ||' do
      let(:source) do
        <<-END
          def some_method
            do_something || (foo = 1)
          end
        END
      end

      it 'returns the right side node' do
        expect(assignment.branch_body_node.type).to eq(:begin)
      end
    end

    context 'when it is inside of begin with rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            rescue
              do_something
            end
          end
        END
      end

      it 'returns the body node' do
        expect(assignment.branch_body_node.type).to eq(:lvasgn)
      end
    end

    context 'when it is inside of rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              do_something
            rescue
              foo = 1
            end
          end
        END
      end

      it 'returns the resbody node' do
        expect(assignment.branch_body_node.type).to eq(:resbody)
      end
    end

    context 'when it is inside of begin with ensure' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            ensure
              do_something
            end
          end
        END
      end

      it 'returns the body node' do
        expect(assignment.branch_body_node.type).to eq(:lvasgn)
      end
    end
  end

  describe '#branch_id' do
    context 'when it is not in branch' do
      let(:source) do
        <<-END
          def some_method(flag)
            foo = 1
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_id).to be_nil
      end
    end

    context 'when it is inside body of if' do
      let(:source) do
        <<-END
          def some_method(flag)
            if flag
              foo = 1
              puts foo
            end
          end
        END
      end

      it 'returns BRANCHNODEID_if_true' do
        expect(assignment.branch_id).to match(/^\d+_if_true/)
      end
    end

    context 'when it is inside body of else of if' do
      let(:source) do
        <<-END
          def some_method(flag)
            if flag
              do_something
            else
              foo = 1
              puts foo
            end
          end
        END
      end

      it 'returns BRANCHNODEID_if_false' do
        expect(assignment.branch_id).to match(/^\d+_if_false/)
      end
    end

    context 'when it is inside body of when of case' do
      let(:source) do
        <<-END
          def some_method(flag)
            case flag
            when first
              do_something
            when second
              foo = 1
              puts foo
            else
              do_something
            end
          end
        END
      end

      it 'returns BRANCHNODEID_case_whenINDEX' do
        expect(assignment.branch_id).to match(/^\d+_case_when1/)
      end
    end

    context 'when it is inside body of when of case' do
      let(:source) do
        <<-END
          def some_method(flag)
            case flag
            when first
              do_something
            when second
              do_something
            else
              foo = 1
              puts foo
            end
          end
        END
      end

      it 'returns BRANCHNODEID_case_else' do
        expect(assignment.branch_id).to match(/^\d+_case_else/)
      end
    end

    context 'when it is on the left side of &&' do
      let(:source) do
        <<-END
          def some_method
            (foo = 1) && do_something
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_id).to be_nil
      end
    end

    context 'when it is on the right side of &&' do
      let(:source) do
        <<-END
          def some_method
            do_something && (foo = 1)
          end
        END
      end

      it 'returns BRANCHNODEID_and_right' do
        expect(assignment.branch_id).to match(/^\d+_and_right/)
      end
    end

    context 'when it is on the left side of ||' do
      let(:source) do
        <<-END
          def some_method
            (foo = 1) || do_something
          end
        END
      end

      it 'returns nil' do
        expect(assignment.branch_id).to be_nil
      end
    end

    context 'when it is on the right side of ||' do
      let(:source) do
        <<-END
          def some_method
            do_something || (foo = 1)
          end
        END
      end

      it 'returns BRANCHNODEID_or_right' do
        expect(assignment.branch_id).to match(/^\d+_or_right/)
      end
    end

    context 'when it is inside of begin with rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            rescue
              do_something
            end
          end
        END
      end

      it 'returns BRANCHNODEID_rescue_main' do
        expect(assignment.branch_id).to match(/^\d+_rescue_main/)
      end
    end

    context 'when it is inside of rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              do_something
            rescue FirstError
              do_something
            rescue SecondError
              foo = 1
            end
          end
        END
      end

      it 'returns BRANCHNODEID_rescue_rescueINDEX' do
        expect(assignment.branch_id).to match(/^\d+_rescue_rescue1/)
      end
    end

    context 'when it is inside of else of rescue' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              do_something
            rescue FirstError
              do_something
            rescue SecondError
              do_something
            else
              foo = 1
            end
          end
        END
      end

      it 'returns BRANCHNODEID_rescue_else' do
        expect(assignment.branch_id).to match(/^\d+_rescue_else/)
      end
    end

    context 'when it is inside of begin with ensure' do
      let(:source) do
        <<-END
          def some_method(flag)
            begin
              foo = 1
            ensure
              do_something
            end
          end
        END
      end

      it 'returns BRANCHNODEID_ensure_main' do
        expect(assignment.branch_id).to match(/^\d+_ensure_main/)
      end
    end
  end
end
