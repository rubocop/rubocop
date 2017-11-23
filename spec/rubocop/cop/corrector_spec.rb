# frozen_string_literal: true

describe RuboCop::Cop::Corrector do
  { replace: 'hello',
    remove: nil,
    insert_before: 'hi',
    insert_after: '!',
  }.each do |method, arg|
    describe "##{method}" do
      it 'requires ranges with the same source_buffer' do
        processed_source = parse_source('2 * 21')
        corrector = described_class.new(processed_source.buffer)
        other_source = parse_source('42')

        expect {
          corrector.send(method, other_source.ast.loc.expression, *arg)
        }.to raise_error(ArgumentError)

        # Sanity check that test works with same buffer:
        expect {
          corrector.send(method, processed_source.ast.loc.expression, *arg)
        }.not_to raise_error
      end
    end
  end

  describe '#rewrite' do
    it 'allows removal of a range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.remove(node.loc.operator)
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true  false'
    end

    it 'allows insertion before a source range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.insert_before(node.loc.operator, ';nil ')
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true ;nil and false'
    end

    it 'allows insertion after a source range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.insert_after(node.loc.operator, ' nil;')
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true and nil; false'
    end

    it 'allows replacement of a range' do
      source = 'true and false'
      processed_source = parse_source(source)

      correction = lambda do |corrector|
        node = processed_source.ast
        corrector.replace(node.loc.operator, 'or')
      end

      corrector = described_class.new(processed_source.buffer, [correction])
      expect(corrector.rewrite).to eq 'true or false'
    end
  end
end
