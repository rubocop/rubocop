# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Security::JSONLoad, :config do
  subject(:cop) { described_class.new(config) }

  it 'accepts JSON.parse' do
    inspect_source(cop, 'JSON.parse("{}")')
    expect(cop.offenses).to be_empty
  end

  it 'accepts JSON.parse' do
    inspect_source(cop, 'Module::JSON.parse("{}")')
    expect(cop.offenses).to be_empty
  end

  it 'accepts JSON.dump' do
    inspect_source(cop, 'JSON.dump({})')
    expect(cop.offenses).to be_empty
  end

  it 'accepts JSON.dump' do
    inspect_source(cop, 'Module::JSON.load({})')
    expect(cop.offenses).to be_empty
  end

  [:load, :restore].each do |method|
    it "registers an offense for JSON.#{method}" do
      inspect_source(cop, "JSON.#{method}('{}')")
      expect(cop.offenses.size).to eq(1)
      expect(cop.offenses.first.message).to include("JSON##{method}")
    end

    it "autocorrects '.#{method}' to '.parse'" do
      corrected = autocorrect_source(cop, "JSON.#{method}('{}')")
      expect(corrected).to eq("JSON.parse('{}')")
    end
  end
end
