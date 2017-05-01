# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceAroundBlockParameters, :config do
  subject(:cop) { described_class.new(config) }

  shared_examples 'common behavior' do
    it 'accepts an empty block' do
      expect_no_offenses('{}.each {}')
    end

    it 'skips lambda without args' do
      expect_no_offenses('->() { puts "a" }')
    end
  end

  context 'when EnforcedStyleInsidePipes is no_space' do
    let(:cop_config) { { 'EnforcedStyleInsidePipes' => 'no_space' } }

    include_examples 'common behavior'

    it 'accepts a block with spaces in the right places' do
      expect_no_offenses('{}.each { |x, y| puts x }')
    end

    it 'accepts a block with parameters but no body' do
      expect_no_offenses('{}.each { |x, y| }')
    end

    it 'accepts a block parameter without preceding space' do
      # This is checked by Layout/SpaceAfterComma.
      expect_no_offenses('{}.each { |x,y| puts x }')
    end

    it 'registers an offense for space before first parameter' do
      inspect_source(cop, '{}.each { | x| puts x }')
      expect(cop.messages)
        .to eq(['Space before first block parameter detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'registers an offense for space after last parameter' do
      inspect_source(cop, '{}.each { |x, y  | puts x }')
      expect(cop.messages).to eq(['Space after last block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'registers an offense for no space after closing pipe' do
      inspect_source(cop, '{}.each { |x, y|puts x }')
      expect(cop.messages).to eq(['Space after closing `|` missing.'])
      expect(cop.highlights).to eq(['|'])
    end

    it 'accepts line break after closing pipe' do
      expect_no_offenses(<<-END.strip_indent)
        {}.each do |x, y|
          puts x
        end
      END
    end

    it 'registers an offense for multiple spaces before parameter' do
      inspect_source(cop, '{}.each { |x,   y| puts x }')
      expect(cop.messages)
        .to eq(['Extra space before block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    context 'trailing comma' do
      it 'registers an offense for space after the last comma' do
        inspect_source(cop, '{}.each { |x, | puts x }')
        expect(cop.messages)
          .to eq(['Space after last block parameter detected.'])
        expect(cop.highlights).to eq([' '])
      end

      it 'accepts no space after the last comma' do
        expect_no_offenses('{}.each { |x,| puts x }')
      end
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop,
                                      '{}.each { |  x=5,  (y,*z) |puts x }')
      expect(new_source).to eq('{}.each { |x=5, (y,*z)| puts x }')
    end
  end

  context 'when EnforcedStyleInsidePipes is space' do
    let(:cop_config) { { 'EnforcedStyleInsidePipes' => 'space' } }

    include_examples 'common behavior'

    it 'accepts a block with spaces in the right places' do
      expect_no_offenses('{}.each { | x, y | puts x }')
    end

    it 'accepts a block with parameters but no body' do
      expect_no_offenses('{}.each { | x, y | }')
    end

    it 'accepts a block parameter without preceding space' do
      # This is checked by Layout/SpaceAfterComma.
      expect_no_offenses('{}.each { | x,y | puts x }')
    end

    it 'registers an offense for no space before first parameter' do
      inspect_source(cop, '{}.each { |x | puts x }')
      expect(cop.messages)
        .to eq(['Space before first block parameter missing.'])
      expect(cop.highlights).to eq(['x'])
    end

    it 'registers an offense for no space after last parameter' do
      inspect_source(cop, '{}.each { | x, y| puts x }')
      expect(cop.messages).to eq(['Space after last block parameter missing.'])
      expect(cop.highlights).to eq(['y'])
    end

    it 'registers an offense for extra space before first parameter' do
      inspect_source(cop, '{}.each { |  x | puts x }')
      expect(cop.messages)
        .to eq(['Extra space before first block parameter detected.'])
      expect(cop.highlights).to eq([' '])
    end

    it 'registers an offense for multiple spaces after last parameter' do
      inspect_source(cop, '{}.each { | x, y   | puts x }')
      expect(cop.messages)
        .to eq(['Extra space after last block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    it 'registers an offense for no space after closing pipe' do
      inspect_source(cop, '{}.each { | x, y |puts x }')
      expect(cop.messages).to eq(['Space after closing `|` missing.'])
      expect(cop.highlights).to eq(['|'])
    end

    it 'accepts line break after closing pipe' do
      expect_no_offenses(<<-END.strip_indent)
        {}.each do | x, y |
          puts x
        end
      END
    end

    it 'registers an offense for multiple spaces before parameter' do
      inspect_source(cop, '{}.each { | x,   y | puts x }')
      expect(cop.messages)
        .to eq(['Extra space before block parameter detected.'])
      expect(cop.highlights).to eq(['  '])
    end

    context 'trailing comma' do
      it 'accepts space after the last comma' do
        expect_no_offenses('{}.each { | x, | puts x }')
      end

      it 'registers an offense for no space after the last comma' do
        inspect_source(cop, '{}.each { | x,| puts x }')
        expect(cop.messages)
          .to eq(['Space after last block parameter missing.'])
        expect(cop.highlights).to eq(['x'])
      end
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop,
                                      '{}.each { |  x=5,  (y,*z)|puts x }')
      expect(new_source).to eq('{}.each { | x=5, (y,*z) | puts x }')
    end
  end
end
