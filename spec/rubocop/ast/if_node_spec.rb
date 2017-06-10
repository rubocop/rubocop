# frozen_string_literal: true

describe RuboCop::AST::IfNode do
  let(:if_node) { parse_source(source).ast }

  describe '.new' do
    context 'with a regular if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node).to be_a(described_class) }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node).to be_a(described_class) }
    end

    context 'with a modifier statement' do
      let(:source) { ':foo if bar?' }

      it { expect(if_node).to be_a(described_class) }
    end
  end

  describe '#keyword' do
    context 'with an if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node.keyword).to eq('if') }
    end

    context 'with an unless statement' do
      let(:source) { 'unless foo?; :bar; end' }

      it { expect(if_node.keyword).to eq('unless') }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node.keyword).to eq('') }
    end
  end

  describe '#inverse_keyword?' do
    context 'with an if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node.inverse_keyword).to eq('unless') }
    end

    context 'with an unless statement' do
      let(:source) { 'unless foo?; :bar; end' }

      it { expect(if_node.inverse_keyword).to eq('if') }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node.inverse_keyword).to eq('') }
    end
  end

  describe '#if?' do
    context 'with an if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node.if?).to be_truthy }
    end

    context 'with an unless statement' do
      let(:source) { 'unless foo?; :bar; end' }

      it { expect(if_node.if?).to be_falsey }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node.if?).to be_falsey }
    end
  end

  describe '#unless?' do
    context 'with an if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node.unless?).to be_falsey }
    end

    context 'with an unless statement' do
      let(:source) { 'unless foo?; :bar; end' }

      it { expect(if_node.unless?).to be_truthy }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node.unless?).to be_falsey }
    end
  end

  describe '#ternary?' do
    context 'with an if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node.ternary?).to be_falsey }
    end

    context 'with an unless statement' do
      let(:source) { 'unless foo?; :bar; end' }

      it { expect(if_node.ternary?).to be_falsey }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node.ternary?).to be_truthy }
    end
  end

  describe '#elsif?' do
    context 'with an elsif statement' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'end'].join("\n")
      end

      let(:elsif_node) { if_node.else_branch }

      it { expect(elsif_node.elsif?).to be_truthy }
    end

    context 'with an if statement comtaining an elsif' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'end'].join("\n")
      end

      it { expect(if_node.elsif?).to be_falsey }
    end

    context 'without an elsif statement' do
      let(:source) do
        ['if foo?',
         '  1',
         'end'].join("\n")
      end

      it { expect(if_node.elsif?).to be_falsey }
    end
  end

  describe '#else?' do
    context 'with an elsif statement' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'end'].join("\n")
      end

      # Note: This is a legacy behavior.
      it { expect(if_node.else?).to be_truthy }
    end

    context 'without an else statement' do
      let(:source) do
        ['if foo?',
         '  1',
         'else',
         '  2',
         'end'].join("\n")
      end

      it { expect(if_node.elsif?).to be_falsey }
    end
  end

  describe '#modifier_form?' do
    context 'with a non-modifier if statement' do
      let(:source) { 'if foo?; :bar; end' }

      it { expect(if_node.modifier_form?).to be_falsey }
    end

    context 'with a non-modifier unless statement' do
      let(:source) { 'unless foo?; :bar; end' }

      it { expect(if_node.modifier_form?).to be_falsey }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :bar : :baz' }

      it { expect(if_node.modifier_form?).to be_falsey }
    end

    context 'with a modifier if statement' do
      let(:source) { ':bar if foo?' }

      it { expect(if_node.modifier_form?).to be_truthy }
    end

    context 'with a modifier unless statement' do
      let(:source) { ':bar unless foo?' }

      it { expect(if_node.modifier_form?).to be_truthy }
    end
  end

  describe '#nested_conditional?' do
    context 'with no nested conditionals' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'else',
         '  3',
         'end'].join("\n")
      end

      it { expect(if_node.nested_conditional?).to be_falsey }
    end

    context 'with nested conditionals in if clause' do
      let(:source) do
        ['if foo?',
         '  if baz; 4; end',
         'elsif bar?',
         '  2',
         'else',
         '  3',
         'end'].join("\n")
      end

      it { expect(if_node.nested_conditional?).to be_truthy }
    end

    context 'with nested conditionals in elsif clause' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  if baz; 4; end',
         'else',
         '  3',
         'end'].join("\n")
      end

      it { expect(if_node.nested_conditional?).to be_truthy }
    end

    context 'with nested conditionals in else clause' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'else',
         '  if baz; 4; end',
         'end'].join("\n")
      end

      it { expect(if_node.nested_conditional?).to be_truthy }
    end

    context 'with nested ternary operators' do
      context 'when nested in the truthy branch' do
        let(:source) { 'foo? ? bar? ? 1 : 2 : 3' }

        it { expect(if_node.nested_conditional?).to be_truthy }
      end

      context 'when nested in the falsey branch' do
        let(:source) { 'foo? ? 3 : bar? ? 1 : 2' }

        it { expect(if_node.nested_conditional?).to be_truthy }
      end
    end
  end

  describe '#elsif_conditional?' do
    context 'with one elsif conditional' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'else',
         '  3',
         'end'].join("\n")
      end

      it { expect(if_node.elsif_conditional?).to be_truthy }
    end

    context 'with multiple elsif conditionals' do
      let(:source) do
        ['if foo?',
         '  1',
         'elsif bar?',
         '  2',
         'elsif baz?',
         '  3',
         'else',
         '  4',
         'end'].join("\n")
      end

      it { expect(if_node.elsif_conditional?).to be_truthy }
    end

    context 'with nested conditionals in if clause' do
      let(:source) do
        ['if foo?',
         '  if baz; 1; end',
         'else',
         '  2',
         'end'].join("\n")
      end

      it { expect(if_node.elsif_conditional?).to be_falsey }
    end

    context 'with nested conditionals in else clause' do
      let(:source) do
        ['if foo?',
         '  1',
         'else',
         '  if baz; 2; end',
         'end'].join("\n")
      end

      it { expect(if_node.elsif_conditional?).to be_falsey }
    end

    context 'with nested ternary operators' do
      context 'when nested in the truthy branch' do
        let(:source) { 'foo? ? bar? ? 1 : 2 : 3' }

        it { expect(if_node.elsif_conditional?).to be_falsey }
      end

      context 'when nested in the falsey branch' do
        let(:source) { 'foo? ? 3 : bar? ? 1 : 2' }

        it { expect(if_node.elsif_conditional?).to be_falsey }
      end
    end
  end

  describe '#if_branch' do
    context 'with an if statement' do
      let(:source) do
        ['if foo?',
         '  :foo',
         'else',
         '  42',
         'end'].join("\n")
      end

      it { expect(if_node.if_branch).to be_sym_type }
    end

    context 'with an unless statement' do
      let(:source) do
        ['unless foo?',
         '  :foo',
         'else',
         '  42',
         'end'].join("\n")
      end

      it { expect(if_node.if_branch).to be_sym_type }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :foo : 42' }

      it { expect(if_node.if_branch).to be_sym_type }
    end
  end

  describe '#else_branch' do
    context 'with an if statement' do
      let(:source) do
        ['if foo?',
         '  :foo',
         'else',
         '  42',
         'end'].join("\n")
      end

      it { expect(if_node.else_branch).to be_int_type }
    end

    context 'with an unless statement' do
      let(:source) do
        ['unless foo?',
         '  :foo',
         'else',
         '  42',
         'end'].join("\n")
      end

      it { expect(if_node.else_branch).to be_int_type }
    end

    context 'with a ternary operator' do
      let(:source) { 'foo? ? :foo : 42' }

      it { expect(if_node.else_branch).to be_int_type }
    end
  end
end
