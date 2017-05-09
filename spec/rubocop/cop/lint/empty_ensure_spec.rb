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
    corrected = autocorrect_source(cop, <<-END.strip_indent)
      begin
        something
      ensure
      end
    END
    expect(corrected).to eq(<<-END.strip_indent)
      begin
        something

      end
    END
  end

  it 'does not register an offense for non-empty ensure' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      ensure
        file.close
      end
    END
  end
end
