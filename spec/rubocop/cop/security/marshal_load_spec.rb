# frozen_string_literal: true

describe RuboCop::Cop::Security::MarshalLoad, :config do
  subject(:cop) { described_class.new(config) }

  before do
    inspect_source(cop, source)
  end

  shared_examples 'code with offense' do |code, message|
    context "when checking #{code}" do
      let(:source) { code }

      it 'registers an offense' do
        expect(cop.offenses.size).to eq(1)
        expect(cop.offenses.first.message).to eq(message)
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

  shared_examples 'offensive method' do |method|
    include_examples 'code with offense',
                     "Marshal.#{method}('{}')",
                     "Avoid using `Marshal.#{method}`."

    include_examples 'code with offense',
                     "::Marshal.#{method}('{}')",
                     "Avoid using `Marshal.#{method}`."

    include_examples 'code without offense',
                     "Module::Marshal.#{method}('{}')"

    include_examples 'code without offense',
                     "Marshal.#{method}(Marshal.dump({}))"

    include_examples 'code without offense',
                     "::Marshal.#{method}(::Marshal.dump({}))"
  end

  include_examples 'code without offense',
                   'Marshal.dump({})'

  include_examples 'code without offense',
                   '::Marshal.dump({})'

  include_examples 'code without offense',
                   'Module::Marshal.dump({})'

  include_examples 'offensive method', :load

  include_examples 'offensive method', :restore
end
