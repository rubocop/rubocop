# frozen_string_literal: true

describe RuboCop::Cop::Lint::EmptyEnsure do
  subject(:cop) { described_class.new }

  it 'registers an offense for empty ensure' do
    expect_offense(<<-RUBY.strip_indent)
      begin
        something
      ensure
      ^^^^^^ Empty `ensure` block detected.
      end
    RUBY
  end

  it 'autocorrects for empty ensure' do
    corrected = autocorrect_source(<<-RUBY.strip_indent)
      begin
        something
      ensure
      end
    RUBY
    expect(corrected).to eq(<<-RUBY.strip_indent)
      begin
        something

      end
    RUBY
  end

  it 'does not register an offense for non-empty ensure' do
    expect_no_offenses(<<-RUBY.strip_indent)
      begin
        something
        return
      ensure
        file.close
      end
    RUBY
  end
end
