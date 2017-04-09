# frozen_string_literal: true

describe RuboCop::Cop::Style::IfUnlessModifierOfIfUnless do
  include StatementModifierHelper

  subject(:cop) { described_class.new }

  it 'provides a good error message' do
    source = 'condition ? then_part : else_part unless external_condition'
    inspect_source(cop, source)
    expect(cop.messages)
      .to eq(['Avoid modifier `unless` after another conditional.'])
  end

  context 'ternary with modifier' do
    let(:source) do
      'condition ? then_part : else_part unless external_condition'
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'conditional with modifier' do
    let(:source) do
      <<-END.strip_indent
        unless condition
          then_part
        end if external_condition
      END
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'conditional with modifier in body' do
    let(:source) do
      <<-END.strip_indent
        if condition
          then_part if maybe?
        end
      END
    end

    it 'accepts' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'nested conditionals' do
    let(:source) do
      <<-END.strip_indent
        if external_condition
          if condition
            then_part
          end
        end
      END
    end

    it 'accepts' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end
end
