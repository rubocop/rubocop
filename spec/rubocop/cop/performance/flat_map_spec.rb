# frozen_string_literal: true

describe RuboCop::Cop::Performance::FlatMap, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'map_and_collect' do |method, flatten|
    it "registers an offense when calling #{method}...#{flatten}(1)" do
      inspect_source("[1, 2, 3, 4].#{method} { |e| [e, e] }.#{flatten}(1)")

      expect(cop.messages)
        .to eq(["Use `flat_map` instead of `#{method}...#{flatten}`."])
      expect(cop.highlights).to eq(["#{method} { |e| [e, e] }.#{flatten}(1)"])
    end

    it "does not register an offense when calling #{method}...#{flatten} " \
      'with a number greater than 1' do
      inspect_source("[1, 2, 3, 4].#{method} { |e| [e, e] }.#{flatten}(3)")

      expect(cop.messages).to be_empty
    end

    it "does not register an offense when calling #{method}!...#{flatten}" do
      inspect_source("[1, 2, 3, 4].#{method}! { |e| [e, e] }.#{flatten}")

      expect(cop.messages).to be_empty
    end

    it "corrects #{method}..#{flatten}(1) to flat_map" do
      source = "[1, 2].#{method} { |e| [e, e] }.#{flatten}(1)"
      new_source = autocorrect_source(source)

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

    shared_examples 'flatten_with_params_disabled' do |method, flatten|
      it "does not register an offense when calling #{method}...#{flatten}" do
        inspect_source("[1, 2, 3, 4].map { |e| [e, e] }.#{flatten}")

        expect(cop.messages).to be_empty
      end
    end

    it_behaves_like('map_and_collect', 'map', 'flatten')
    it_behaves_like('map_and_collect', 'map', 'flatten!')
    it_behaves_like('map_and_collect', 'collect', 'flatten')
    it_behaves_like('map_and_collect', 'collect', 'flatten!')

    it_behaves_like('flatten_with_params_disabled', 'map', 'flatten')
    it_behaves_like('flatten_with_params_disabled', 'collect', 'flatten')
    it_behaves_like('flatten_with_params_disabled', 'map', 'flatten!')
    it_behaves_like('flatten_with_params_disabled', 'collect', 'flatten!')
  end

  describe 'configured to warn when flatten is not called with parameters' do
    let(:config) do
      RuboCop::Config.new('Performance/FlatMap' => {
                            'Enabled' => true,
                            'EnabledForFlattenWithoutParams' => true
                          })
    end

    shared_examples 'flatten_with_params_enabled' do |method, flatten|
      it "registers an offense when calling #{method}...#{flatten}" do
        inspect_source("[1, 2, 3, 4].map { |e| [e, e] }.#{flatten}")

        expect(cop.messages)
          .to eq(["Use `flat_map` instead of `map...#{flatten}`. " \
               'Beware, `flat_map` only flattens 1 level and `flatten` ' \
               'can be used to flatten multiple levels.'])
        expect(cop.highlights).to eq(["map { |e| [e, e] }.#{flatten}"])
      end

      it "will not correct #{method}..#{flatten} to flat_map" do
        source = "[1, 2].map { |e| [e, e] }.#{flatten}"
        new_source = autocorrect_source(source)

        expect(new_source).to eq("[1, 2].map { |e| [e, e] }.#{flatten}")
      end
    end

    it_behaves_like('map_and_collect', 'map', 'flatten')
    it_behaves_like('map_and_collect', 'map', 'flatten!')
    it_behaves_like('map_and_collect', 'collect', 'flatten')
    it_behaves_like('map_and_collect', 'collect', 'flatten!')

    it_behaves_like('flatten_with_params_enabled', 'map', 'flatten')
    it_behaves_like('flatten_with_params_enabled', 'collect', 'flatten')
    it_behaves_like('flatten_with_params_enabled', 'map', 'flatten!')
    it_behaves_like('flatten_with_params_enabled', 'collect', 'flatten!')
  end
end
