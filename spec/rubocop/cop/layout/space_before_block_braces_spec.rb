# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceBeforeBlockBraces, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => 'space' } }

  context 'when EnforcedStyle is space' do
    it 'accepts braces surrounded by spaces' do
      expect_no_offenses('each { puts }')
    end

    it 'registers an offense for left brace without outer space' do
      inspect_source('each{ puts }')
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'no_space')
    end

    it 'registers an offense for opposite + correct style' do
      inspect_source(<<-RUBY.strip_indent)
        each{ puts }
        each { puts }
      RUBY
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for multiline block where left brace has no ' \
       'outer space' do
      inspect_source(<<-RUBY.strip_indent)
        foo.map{ |a|
          a.bar.to_s
        }
      RUBY
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'no_space')
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source('each{ puts }')
      expect(new_source).to eq('each { puts }')
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for braces surrounded by spaces' do
      inspect_source('each { puts }')
      expect(cop.messages).to eq(['Space detected to the left of {.'])
      expect(cop.highlights).to eq([' '])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'space')
    end

    it 'registers an offense for correct + opposite style' do
      inspect_source(<<-RUBY.strip_indent)
        each{ puts }
        each { puts }
      RUBY
      expect(cop.messages).to eq(['Space detected to the left of {.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts left brace without outer space' do
      expect_no_offenses('each{ puts }')
    end
  end

  context 'with space before empty braces not allowed' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'space',
        'EnforcedStyleForEmptyBraces' => 'no_space'
      }
    end

    it 'accepts empty braces without outer space' do
      expect_no_offenses('->{}')
    end

    it 'registers an offense for empty braces' do
      inspect_source('-> {}')
      expect(cop.messages).to eq(['Space detected to the left of {.'])
      expect(cop.highlights).to eq([' '])
      expect(cop.config_to_allow_offenses)
        .to eq('EnforcedStyleForEmptyBraces' => 'space')
    end

    it 'auto-corrects unwanted space' do
      new_source = autocorrect_source('-> {}')
      expect(new_source).to eq('->{}')
    end
  end

  context 'with space before empty braces allowed' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'no_space',
        'EnforcedStyleForEmptyBraces' => 'space'
      }
    end

    it 'accepts empty braces with outer space' do
      expect_no_offenses('-> {}')
    end

    it 'registers an offense for empty braces' do
      inspect_source('->{}')
      expect(cop.messages).to eq(['Space missing to the left of {.'])
      expect(cop.highlights).to eq(['{'])
      expect(cop.config_to_allow_offenses)
        .to eq('EnforcedStyleForEmptyBraces' => 'no_space')
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source('->{}')
      expect(new_source).to eq('-> {}')
    end
  end

  context 'with invalid value for EnforcedStyleForEmptyBraces' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBraces' => 'unknown' } }

    it 'fails with an error' do
      expect { inspect_source('each {}') }
        .to raise_error('Unknown EnforcedStyleForEmptyBraces selected!')
    end
  end
end
