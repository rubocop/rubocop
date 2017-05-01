# frozen_string_literal: true

describe RuboCop::Cop::Layout::EmptyLines do
  subject(:cop) { described_class.new }

  it 'registers an offense for consecutive empty lines' do
    inspect_source(cop,
                   ['test = 5', '', '', '', 'top'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'auto-corrects consecutive empty lines' do
    corrected = autocorrect_source(cop,
                                   ['test = 5', '', '', '', 'top'])
    expect(corrected).to eq ['test = 5', '', 'top'].join("\n")
  end

  it 'works when there are no tokens' do
    expect_no_offenses('#comment')
  end

  it 'handles comments' do
    inspect_source(cop,
                   ['test', '', '#comment', 'top'])
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for empty lines in a string' do
    inspect_source(cop, 'result = "test



                                  string"')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for heredocs with empty lines inside' do
    expect_no_offenses(<<-END.strip_indent)
      str = <<-TEXT
      line 1


      line 2
      TEXT
      puts str
    END
  end
end
