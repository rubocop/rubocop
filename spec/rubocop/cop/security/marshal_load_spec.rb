# frozen_string_literal: true

describe RuboCop::Cop::Security::MarshalLoad, :config do
  subject(:cop) { described_class.new(config) }

  it 'accepts Marshal.dump' do
    inspect_source(cop, 'Marshal.dump({})')
    expect(cop.offenses).to be_empty
  end

  it 'accepts Module::Marshal.dump' do
    inspect_source(cop, 'Module::Marshal.dump({})')
    expect(cop.offenses).to be_empty
  end

  [:load, :restore].each do |method|
    it "registers an offense for Marshal.#{method}" do
      inspect_source(cop, "Marshal.#{method}('{}')")
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to include("Marshal.#{method}")
    end
  end
end
