# frozen_string_literal: true

describe RuboCop::Cop::Security::YAMLLoad, :config do
  subject(:cop) { described_class.new(config) }

  it 'accepts YAML.dump' do
    inspect_source(cop, 'YAML.dump("foo")')
    expect(cop.offenses).to be_empty
  end

  it 'accepts Module::YAML.dump' do
    inspect_source(cop, 'Module::YAML.dump("foo")')
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for YAML.load' do
    inspect_source(cop, 'YAML.load("--- foo")')
    expect(cop.offenses.size).to eq(1)
    expect(cop.offenses.first.message).to include('YAML.load')
  end

  it "autocorrects '.load' to '.safe_load'" do
    corrected = autocorrect_source(cop, "YAML.load('--- foo')")
    expect(corrected).to eq("YAML.safe_load('--- foo')")
  end
end
