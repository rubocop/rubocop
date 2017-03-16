# frozen_string_literal: true

describe RuboCop::Cop::Security::YAMLLoad, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, message, expected|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(message)
      end

      it 'auto-corrects' do
        expect(autocorrect_source(cop, code)).to eq expected
      end
    end
  end

  shared_examples 'code without offense' do |code|
    context "when checking #{code}" do
      let(:source) { code }

      it 'does not register any offense' do
        expect(cop.offenses).to be_empty
      end
    end
  end

  include_examples 'code without offense',
                   'YAML.dump("foo")'

  include_examples 'code without offense',
                   '::YAML.dump("foo")'

  include_examples 'code without offense',
                   'Module::YAML.dump("foo")'

  include_examples 'code with offense',
                   'YAML.load("--- foo")',
                   'Prefer using `YAML.safe_load` over `YAML.load`.',
                   'YAML.safe_load("--- foo")'

  include_examples 'code with offense',
                   '::YAML.load("--- foo")',
                   'Prefer using `YAML.safe_load` over `YAML.load`.',
                   '::YAML.safe_load("--- foo")'

  include_examples 'code without offense',
                   'Module::YAML.load("foo")'
end
