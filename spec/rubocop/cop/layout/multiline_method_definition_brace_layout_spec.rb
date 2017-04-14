# frozen_string_literal: true

describe RuboCop::Cop::Layout::MultilineMethodDefinitionBraceLayout, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'symmetrical' } }

  it 'ignores implicit defs' do
    inspect_source(cop, <<-END.strip_indent)
      def foo a: 1,
      b: 2
      end
    END

    expect(cop.offenses).to be_empty
  end

  it 'ignores single-line defs' do
    inspect_source(cop, <<-END.strip_indent)
      def foo(a,b)
      end
    END

    expect(cop.offenses).to be_empty
  end

  it 'ignores defs without params' do
    inspect_source(cop, <<-END.strip_indent)
      def foo
      end
    END

    expect(cop.offenses).to be_empty
  end

  include_examples 'multiline literal brace layout' do
    let(:prefix) { 'def foo' }
    let(:suffix) { 'end' }
    let(:open) { '(' }
    let(:close) { ')' }
    let(:multi_prefix) { 'b: ' }
  end
end
