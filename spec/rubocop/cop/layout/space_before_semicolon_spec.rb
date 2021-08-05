# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceBeforeSemicolon, :config do
  let(:config) { RuboCop::Config.new('Layout/SpaceInsideBlockBraces' => brace_config) }
  let(:brace_config) { {} }

  it 'registers an offense and corrects space before semicolon' do
    expect_offense(<<~RUBY)
      x = 1 ; y = 2
           ^ Space found before semicolon.
    RUBY

    expect_correction(<<~RUBY)
      x = 1; y = 2
    RUBY
  end

  it 'does not register an offense for no space before semicolons' do
    expect_no_offenses('x = 1; y = 2')
  end

  it 'registers an offense and corrects more than one space before a semicolon' do
    expect_offense(<<~RUBY)
      x = 1  ; y = 2
           ^^ Space found before semicolon.
    RUBY

    expect_correction(<<~RUBY)
      x = 1; y = 2
    RUBY
  end

  context 'inside block braces' do
    shared_examples 'common behavior' do
      it 'accepts no space between an opening brace and a semicolon' do
        expect_no_offenses('test {; }')
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) { { 'Enabled' => true, 'EnforcedStyle' => 'space' } }

      it_behaves_like 'common behavior'

      it 'accepts a space between an opening brace and a semicolon' do
        expect_no_offenses('test { ; }')
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) { { 'Enabled' => true, 'EnforcedStyle' => 'no_space' } }

      it_behaves_like 'common behavior'

      it 'registers an offense and corrects a space between an opening brace and a semicolon' do
        expect_offense(<<~RUBY)
          test { ; }
                ^ Space found before semicolon.
        RUBY

        expect_correction(<<~RUBY)
          test {; }
        RUBY
      end
    end
  end

  context 'heredocs' do
    it 'registers an offense and corrects' do
      expect_offense(<<~RUBY)
        <<~STR ; x = 1
              ^ Space found before semicolon.
          text
        STR
      RUBY

      expect_correction(<<~RUBY)
        <<~STR; x = 1
          text
        STR
      RUBY
    end
  end
end
