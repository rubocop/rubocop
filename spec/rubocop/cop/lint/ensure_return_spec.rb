# frozen_string_literal: true

describe RuboCop::Cop::Lint::EnsureReturn do
  subject(:cop) { described_class.new }

  it 'registers an offense for return in ensure' do
    inspect_source(cop, <<-END.strip_indent)
      begin
        something
      ensure
        file.close
        return
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for return outside ensure' do
    expect_no_offenses(<<-END.strip_indent)
      begin
        something
        return
      ensure
        file.close
      end
    END
  end

  it 'does not check when ensure block has no body' do
    expect do
      inspect_source(cop, <<-END.strip_indent)
        begin
          something
        ensure
        end
      END
    end.not_to raise_exception
  end
end
