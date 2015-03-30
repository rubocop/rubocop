# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Performance::FlatMap, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'map_and_collect' do |method|
    it "registers an offense when calling #{method}...flatten(1)" do
      inspect_source(cop, "[1, 2, 3, 4].#{method} { |e| [e, e] }.flatten(1)")

      expect(cop.messages)
        .to eq(["Use `flat_map` instead of `#{method}...flatten`."])
    end

    it "does not register an offense when calling #{method}...flatten " \
      'with a number greater than 1' do
      inspect_source(cop, "[1, 2, 3, 4].#{method} { |e| [e, e] }.flatten(3)")

      expect(cop.messages).to be_empty
    end

    it "does not register an offense when calling #{method}!...flatten!" do
      inspect_source(cop, "[1, 2, 3, 4].#{method}! { |e| [e, e] }.flatten!")

      expect(cop.messages).to be_empty
    end

    it "corrects #{method}..flatten(1) to flat_map" do
      source = "[1, 2].#{method} { |e| [e, e] }.flatten(1)"
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq('[1, 2].flat_map { |e| [e, e] }')
    end
  end

  describe 'configured to only warn when flattening one level' do
    let(:config) do
      RuboCop::Config.new('Performance/FlatMap' => {
                            'Enabled' => true,
                            'EnabledForFlattenWithoutParams' => false
                          })
    end

    it_behaves_like('map_and_collect', 'map')
    it_behaves_like('map_and_collect', 'collect')

    it 'does not registers an offense when calling map...flatten' do
      inspect_source(cop, '[1, 2, 3, 4].map { |e| [e, e] }.flatten')

      expect(cop.messages).to be_empty
    end

    it 'does not registers an offense when calling collect...flatten' do
      inspect_source(cop, '[1, 2, 3, 4].collect { |e| [e, e] }.flatten')

      expect(cop.messages).to be_empty
    end
  end

  describe 'configured to warn when flatten is not called with parameters' do
    let(:config) do
      RuboCop::Config.new('Performance/FlatMap' => {
                            'Enabled' => true,
                            'EnabledForFlattenWithoutParams' => true
                          })
    end

    it_behaves_like('map_and_collect', 'map')
    it_behaves_like('map_and_collect', 'collect')

    it 'does not registers an offense when calling map...flatten' do
      inspect_source(cop, '[1, 2, 3, 4].map { |e| [e, e] }.flatten')

      expect(cop.messages)
        .to eq(['Use `flat_map` instead of `map...flatten`. ' \
             'Beware, `flat_map` only flattens 1 level and `flatten` ' \
             'can be used to flatten multiple levels'])
    end

    it 'does not registers an offense when calling collect...flatten' do
      inspect_source(cop, '[1, 2, 3, 4].collect { |e| [e, e] }.flatten')

      expect(cop.messages)
        .to eq(['Use `flat_map` instead of `collect...flatten`. ' \
             'Beware, `flat_map` only flattens 1 level and `flatten` ' \
             'can be used to flatten multiple levels'])
    end

    it 'will not correct map..flatten to flat_map' do
      source = '[1, 2].map { |e| [e, e] }.flatten'
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq('[1, 2].map { |e| [e, e] }.flatten')
    end

    it 'will not correct collect..flatten to flat_map' do
      source = '[1, 2].collect { |e| [e, e] }.flatten'
      new_source = autocorrect_source(cop, source)

      expect(new_source).to eq('[1, 2].collect { |e| [e, e] }.flatten')
    end
  end
end
