# frozen_string_literal: true

describe RuboCop::Cop::Security::JSONLoad, :config do
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

  shared_examples 'accepted method' do |method|
    include_examples 'code without offense',
                     "JSON.#{method}(arg)"

    include_examples 'code without offense',
                     "::JSON.#{method}(arg)"

    include_examples 'code without offense',
                     "Module::JSON.#{method}(arg)"
  end

  shared_examples 'offensive method' do |method|
    include_examples 'code with offense',
                     "JSON.#{method}(arg)",
                     "Prefer `JSON.parse` over `JSON.#{method}`.",
                     'JSON.parse(arg)'

    include_examples 'code with offense',
                     "::JSON.#{method}(arg)",
                     "Prefer `JSON.parse` over `JSON.#{method}`.",
                     '::JSON.parse(arg)'

    include_examples 'code without offense',
                     "Module::JSON.#{method}(arg)"
  end

  include_examples 'accepted method', :parse

  include_examples 'accepted method', :dump

  include_examples 'offensive method', :load

  include_examples 'offensive method', :restore
end
