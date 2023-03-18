# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundBlockParameters, :config do
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

    it 'accepts block parameters with surrounding space that includes line breaks' do
      # This is checked by Layout/MultilineBlockLayout.
      expect_no_offenses(<<~RUBY)
        some_result = lambda do |
          so_many,
          parameters,
          it_will,
          be_too_long,
          for_one_line
        |
          do_something
        end
      RUBY
    end

    it 'accepts a lambda with spaces in the right places' do
      expect_no_offenses('->(x, y) { puts x }')
    end

    it 'registers an offense and corrects space before first parameter' do
      expect_offense(<<~RUBY)
        {}.each { | x| puts x }
                   ^ Space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { |x| puts x }
      RUBY
    end

    it 'registers an offense and corrects space after last parameter' do
      expect_offense(<<~RUBY)
        {}.each { |x, y  | puts x }
                       ^^ Space after last block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { |x, y| puts x }
      RUBY
    end

    it 'registers an offense and corrects no space after closing pipe' do
      expect_offense(<<~RUBY)
        {}.each { |x, y|puts x }
                       ^ Space after closing `|` missing.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { |x, y| puts x }
      RUBY
    end

    it 'registers an offense and corrects a lambda for space before first parameter' do
      expect_offense(<<~RUBY)
        ->( x, y) { puts x }
           ^ Space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        ->(x, y) { puts x }
      RUBY
    end

    it 'registers an offense and corrects a lambda for space after the last parameter' do
      expect_offense(<<~RUBY)
        ->(x, y  ) { puts x }
               ^^ Space after last block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        ->(x, y) { puts x }
      RUBY
    end

    it 'accepts line break after closing pipe' do
      expect_no_offenses(<<~RUBY)
        {}.each do |x, y|
          puts x
        end
      RUBY
    end

    it 'registers an offense and corrects multiple spaces before parameter' do
      expect_offense(<<~RUBY)
        {}.each { |x,   y| puts x }
                     ^^ Extra space before block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { |x, y| puts x }
      RUBY
    end

    it 'registers an offense and corrects for space with parens' do
      expect_offense(<<~RUBY)
        {}.each { |a,  (x,  y),  z| puts x }
                     ^ Extra space before block parameter detected.
                          ^ Extra space before block parameter detected.
                               ^ Extra space before block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { |a, (x, y), z| puts x }
      RUBY
    end

    context 'trailing comma' do
      it 'registers an offense for space after the last comma' do
        expect_offense(<<~RUBY)
          {}.each { |x, | puts x }
                       ^ Space after last block parameter detected.
        RUBY

        expect_correction(<<~RUBY)
          {}.each { |x,| puts x }
        RUBY
      end

      it 'registers an offense for space before and after the last comma' do
        expect_offense(<<~RUBY)
          {}.each { |x , | puts x }
                        ^ Space after last block parameter detected.
        RUBY

        expect_correction(<<~RUBY)
          {}.each { |x ,| puts x }
        RUBY
      end
    end

    it 'registers an offense and corrects all types of spacing issues' do
      expect_offense(<<~RUBY)
        {}.each { |  x=5,  (y,*z) |puts x }
                                  ^ Space after closing `|` missing.
                                 ^ Space after last block parameter detected.
                         ^ Extra space before block parameter detected.
                   ^ Extra space before block parameter detected.
                   ^^ Space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { |x=5, (y,*z)| puts x }
      RUBY
    end

    it 'registers an offense and corrects all types of spacing issues for a lambda' do
      expect_offense(<<~RUBY)
        ->(  a,  b, c) { puts a }
               ^ Extra space before block parameter detected.
           ^ Extra space before block parameter detected.
           ^^ Space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        ->(a, b, c) { puts a }
      RUBY
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
      expect_offense(<<~RUBY)
        {}.each { |x | puts x }
                   ^ Space before first block parameter missing.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x | puts x }
      RUBY
    end

    it 'registers an offense and corrects no space after last parameter' do
      expect_offense(<<~RUBY)
        {}.each { | x, y| puts x }
                       ^ Space after last block parameter missing.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x, y | puts x }
      RUBY
    end

    it 'registers an offense and corrects extra space before first parameter' do
      expect_offense(<<~RUBY)
        {}.each { |  x | puts x }
                   ^ Extra space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x | puts x }
      RUBY
    end

    it 'registers an offense and corrects multiple spaces after last parameter' do
      expect_offense(<<~RUBY)
        {}.each { | x, y   | puts x }
                         ^^ Extra space after last block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x, y | puts x }
      RUBY
    end

    it 'registers an offense and corrects no space after closing pipe' do
      expect_offense(<<~RUBY)
        {}.each { | x, y |puts x }
                         ^ Space after closing `|` missing.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x, y | puts x }
      RUBY
    end

    it 'registers an offense and corrects a lambda for no space before first parameter' do
      expect_offense(<<~RUBY)
        ->(x ) { puts x }
           ^ Space before first block parameter missing.
      RUBY

      expect_correction(<<~RUBY)
        ->( x ) { puts x }
      RUBY
    end

    it 'registers an offense and corrects a lambda for no space after last parameter' do
      expect_offense(<<~RUBY)
        ->( x, y) { puts x }
               ^ Space after last block parameter missing.
      RUBY

      expect_correction(<<~RUBY)
        ->( x, y ) { puts x }
      RUBY
    end

    it 'registers an offense and corrects a lambda for extra space before first parameter' do
      expect_offense(<<~RUBY)
        ->(  x ) { puts x }
           ^ Extra space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        ->( x ) { puts x }
      RUBY
    end

    it 'registers an offense and corrects a lambda for multiple spaces after last parameter' do
      expect_offense(<<~RUBY)
        ->( x, y   ) { puts x }
                 ^^ Extra space after last block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        ->( x, y ) { puts x }
      RUBY
    end

    it 'accepts line break after closing pipe' do
      expect_no_offenses(<<~RUBY)
        {}.each do | x, y |
          puts x
        end
      RUBY
    end

    it 'registers an offense and corrects multiple spaces before parameter' do
      expect_offense(<<~RUBY)
        {}.each { | x,   y | puts x }
                      ^^ Extra space before block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x, y | puts x }
      RUBY
    end

    it 'registers an offense and corrects space with parens at middle' do
      expect_offense(<<~RUBY)
        {}.each { |(x,  y),  z| puts x }
                   ^^^^^^^ Space before first block parameter missing.
                      ^ Extra space before block parameter detected.
                           ^ Extra space before block parameter detected.
                             ^ Space after last block parameter missing.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | (x, y), z | puts x }
      RUBY
    end

    context 'trailing comma' do
      it 'accepts space after the last comma' do
        expect_no_offenses('{}.each { | x, | puts x }')
      end

      it 'accepts space both before and after the last comma' do
        expect_no_offenses('{}.each { | x , | puts x }')
      end

      it 'registers an offense and corrects no space after the last comma' do
        expect_offense(<<~RUBY)
          {}.each { | x,| puts x }
                      ^ Space after last block parameter missing.
        RUBY

        expect_correction(<<~RUBY, loop: false)
          {}.each { | x ,| puts x }
        RUBY
      end
    end

    it 'registers an offense and corrects block arguments inside Hash#each' do
      expect_offense(<<~RUBY)
        {}.each { |  x=5,  (y,*z)|puts x }
                                 ^ Space after closing `|` missing.
                           ^^^^^^ Space after last block parameter missing.
                         ^ Extra space before block parameter detected.
                   ^ Extra space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x=5, (y,*z) | puts x }
      RUBY
    end

    it 'registers an offense and corrects missing space ' \
       'before first argument and after last argument' do
      expect_offense(<<~RUBY)
        {}.each { |x, z| puts x }
                      ^ Space after last block parameter missing.
                   ^ Space before first block parameter missing.
      RUBY

      expect_correction(<<~RUBY)
        {}.each { | x, z | puts x }
      RUBY
    end

    it 'registers an offense and corrects spacing in lambda args' do
      expect_offense(<<~RUBY)
        ->(  x,  y) { puts x }
                 ^ Space after last block parameter missing.
               ^ Extra space before block parameter detected.
           ^ Extra space before first block parameter detected.
      RUBY

      expect_correction(<<~RUBY)
        ->( x, y ) { puts x }
      RUBY
    end
  end
end
