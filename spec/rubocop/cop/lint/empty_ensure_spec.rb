# frozen_string_literal: true

describe RuboCop::Cop::Lint::EmptyEnsure do
  subject(:cop) { described_class.new }

  it 'registers an offense for empty ensure' do
    inspect_source(cop, <<-END.strip_indent)
      begin
        something
      ensure
      end
    END
    expect(cop.offenses.size).to eq(1)
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
    inspect_source(cop, <<-END.strip_indent)
      begin
        something
        return
      ensure
        file.close
      end
    END
    expect(cop.offenses).to be_empty
  end
end
