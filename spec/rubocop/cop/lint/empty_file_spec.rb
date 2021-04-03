# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyFile, :config do
  let(:commissioner) { RuboCop::Cop::Commissioner.new([cop]) }
  let(:offenses) { commissioner.investigate(processed_source).offenses }
  let(:cop_config) { { 'AllowComments' => true } }
  let(:source) { '' }

  it 'registers an offense when the file is empty' do
    expect(offenses.size).to eq(1)
    offense = offenses.first
    expect(offense.message).to eq('Empty file detected.')
    expect(offense.severity).to eq(:warning)
  end

  it 'does not register an offense when the file contains code' do
    expect_no_offenses(<<~RUBY)
      foo.bar
    RUBY
  end

  it 'does not register an offense when the file contains comments' do
    expect_no_offenses(<<~RUBY)
      # comment
    RUBY
  end

  context 'when AllowComments is false' do
    let(:cop_config) { { 'AllowComments' => false } }
    let(:source) { '# comment' }

    it 'registers an offense when the file contains comments' do
      expect(offenses.size).to eq(1)
    end
  end
end
