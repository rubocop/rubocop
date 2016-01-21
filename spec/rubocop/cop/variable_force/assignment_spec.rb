# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::VariableForce::Assignment do
  include RuboCop::Sexp

  let(:ast) do
    RuboCop::ProcessedSource.new(source, ruby_version).ast
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

  let(:def_node) { ast.each_node.find(&:def_type?) }

  let(:lvasgn_node) { ast.each_node.find(&:lvasgn_type?) }

  let(:name) { lvasgn_node.children.first }
  let(:scope) { RuboCop::Cop::VariableForce::Scope.new(def_node) }
  let(:variable) do
    RuboCop::Cop::VariableForce::Variable.new(name, lvasgn_node, scope)
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
