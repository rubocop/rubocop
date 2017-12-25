# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::CollectionMethods, :config do
  cop_config = {
    'PreferredMethods' => {
      'collect' => 'map',
      'inject' => 'reduce',
      'detect' => 'find',
      'find_all' => 'select'
    }
  }

  subject(:cop) { described_class.new(config) }

  let(:cop_config) { cop_config }

  cop_config['PreferredMethods'].each do |method, preferred_method|
    it "registers an offense for #{method} with block" do
      inspect_source("[1, 2, 3].#{method} { |e| e + 1 }")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Prefer `#{preferred_method}` over `#{method}`."])
    end

    it "registers an offense for #{method} with proc param" do
      inspect_source("[1, 2, 3].#{method}(&:test)")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Prefer `#{preferred_method}` over `#{method}`."])
    end

    it "accepts #{method} with more than 1 param" do
      inspect_source("[1, 2, 3].#{method}(other, &:test)")
      expect(cop.offenses.empty?).to be(true)
    end

    it "accepts #{method} without a block" do
      inspect_source("[1, 2, 3].#{method}")
      expect(cop.offenses.empty?).to be(true)
    end

    it 'auto-corrects to preferred method' do
      new_source = autocorrect_source('some.collect(&:test)')
      expect(new_source).to eq('some.map(&:test)')
    end
  end
end
