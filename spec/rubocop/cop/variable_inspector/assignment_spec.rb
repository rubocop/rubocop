# encoding: utf-8

require 'spec_helper'

describe Rubocop::Cop::VariableInspector::Assignment do
  include ASTHelper
  include AST::Sexp

  let(:ast) do
    processed_source = Rubocop::SourceParser.parse(source)
    processed_source.ast
  end

  let(:source) do
    <<-END
      class SomeClass
        def some_method(flag)
          puts 'Hello World!'

          if flag > 0
            foo = 1
          end
        end
      end
    END
  end

  let(:def_node) do
    found_node = scan_node(ast, include_origin_node: true) do |node|
      break node if node.type == :def
    end
    fail 'No def node found!' unless found_node
    found_node
  end

  let(:lvasgn_node) do
    found_node = scan_node(ast) do |node|
      break node if node.type == :lvasgn
    end
    fail 'No lvasgn node found!' unless found_node
    found_node
  end

  let(:name) { lvasgn_node.children.first }
  let(:scope) { Rubocop::Cop::VariableInspector::Scope.new(def_node) }
  let(:variable) do
    Rubocop::Cop::VariableInspector::Variable.new(name, lvasgn_node, scope)
  end
  let(:assignment) { described_class.new(lvasgn_node, variable) }

  describe '.new' do
    let(:variable) { double('variable') }

    context 'when an assignment node is passed' do
      it 'does not raise error' do
        node = s(:lvasgn, :foo)
        expect { described_class.new(node, variable) }.not_to raise_error
      end
    end

    context 'when an argument declaration node is passed' do
      it 'raises error' do
        node = s(:arg, :foo)
        expect { described_class.new(node, variable) }
          .to raise_error(ArgumentError)
      end
    end

    context 'when any other type node is passed' do
      it 'raises error' do
        node = s(:def)
        expect { described_class.new(node, variable) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#name' do
    it 'returns the variable name' do
      expect(assignment.name).to eq(:foo)
    end
  end

  describe '#meta_assignment_node' do
    context 'when it is += operator assignment' do
      let(:source) do
        <<-END
          def some_method
            foo += 1
          end
        END
      end

      it 'returns op_asgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:op_asgn)
      end
    end

    context 'when it is ||= operator assignment' do
      let(:source) do
        <<-END
          def some_method
            foo ||= 1
          end
        END
      end

      it 'returns or_asgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:or_asgn)
      end
    end

    context 'when it is &&= operator assignment' do
      let(:source) do
        <<-END
          def some_method
            foo &&= 1
          end
        END
      end

      it 'returns and_asgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:and_asgn)
      end
    end

    context 'when it is multiple assignment' do
      let(:source) do
        <<-END
          def some_method
            foo, bar = [1, 2]
          end
        END
      end

      it 'returns masgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:masgn)
      end
    end
  end

  describe '#operator' do
    context 'when it is normal assignment' do
      let(:source) do
        <<-END
          def some_method
            foo = 1
          end
        END
      end

      it 'returns =' do
        expect(assignment.operator).to eq('=')
      end
    end

    context 'when it is += operator assignment' do
      let(:source) do
        <<-END
          def some_method
            foo += 1
          end
        END
      end

      it 'returns +=' do
        expect(assignment.operator).to eq('+=')
      end
    end

    context 'when it is ||= operator assignment' do
      let(:source) do
        <<-END
          def some_method
            foo ||= 1
          end
        END
      end

      it 'returns ||=' do
        expect(assignment.operator).to eq('||=')
      end
    end

    context 'when it is &&= operator assignment' do
      let(:source) do
        <<-END
          def some_method
            foo &&= 1
          end
        END
      end

      it 'returns &&=' do
        expect(assignment.operator).to eq('&&=')
      end
    end

    context 'when it is multiple assignment' do
      let(:source) do
        <<-END
          def some_method
            foo, bar = [1, 2]
          end
        END
      end

      it 'returns =' do
        expect(assignment.operator).to eq('=')
      end
    end
  end
end
