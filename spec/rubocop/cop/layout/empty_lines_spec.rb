# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::EmptyLines do
  subject(:cop) { described_class.new }

  it 'registers an offense for consecutive empty lines' do
    inspect_source(['test = 5', '', '', '', 'top'])
    expect(cop.offenses.size).to eq(2)
  end

  it 'auto-corrects consecutive empty lines' do
    corrected = autocorrect_source(['test = 5', '', '', '', 'top'])
    expect(corrected).to eq ['test = 5', '', 'top'].join("\n")
  end

  it 'works when there are no tokens' do
    expect_no_offenses('#comment')
  end

  it 'handles comments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      test

      #comment
      top
    RUBY
  end

  it 'does not register an offense for empty lines in a string' do
    expect_no_offenses(<<-RUBY.strip_indent)
      result = "test



                                        string"
    RUBY
  end

  it 'does not register an offense for heredocs with empty lines inside' do
    expect_no_offenses(<<-RUBY.strip_indent)
      str = <<-TEXT
      line 1


      line 2
      TEXT
      puts str
    RUBY
  end
end
