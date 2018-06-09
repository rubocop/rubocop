# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::RandOne do
  subject(:cop) { described_class.new }

  shared_examples 'offenses' do |source|
    describe source do
      it 'registers an offense' do
        inspect_source(source)
        expect(cop.messages).to eq(
          [
            "`#{source}` always returns `0`. " \
            'Perhaps you meant `rand(2)` or `rand`?'
          ]
        )
        expect(cop.highlights).to eq([source])
      end
    end
  end

  shared_examples 'no offense' do |source|
    describe source do
      it 'does not register an offense' do
        expect_no_offenses(source)
      end
    end
  end

  it_behaves_like 'offenses', 'rand 1'
  it_behaves_like 'offenses', 'rand(-1)'
  it_behaves_like 'offenses', 'rand(1.0)'
  it_behaves_like 'offenses', 'rand(-1.0)'
  it_behaves_like 'no offense', 'rand'
  it_behaves_like 'no offense', 'rand(2)'
  it_behaves_like 'no offense', 'rand(-1..1)'

  it_behaves_like 'offenses', 'Kernel.rand(1)'
  it_behaves_like 'offenses', 'Kernel.rand(-1)'
  it_behaves_like 'offenses', 'Kernel.rand 1.0'
  it_behaves_like 'offenses', 'Kernel.rand(-1.0)'
  it_behaves_like 'no offense', 'Kernel.rand'
  it_behaves_like 'no offense', 'Kernel.rand 2'
  it_behaves_like 'no offense', 'Kernel.rand(-1..1)'
end
