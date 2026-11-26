# frozen_string_literal: true

RSpec.describe RuboCop::Cop::VariableForce::Analysis do
  subject(:analysis) { processed_source.variable_analysis }

  let(:processed_source) do
    RuboCop::ProcessedSource.new(source, ruby_version, parser_engine: parser_engine)
  end

  let(:source) { <<~RUBY }
    top = 1

    def foo(arg)
      local = arg
      [1].each { |item| local + item }
    end
  RUBY

  it 'is built once for a source' do
    expect(processed_source.variable_analysis).to equal(analysis)
  end

  describe '#scopes' do
    it 'has the scopes of the source, inner scopes first' do
      expect(analysis.scopes.map { |scope| scope.node.type }).to eq(%i[block def begin])
    end

    it 'has the variables of each scope' do
      expect(analysis.scopes.map { |scope| scope.variables.keys })
        .to eq([%i[item], %i[arg local], %i[top]])
    end

    it 'has the references of each variable' do
      local = analysis.scopes[1].variables[:local]

      expect(local.references.size).to eq(1)
      expect(local).to be_captured_by_block
    end

    context 'when the source is empty' do
      let(:source) { '' }

      it 'has no scopes' do
        expect(analysis.scopes).to be_empty
      end
    end
  end

  describe '#variables' do
    it 'has the variables of all the scopes' do
      expect(analysis.variables.map(&:name)).to eq(%i[item arg local top])
    end
  end

  describe '#shadowings' do
    it 'has nothing when no variable hides an outer one' do
      expect(analysis.shadowings).to be_empty
    end

    context 'when a block argument has the name of an outer variable' do
      let(:source) { <<~RUBY }
        def foo
          item = 1
          [2].each { |item| item }
        end
      RUBY

      it 'pairs the inner variable with the outer one' do
        inner, outer = analysis.shadowings.first

        expect(analysis.shadowings.size).to eq(1)
        expect(inner.declaration_node.type).to eq(:arg)
        expect(outer.declaration_node.type).to eq(:lvasgn)
      end
    end

    context 'when a method argument has the name of a variable outside the method' do
      let(:source) { <<~RUBY }
        item = 1

        def foo(item)
          item
        end
      RUBY

      it 'has nothing, because the method cannot see the outer variable' do
        expect(analysis.shadowings).to be_empty
      end
    end
  end
end
