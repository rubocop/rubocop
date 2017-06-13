# frozen_string_literal: true

describe RuboCop::Cop::Performance::LstripRstrip do
  subject(:cop) { described_class.new }

  it 'autocorrects str.lstrip.rstrip' do
    new_source = autocorrect_source('str.lstrip.rstrip')
    expect(new_source).to eq 'str.strip'
  end

  it 'autocorrects str.rstrip.lstrip' do
    new_source = autocorrect_source('str.rstrip.lstrip')
    expect(new_source).to eq 'str.strip'
  end

  it 'formats the error message correctly for str.lstrip.rstrip' do
    expect_offense(<<-RUBY.strip_indent)
      str.lstrip.rstrip
          ^^^^^^^^^^^^^ Use `strip` instead of `lstrip.rstrip`.
    RUBY
  end
end
