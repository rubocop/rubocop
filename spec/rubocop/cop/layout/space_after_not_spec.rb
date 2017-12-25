# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAfterNot do
  subject(:cop) { described_class.new }

  it 'reports an offense for space after !' do
    expect_offense(<<-RUBY.strip_indent)
      ! something
      ^^^^^^^^^^^ Do not leave space between `!` and its argument.
    RUBY
  end

  it 'accepts no space after !' do
    expect_no_offenses('!something')
  end

  it 'accepts space after not keyword' do
    expect_no_offenses('not something')
  end

  it 'reports an offense for space after ! with the negated receiver ' \
     'wrapped in parentheses' do
    inspect_source('! (model)')

    expect(cop.messages)
      .to eq(['Do not leave space between `!` and its argument.'])
    expect(cop.highlights).to eq(['! (model)'])
  end

  context 'auto-correct' do
    it 'removes redundant space' do
      new_source = autocorrect_source('!  something')

      expect(new_source).to eq('!something')
    end

    it 'keeps space after not keyword' do
      new_source = autocorrect_source('not something')

      expect(new_source).to eq('not something')
    end

    it 'removes redundant space when there is a parentheses' do
      new_source = autocorrect_source('!  (model)')

      expect(new_source).to eq('!(model)')
    end
  end
end
