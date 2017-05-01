# frozen_string_literal: true

describe RuboCop::Cop::Style::WhileUntilModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }
  let(:config) do
    hash = { 'Metrics/LineLength' => { 'Max' => 80 } }
    RuboCop::Config.new(hash)
  end

  it "accepts multiline unless that doesn't fit on one line" do
    check_too_long(cop, 'unless')
  end

  it 'accepts multiline unless whose body is more than one line' do
    check_short_multiline(cop, 'unless')
  end

  context 'multiline while that fits on one line' do
    it 'registers an offense' do
      check_really_short(cop, 'while')
    end

    it 'does auto-correction' do
      autocorrect_really_short(cop, 'while')
    end
  end

  it "accepts multiline while that doesn't fit on one line" do
    check_too_long(cop, 'while')
  end

  it 'accepts multiline while whose body is more than one line' do
    check_short_multiline(cop, 'while')
  end

  it 'accepts oneline while when condition has local variable assignment' do
    inspect_source(cop, <<-END.strip_indent)
      lines = %w{first second third}
      while (line = lines.shift)
        puts line
      end
    END
    expect(cop.offenses).to be_empty
  end

  context 'oneline while when assignment is in body' do
    let(:source) do
      <<-END.strip_indent
        while true
          x = 0
        end
      END
    end

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(cop, source)
      expect(corrected).to eq "x = 0 while true\n"
    end
  end

  context 'multiline until that fits on one line' do
    it 'registers an offense' do
      check_really_short(cop, 'until')
    end

    it 'does auto-correction' do
      autocorrect_really_short(cop, 'until')
    end
  end

  it "accepts multiline until that doesn't fit on one line" do
    check_too_long(cop, 'until')
  end

  it 'accepts multiline until whose body is more than one line' do
    check_short_multiline(cop, 'until')
  end

  it 'accepts an empty condition' do
    check_empty(cop, 'while')
    check_empty(cop, 'until')
  end

  it 'accepts modifier while' do
    expect_no_offenses('ala while bala')
  end

  it 'accepts modifier until' do
    expect_no_offenses('ala until bala')
  end

  # Regression: https://github.com/bbatsov/rubocop/issues/4006
  context 'when the modifier condition is multiline' do
    it 'registers an offense' do
      inspect_source(cop, <<-END.strip_indent)
        foo while bar ||
          baz
      END
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when the maximum line length is specified by the cop itself' do
    let(:config) do
      hash = {
        'Metrics/LineLength' => { 'Max' => 100 },
        'Style/WhileUntilModifier' => { 'MaxLineLength' => 80 }
      }
      RuboCop::Config.new(hash)
    end

    it "accepts multiline while that doesn't fit on one line" do
      check_too_long(cop, 'while')
    end

    it "accepts multiline until that doesn't fit on one line" do
      check_too_long(cop, 'until')
    end
  end
end
