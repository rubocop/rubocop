# frozen_string_literal: true

describe RuboCop::Cop::Style::WhenThen do
  subject(:cop) { described_class.new }

  it 'registers an offense for when x;' do
    inspect_source(cop, <<-END.strip_indent)
      case a
      when b; c
      end
    END
    expect(cop.offenses.size).to eq(1)
  end

  it 'accepts when x then' do
    expect_no_offenses(<<-END.strip_indent)
      case a
      when b then c
      end
    END
  end

  it 'accepts ; separating statements in the body of when' do
    expect_no_offenses(<<-END.strip_indent)
      case a
      when b then c; d
      end

      case e
      when f
        g; h
      end
    END
  end

  it 'auto-corrects "when x;" with "when x then"' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      case a
      when b; c
      end
    END
    expect(new_source).to eq(<<-END.strip_indent)
      case a
      when b then c
      end
    END
  end

  # Regression: https://github.com/bbatsov/rubocop/issues/3868
  context 'when inspecting a case statement with an empty branch' do
    it 'does not register an offense' do
      expect_no_offenses(<<-END.strip_indent)
        case value
        when cond1
        end
      END
    end
  end
end
