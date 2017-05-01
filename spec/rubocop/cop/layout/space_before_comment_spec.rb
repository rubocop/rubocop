# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceBeforeComment do
  subject(:cop) { described_class.new }

  it 'registers an offense for missing space before an EOL comment' do
    inspect_source(cop, 'a += 1# increment')
    expect(cop.highlights).to eq(['# increment'])
  end

  it 'accepts an EOL comment with a preceding space' do
    expect_no_offenses('a += 1 # increment')
  end

  it 'accepts a comment that begins a line' do
    expect_no_offenses('# comment')
  end

  it 'accepts a doc comment' do
    inspect_source(cop, <<-END.strip_indent)
      =begin
      Doc comment
      =end
    END
    expect(cop.offenses).to be_empty
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, 'a += 1# increment')
    expect(new_source).to eq('a += 1 # increment')
  end
end
