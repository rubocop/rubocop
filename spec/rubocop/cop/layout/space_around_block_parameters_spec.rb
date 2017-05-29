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

    it 'skips lambda without parens' do
      expect_no_offenses('->a { puts a }')
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

    it 'accepts a lambda with spaces in the right places' do
      expect_no_offenses('->(x, y) { puts x }')
    end

    it 'registers an offense for space before first parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { | x| puts x }
                   ^ Space before first block parameter detected.
      RUBY
    end

    it 'registers an offense for space after last parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { |x, y  | puts x }
                       ^^ Space after last block parameter detected.
      RUBY
    end

    it 'registers an offense for no space after closing pipe' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { |x, y|puts x }
                       ^ Space after closing `|` missing.
      RUBY
    end

    it 'registers an offense to a lambda for space before first parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->( x, y) { puts x }
           ^ Space before first block parameter detected.
      RUBY
    end

    it 'registers an offense to a lambda for space after last parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->(x, y  ) { puts x }
               ^^ Space after last block parameter detected.
      RUBY
    end

    it 'accepts line break after closing pipe' do
      expect_no_offenses(<<-END.strip_indent)
        {}.each do |x, y|
          puts x
        end
      END
    end

    it 'registers an offense for multiple spaces before parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { |x,   y| puts x }
                     ^^ Extra space before block parameter detected.
      RUBY
    end

    context 'trailing comma' do
      it 'registers an offense for space after the last comma' do
        expect_offense(<<-RUBY.strip_indent)
          {}.each { |x, | puts x }
                       ^ Space after last block parameter detected.
        RUBY
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

    it 'auto-corrects offenses for a lambda' do
      new_source = autocorrect_source(cop,
                                      '->(  a,  b, c) { puts a }')
      expect(new_source).to eq('->(a, b, c) { puts a }')
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

    it 'accepts a lambda with spaces in the right places' do
      expect_no_offenses('->( x, y ) { puts x }')
    end

    it 'registers an offense for no space before first parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { |x | puts x }
                   ^ Space before first block parameter missing.
      RUBY
    end

    it 'registers an offense for no space after last parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { | x, y| puts x }
                       ^ Space after last block parameter missing.
      RUBY
    end

    it 'registers an offense for extra space before first parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { |  x | puts x }
                   ^ Extra space before first block parameter detected.
      RUBY
    end

    it 'registers an offense for multiple spaces after last parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { | x, y   | puts x }
                         ^^ Extra space after last block parameter detected.
      RUBY
    end

    it 'registers an offense for no space after closing pipe' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { | x, y |puts x }
                         ^ Space after closing `|` missing.
      RUBY
    end

    it 'registers an offense to a lambda for no space before first parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->(x ) { puts x }
           ^ Space before first block parameter missing.
      RUBY
    end

    it 'registers an offense to a lambda for no space after last parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->( x, y) { puts x }
               ^ Space after last block parameter missing.
      RUBY
    end

    it 'registers an offense to a lambda for extra space' \
       'before first parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->(  x ) { puts x }
           ^ Extra space before first block parameter detected.
      RUBY
    end

    it 'registers an offense to a lambda for multiple spaces' \
       'after last parameter' do
      expect_offense(<<-RUBY.strip_indent)
        ->( x, y   ) { puts x }
                 ^^ Extra space after last block parameter detected.
      RUBY
    end

    it 'accepts line break after closing pipe' do
      expect_no_offenses(<<-END.strip_indent)
        {}.each do | x, y |
          puts x
        end
      END
    end

    it 'registers an offense for multiple spaces before parameter' do
      expect_offense(<<-RUBY.strip_indent)
        {}.each { | x,   y | puts x }
                      ^^ Extra space before block parameter detected.
      RUBY
    end

    context 'trailing comma' do
      it 'accepts space after the last comma' do
        expect_no_offenses('{}.each { | x, | puts x }')
      end

      it 'registers an offense for no space after the last comma' do
        expect_offense(<<-RUBY.strip_indent)
          {}.each { | x,| puts x }
                      ^ Space after last block parameter missing.
        RUBY
      end
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop,
                                      '{}.each { |  x=5,  (y,*z)|puts x }')
      expect(new_source).to eq('{}.each { | x=5, (y,*z) | puts x }')
    end

    it 'auto-corrects offenses' do
      new_source = autocorrect_source(cop,
                                      '->(  x,  y) { puts x }')
      expect(new_source).to eq('->( x, y ) { puts x }')
    end
  end
end
