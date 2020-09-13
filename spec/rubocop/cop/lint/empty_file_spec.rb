# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::EmptyFile, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) do
    { 'AllowComments' => true }
  end

  it 'registers an offense when the file is empty' do
    expect_offense(<<~RUBY)
      ^ Empty file detected.
    RUBY
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
    let(:cop_config) do
      { 'AllowComments' => false }
    end

    it 'registers an offense when the file contains comments' do
      expect_offense(<<~RUBY)
        # comment
        ^ Empty file detected.
      RUBY
    end
  end
end
