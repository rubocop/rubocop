# frozen_string_literal: true

RSpec.describe RuboCop::Cop::VariableForce::Assignment do
  include RuboCop::AST::Sexp

  let(:ast) { RuboCop::ProcessedSource.new(source, ruby_version, parser_engine: parser_engine).ast }

  let(:source) do
    <<~RUBY
      class SomeClass
        def some_method(flag)
          puts 'Hello World!'

          if flag > 0
            foo = 1
          end
        end
      end
    RUBY
  end

  let(:def_node) { ast.each_node.find(&:def_type?) }

  let(:lvasgn_node) { ast.each_node.find(&:lvasgn_type?) }

  let(:name) { lvasgn_node.children.first }
  let(:scope) { RuboCop::Cop::VariableForce::Scope.new(def_node) }
  let(:variable) { RuboCop::Cop::VariableForce::Variable.new(name, lvasgn_node, scope) }
  let(:assignment) { described_class.new(lvasgn_node, variable) }

  describe '.new' do
    let(:variable) { instance_double(RuboCop::Cop::VariableForce::Variable) }

    context 'when an assignment node is passed' do
      it 'does not raise error' do
        node = s(:lvasgn, :foo)
        expect { described_class.new(node, variable) }.not_to raise_error
      end
    end

    context 'when an argument declaration node is passed' do
      it 'raises error' do
        node = s(:arg, :foo)
        expect { described_class.new(node, variable) }.to raise_error(ArgumentError)
      end
    end

    context 'when any other type node is passed' do
      it 'raises error' do
        node = s(:def)
        expect { described_class.new(node, variable) }.to raise_error(ArgumentError)
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
        <<~RUBY
          def some_method
            foo += 1
          end
        RUBY
      end

      it 'returns op_asgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:op_asgn)
      end
    end

    context 'when it is ||= operator assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo ||= 1
          end
        RUBY
      end

      it 'returns or_asgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:or_asgn)
      end
    end

    context 'when it is &&= operator assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo &&= 1
          end
        RUBY
      end

      it 'returns and_asgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:and_asgn)
      end
    end

    context 'when it is multiple assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo, bar = [1, 2]
          end
        RUBY
      end

      it 'returns masgn node' do
        expect(assignment.meta_assignment_node.type).to eq(:masgn)
      end
    end

    context 'when it is rest assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            *foo = [1, 2]
          end
        RUBY
      end

      it 'returns splat node' do
        expect(assignment.meta_assignment_node.type).to eq(:splat)
      end
    end

    context 'when it is `for` assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            for item in items
            end
          end
        RUBY
      end

      it 'returns splat node' do
        expect(assignment.meta_assignment_node.type).to eq(:for)
      end
    end
  end

  describe '#operator' do
    context 'when it is normal assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo = 1
          end
        RUBY
      end

      it 'returns =' do
        expect(assignment.operator).to eq('=')
      end
    end

    context 'when it is += operator assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo += 1
          end
        RUBY
      end

      it 'returns +=' do
        expect(assignment.operator).to eq('+=')
      end
    end

    context 'when it is ||= operator assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo ||= 1
          end
        RUBY
      end

      it 'returns ||=' do
        expect(assignment.operator).to eq('||=')
      end
    end

    context 'when it is &&= operator assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo &&= 1
          end
        RUBY
      end

      it 'returns &&=' do
        expect(assignment.operator).to eq('&&=')
      end
    end

    context 'when it is multiple assignment' do
      let(:source) do
        <<~RUBY
          def some_method
            foo, bar = [1, 2]
          end
        RUBY
      end

      it 'returns =' do
        expect(assignment.operator).to eq('=')
      end
    end
  end
end
