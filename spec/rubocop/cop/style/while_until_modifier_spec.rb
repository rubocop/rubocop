# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::WhileUntilModifier do
  include StatementModifierHelper

  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new('Metrics/LineLength' => { 'Max' => 80 })
  end

  it "accepts multiline unless that doesn't fit on one line" do
    check_too_long('unless')
  end

  it 'accepts multiline unless whose body is more than one line' do
    check_short_multiline('unless')
  end

  context 'multiline while that fits on one line' do
    it 'registers an offense' do
      check_really_short('while')
    end

    it 'does auto-correction' do
      autocorrect_really_short('while')
    end
  end

  it "accepts multiline while that doesn't fit on one line" do
    check_too_long('while')
  end

  it 'accepts multiline while whose body is more than one line' do
    check_short_multiline('while')
  end

  it 'accepts oneline while when condition has local variable assignment' do
    expect_no_offenses(<<-RUBY.strip_indent)
      lines = %w{first second third}
      while (line = lines.shift)
        puts line
      end
    RUBY
  end

  context 'oneline while when assignment is in body' do
    let(:source) do
      <<-RUBY.strip_indent
        while true
          x = 0
        end
      RUBY
    end

    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        while true
        ^^^^^ Favor modifier `while` usage when having a single-line body.
          x = 0
        end
      RUBY
    end

    it 'does auto-correction' do
      corrected = autocorrect_source(source)
      expect(corrected).to eq "x = 0 while true\n"
    end
  end

  context 'multiline until that fits on one line' do
    it 'registers an offense' do
      check_really_short('until')
    end

    it 'does auto-correction' do
      autocorrect_really_short('until')
    end
  end

  it "accepts multiline until that doesn't fit on one line" do
    check_too_long('until')
  end

  it 'accepts multiline until whose body is more than one line' do
    check_short_multiline('until')
  end

  it 'accepts an empty condition' do
    check_empty('while')
    check_empty('until')
  end

  it 'accepts modifier while' do
    expect_no_offenses('ala while bala')
  end

  it 'accepts modifier until' do
    expect_no_offenses('ala until bala')
  end

  # Regression: https://github.com/rubocop-hq/rubocop/issues/4006
  context 'when the modifier condition is multiline' do
    it 'registers an offense' do
      expect_offense(<<-RUBY.strip_indent)
        foo while bar ||
            ^^^^^ Favor modifier `while` usage when having a single-line body.
          baz
      RUBY
    end
  end

  context 'when Metrics/LineLength is disabled' do
    let(:config) do
      RuboCop::Config.new(
        'Metrics/LineLength' => {
          'Enabled' => false,
          'Max' => 80
        }
      )
    end

    it 'registers an offense even for a long modifier statement' do
      expect_offense(<<-RUBY.strip_indent)
        while foo
        ^^^^^ Favor modifier `while` usage when having a single-line body.
          "This string would make the line longer than eighty characters if combined with the statement." 
        end
      RUBY
    end
  end
end
