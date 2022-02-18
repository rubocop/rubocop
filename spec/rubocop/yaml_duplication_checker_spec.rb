# frozen_string_literal: true

RSpec.describe RuboCop::YAMLDuplicationChecker do
  def check(yaml, &block)
    described_class.check(yaml, 'dummy.yaml', &block)
  end

  shared_examples 'call block' do
    it 'calls block' do
      called = false
      check(yaml) { called = true }
      expect(called).to be(true)
    end
  end

  context 'when yaml has duplicated keys in the top level' do
    let(:yaml) { <<~YAML }
      Layout/IndentationStyle:
        Enabled: true

      Layout/IndentationStyle:
        Enabled: false
    YAML

    include_examples 'call block'

    it 'calls block with keys' do
      key1 = nil
      key2 = nil
      check(yaml) do |key_a, key_b|
        key1 = key_a
        key2 = key_b
      end
      expect(key1.start_line).to eq(0)
      expect(key2.start_line).to eq(3)
      expect(key1.value).to eq('Layout/IndentationStyle')
      expect(key2.value).to eq('Layout/IndentationStyle')
    end
  end

  context 'when yaml has duplicated keys in the second level' do
    let(:yaml) { <<~YAML }
      Layout/IndentationStyle:
        Enabled: true
        Enabled: false
    YAML

    include_examples 'call block'

    it 'calls block with keys' do
      key1 = nil
      key2 = nil
      check(yaml) do |key_a, key_b|
        key1 = key_a
        key2 = key_b
      end
      expect(key1.start_line).to eq(1)
      expect(key2.start_line).to eq(2)
      expect(key1.value).to eq('Enabled')
      expect(key2.value).to eq('Enabled')
    end
  end

  context 'when yaml does not have any duplication' do
    let(:yaml) { <<~YAML }
      Style/TrailingCommaInHashLiteral:
        Enabled: true
        EnforcedStyleForMultiline: no_comma
      Style/TrailingBodyOnModule:
        Enabled: true
    YAML

    it 'does not call block' do
      called = false
      described_class.check(yaml, 'dummy.yaml') { called = true }
      expect(called).to be(false)
    end
  end
end
