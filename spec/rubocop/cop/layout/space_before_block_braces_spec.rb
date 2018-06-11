# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeBlockBraces, :config do
  subject(:cop) { described_class.new(config) }

  let(:cop_config) { { 'EnforcedStyle' => 'space' } }

  context 'when EnforcedStyle is space' do
    it 'accepts braces surrounded by spaces' do
      expect_no_offenses('each { puts }')
    end

    it 'registers an offense for left brace without outer space' do
      expect_offense(<<-RUBY.strip_indent)
        each{ puts }
            ^ Space missing to the left of {.
      RUBY
    end

    it 'registers an offense for opposite + correct style' do
      expect_offense(<<-RUBY.strip_indent)
        each{ puts }
            ^ Space missing to the left of {.
        each { puts }
      RUBY
    end

    it 'registers an offense for multiline block where left brace has no ' \
       'outer space' do
      expect_offense(<<-RUBY.strip_indent)
        foo.map{ |a|
               ^ Space missing to the left of {.
          a.bar.to_s
        }
      RUBY
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source('each{ puts }')
      expect(new_source).to eq('each { puts }')
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'registers an offense for braces surrounded by spaces' do
      expect_offense(<<-RUBY.strip_indent)
        each { puts }
            ^ Space detected to the left of {.
      RUBY
    end

    it 'registers an offense for correct + opposite style' do
      expect_offense(<<-RUBY.strip_indent)
        each{ puts }
        each { puts }
            ^ Space detected to the left of {.
      RUBY
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
      expect_offense(<<-RUBY.strip_indent)
        -> {}
          ^ Space detected to the left of {.
      RUBY
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
      expect_offense(<<-RUBY.strip_indent)
        ->{}
          ^ Space missing to the left of {.
      RUBY
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
