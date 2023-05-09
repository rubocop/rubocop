# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAfterSemicolon, :config do
  let(:config) { RuboCop::Config.new('Layout/SpaceInsideBlockBraces' => brace_config) }
  let(:brace_config) { {} }

  it 'registers an offense and corrects semicolon without space after it' do
    expect_offense(<<~RUBY)
      x = 1;y = 2
           ^ Space missing after semicolon.
    RUBY

    expect_correction(<<~RUBY)
      x = 1; y = 2
    RUBY
  end

  it 'does not crash if semicolon is the last character of the file' do
    expect_no_offenses('x = 1;')
  end

  context 'inside block braces' do
    shared_examples 'common behavior' do
      it 'accepts a space between a semicolon and a closing brace' do
        expect_no_offenses('test { ; }')
      end

      it 'accepts no space between a semicolon and a closing brace of string interpolation' do
        expect_no_offenses(<<~'RUBY')
          "#{ ;}"
        RUBY
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is space' do
      let(:brace_config) { { 'Enabled' => true, 'EnforcedStyle' => 'space' } }

      it_behaves_like 'common behavior'

      it 'registers an offense and corrects no space between a semicolon and a closing brace' do
        expect_offense(<<~RUBY)
          test { ;}
                 ^ Space missing after semicolon.
        RUBY

        expect_correction(<<~RUBY)
          test { ; }
        RUBY
      end
    end

    context 'when EnforcedStyle for SpaceInsideBlockBraces is no_space' do
      let(:brace_config) { { 'Enabled' => true, 'EnforcedStyle' => 'no_space' } }

      it_behaves_like 'common behavior'

      it 'accepts no space between a semicolon and a closing brace' do
        expect_no_offenses('test { ;}')
      end
    end
  end
end
