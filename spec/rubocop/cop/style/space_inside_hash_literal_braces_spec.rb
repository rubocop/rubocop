# frozen_string_literal: true

describe RuboCop::Cop::Style::SpaceInsideHashLiteralBraces, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'EnforcedStyle' => 'space' } }

  context 'with space inside empty braces not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'no_space' } }

    it 'accepts empty braces with no space inside' do
      inspect_source(cop, 'h = {}')
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for empty braces with space inside' do
      inspect_source(cop, 'h = { }')
      expect(cop.messages)
        .to eq(['Space inside empty hash literal braces detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, 'h = { }')
      expect(new_source).to eq('h = {}')
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'space' } }

    it 'accepts empty braces with space inside' do
      inspect_source(cop, 'h = { }')
      expect(cop.messages).to be_empty
    end

    it 'registers an offense for empty braces with no space inside' do
      inspect_source(cop, 'h = {}')
      expect(cop.messages)
        .to eq(['Space inside empty hash literal braces missing.'])
      expect(cop.highlights).to eq(['{'])
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(cop, 'h = {}')
      expect(new_source).to eq('h = { }')
    end
  end

  it 'registers an offense for hashes with no spaces if so configured' do
    inspect_source(cop, <<-END.strip_indent)
      h = {a: 1, b: 2}
      h = {a => 1}
    END
    expect(cop.messages).to eq(['Space inside { missing.',
                                'Space inside } missing.',
                                'Space inside { missing.',
                                'Space inside } missing.'])
    expect(cop.highlights).to eq(['{', '}', '{', '}'])
    expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'no_space')
  end

  it 'registers an offense for correct + opposite' do
    inspect_source(cop,
                   'h = { a: 1}')
    expect(cop.messages).to eq(['Space inside } missing.'])
    expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
  end

  it 'auto-corrects missing space' do
    new_source = autocorrect_source(cop, <<-END.strip_indent)
      h = {a: 1, b: 2}
      h = {a => 1 }
    END
    expect(new_source).to eq(<<-END.strip_indent)
      h = { a: 1, b: 2 }
      h = { a => 1 }
    END
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for hashes with spaces' do
      inspect_source(cop,
                     'h = { a: 1, b: 2 }')
      expect(cop.messages).to eq(['Space inside { detected.',
                                  'Space inside } detected.'])
      expect(cop.highlights).to eq([' ', ' '])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'space')
    end

    it 'registers an offense for opposite + correct' do
      inspect_source(cop,
                     'h = {a: 1 }')
      expect(cop.messages).to eq(['Space inside } detected.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        h = { a: 1, b: 2 }
        h = {a => 1 }
      END
      expect(new_source).to eq(<<-END.strip_indent)
        h = {a: 1, b: 2}
        h = {a => 1}
      END
    end

    it 'accepts hashes with no spaces' do
      inspect_source(cop, <<-END.strip_indent)
        h = {a: 1, b: 2}
        h = {a => 1}
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts multiline hash' do
      inspect_source(cop, <<-END.strip_indent)
        h = {
              a: 1,
              b: 2,
        }
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts multiline hash with comment' do
      inspect_source(cop, <<-END.strip_indent)
        h = { # Comment
              a: 1,
              b: 2,
        }
      END
      expect(cop.offenses).to be_empty
    end
  end

  context 'when EnforcedStyle is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it "doesn't register an offense for non-nested hashes with spaces" do
      inspect_source(cop, 'h = { a: 1, b: 2 }')
      expect(cop.offenses).to be_empty
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'compact')
    end

    it 'registers an offense for nested hashes with spaces' do
      inspect_source(cop, 'h = { a: { a: 1, b: 2 } }')
      expect(cop.offenses.size).to eq 1
      expect(cop.messages).to eq(['Space inside } detected.'])
    end

    it 'registers an offense for opposite + correct' do
      inspect_source(cop,
                     'h = {a: 1 }')
      expect(cop.messages).to eq(['Space inside { missing.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'auto-corrects hashes with no space' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        h = {a: 1, b: 2}
        h = {a => 1 }
      END
      expect(new_source).to eq(<<-END.strip_indent)
        h = { a: 1, b: 2 }
        h = { a => 1 }
      END
    end

    it 'auto-corrects nested hashes with spaces' do
      new_source = autocorrect_source(cop, <<-END.strip_indent)
        h = { a: { a: 1, b: 2 } }
        h = {a => method { 1 } }
      END
      expect(new_source).to eq(<<-END.strip_indent)
        h = { a: { a: 1, b: 2 }}
        h = { a => method { 1 }}
      END
    end

    it 'registers offenses for hashes with no spaces' do
      inspect_source(cop, <<-END.strip_indent)
        h = {a: 1, b: 2}
        h = {a => 1}
      END
      expect(cop.offenses.size).to eq 4
    end

    it 'accepts multiline hash' do
      inspect_source(cop, <<-END.strip_indent)
        h = {
              a: 1,
              b: 2,
        }
      END
      expect(cop.offenses).to be_empty
    end

    it 'accepts multiline hash with comment' do
      inspect_source(cop, <<-END.strip_indent)
        h = { # Comment
              a: 1,
              b: 2,
        }
      END
      expect(cop.offenses).to be_empty
    end
  end

  it 'accepts hashes with spaces by default' do
    inspect_source(cop, <<-END.strip_indent)
      h = { a: 1, b: 2 }
      h = { a => 1 }
    END
    expect(cop.offenses).to be_empty
  end

  it 'accepts hash literals with no braces' do
    inspect_source(cop, 'x(a: b.c)')
    expect(cop.offenses).to be_empty
  end

  it 'can handle interpolation in a braceless hash literal' do
    # A tricky special case where the closing brace of the
    # interpolation risks getting confused for a hash literal brace.
    inspect_source(cop, 'f(get: "#{x}")')
    expect(cop.offenses).to be_empty
  end

  context 'on Hash[{ x: 1 } => [1]]' do
    # regression test; see GH issue 2436
    it 'does not register an offense' do
      inspect_source(cop, 'Hash[{ x: 1 } => [1]]')
      expect(cop.offenses).to be_empty
    end
  end

  context 'on { key: "{" }' do
    # regression test; see GH issue 3958
    it 'does not register an offense' do
      inspect_source(cop, '{ key: "{" }')
      expect(cop.offenses).to be_empty
    end
  end
end
