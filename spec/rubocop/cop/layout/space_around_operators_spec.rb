# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceAroundOperators, :config do
  let(:config) do
    RuboCop::Config
      .new(
        'AllCops' => { 'TargetRubyVersion' => target_ruby_version },
        'Layout/HashAlignment' => { 'EnforcedHashRocketStyle' => hash_style },
        'Layout/SpaceAroundOperators' => {
          'AllowForAlignment' => allow_for_alignment,
          'EnforcedStyleForExponentOperator' => exponent_operator_style
        },
        'Layout/ExtraSpacing' => {
          'Enabled' => force_equal_sign_alignment,
          'ForceEqualSignAlignment' => force_equal_sign_alignment
        }
      )
  end
  let(:target_ruby_version) { 2.5 }
  let(:hash_style) { 'key' }
  let(:allow_for_alignment) { true }
  let(:exponent_operator_style) { nil }
  let(:force_equal_sign_alignment) { false }

  it 'accepts operator surrounded by tabs' do
    expect_no_offenses("a\t+\tb")
  end

  it 'accepts operator symbols' do
    expect_no_offenses('func(:-)')
  end

  it 'accepts ranges' do
    expect_no_offenses('a, b = (1..2), (1...3)')
  end

  it 'accepts rational' do
    expect_no_offenses('x = 2/3r')
  end

  it 'accepts scope operator' do
    expect_no_offenses('@io.class == Zlib::GzipWriter')
  end

  it 'accepts ::Kernel::raise' do
    expect_no_offenses('::Kernel::raise IllegalBlockError.new')
  end

  it 'registers an offense and corrects exclamation point negation' do
    expect_offense(<<~RUBY)
      x = !a&&!b
            ^^ Surrounding space missing for operator `&&`.
    RUBY

    expect_correction(<<~RUBY)
      x = !a && !b
    RUBY
  end

  it 'accepts exclamation point definition' do
    expect_no_offenses(<<~RUBY)
      def !
        !__getobj__
      end
    RUBY
  end

  it 'accepts the result of the ExtraSpacing Cop' do
    expect_no_offenses(<<~RUBY)
      def batch
        @areas   = params[:param].map do
                     var_1      = 123_456
                     variable_2 = 456_123
                   end
        @another = params[:param].map do
                     char_1 = begin
                                variable_1_1  = 'a'
                                variable_1_20 = 'b'

                                variable_1_300  = 'c'
                                # A Comment
                                variable_1_4000 = 'd'

                                variable_1_50000           = 'e'
                                puts 'a non-assignment statement without a blank line'
                                some_other_length_variable = 'f'
                              end
                     var_2  = 456_123
                   end

        render json: @areas
      end
    RUBY
  end

  it 'accepts a unary' do
    expect_no_offenses(<<~RUBY)
      def bm(label_width = 0, *labels, &blk)
        benchmark(CAPTION, label_width, FORMAT,
                  *labels, &blk)
      end

      def each &block
        +11
      end

      def self.search *args
      end

      def each *args
      end
    RUBY
  end

  it 'accepts splat operator' do
    expect_no_offenses('return *list if options')
  end

  it 'accepts def of operator' do
    expect_no_offenses(<<~RUBY)
      def +(other); end
      def self.===(other); end
    RUBY
  end

  it 'accepts an operator at the end of a line' do
    expect_no_offenses(<<~RUBY)
      ['Favor unless over if for negative ' +
       'conditions.'] * 2
    RUBY
  end

  it 'accepts an assignment with spaces' do
    expect_no_offenses('x = 0')
  end

  it 'accepts an assignment with the same alignment margins' do
    expect_no_offenses(<<~RUBY)
      @integer_message = 12345
      @output  = StringIO.new
      @logger  = Logger.new(@output)
    RUBY
  end

  it 'accepts an assignment with a blank line' do
    expect_no_offenses(<<~RUBY)
      expected = posts(:welcome)

      tagging  = Tagging.all.merge!(includes: :taggable).find(taggings(:welcome_general).id)
      assert_no_queries { assert_equal expected, tagging.taggable }
    RUBY
  end

  it 'accepts an assignment by `for` statement' do
    expect_no_offenses(<<~RUBY)
      for a in [] do; end
      for A in [] do; end
      for @a in [] do; end
      for @@a in [] do; end
    RUBY
  end

  it 'accepts an operator called with method syntax' do
    expect_no_offenses('Date.today.+(1).to_s')
  end

  it 'accepts operators with spaces' do
    expect_no_offenses(<<~RUBY)
      x += a + b - c * d / e % f ^ g | h & i || j
      y -= k && l
    RUBY
  end

  it "accepts some operators that are exceptions & don't need spaces" do
    expect_no_offenses(<<~RUBY)
      (1..3)
      ActionController::Base
      each { |s, t| }
    RUBY
  end

  it 'accepts an assignment followed by newline' do
    expect_no_offenses(<<~RUBY)
      x =
      0
    RUBY
  end

  it 'accepts an operator at the beginning of a line' do
    expect_no_offenses(<<~'RUBY')
      a = b \
          && c
    RUBY
  end

  it 'registers an offenses for exponent operator with spaces' do
    expect_offense(<<~RUBY)
      x = a * b ** 2
                ^^ Space around operator `**` detected.
      y = a * b** 2
               ^^ Space around operator `**` detected.
    RUBY

    expect_correction(<<~RUBY)
      x = a * b**2
      y = a * b**2
    RUBY
  end

  it 'accepts exponent operator without spaces' do
    expect_no_offenses('x = a * b**2')
  end

  context '>= Ruby 2.7', :ruby27 do
    let(:target_ruby_version) { 2.7 }

    # NOTE: It is `Layout/SpaceAroundKeyword` cop's role to detect this offense.
    it 'does not register an offenses for one-line pattern matching syntax (`in`)' do
      expect_no_offenses(<<~RUBY)
        ""in foo
      RUBY
    end
  end

  context '>= Ruby 3.0', :ruby30 do
    let(:target_ruby_version) { 3.0 }

    it 'registers an offenses for one-line pattern matching syntax (`=>`)' do
      expect_offense(<<~RUBY)
        ""=>foo
          ^^ Surrounding space missing for operator `=>`.
      RUBY

      expect_correction(<<~RUBY)
        "" => foo
      RUBY
    end
  end

  context 'when EnforcedStyleForExponentOperator is space' do
    let(:exponent_operator_style) { 'space' }

    it 'registers an offenses for exponent operator without spaces' do
      expect_offense(<<~RUBY)
        x = a * b**2
                 ^^ Surrounding space missing for operator `**`.
      RUBY

      expect_correction(<<~RUBY)
        x = a * b ** 2
      RUBY
    end
  end

  it 'accepts unary operators without space' do
    expect_no_offenses(<<~RUBY)
      [].map(&:size)
      a.(b)
      -3
      arr.collect { |e| -e }
      x = +2
    RUBY
  end

  it 'accepts [arg] without space' do
    expect_no_offenses('files[2]')
  end

  it 'accepts [] without space' do
    expect_no_offenses('files[]')
  end

  it 'accepts []= without space' do
    expect_no_offenses('files[:key], files[:another] = method')
  end

  it 'accepts argument default values without space' do
    # These are handled by SpaceAroundEqualsInParameterDefault,
    # so SpaceAroundOperators leaves them alone.
    expect_no_offenses(<<~RUBY)
      def init(name=nil)
      end
    RUBY
  end

  it 'registers an offense and corrects singleton class operator`' do
    expect_offense(<<~RUBY)
      class<<self
           ^^ Surrounding space missing for operator `<<`.
      end
    RUBY

    expect_correction(<<~RUBY)
      class << self
      end
    RUBY
  end

  describe 'missing space around operators' do
    shared_examples 'modifier with missing space' do |keyword|
      it "registers an offense in presence of modifier #{keyword} statement" do
        expect_offense(<<~RUBY)
          a=1 #{keyword} condition
           ^ Surrounding space missing for operator `=`.
          c=2
           ^ Surrounding space missing for operator `=`.
        RUBY

        expect_correction(<<~RUBY)
          a = 1 #{keyword} condition
          c = 2
        RUBY
      end
    end

    it 'registers an offense for assignment without space on both sides' do
      expect_offense(<<~RUBY)
        x=0
         ^ Surrounding space missing for operator `=`.
        y+= 0
         ^^ Surrounding space missing for operator `+=`.
        z[0] =0
             ^ Surrounding space missing for operator `=`.
      RUBY

      expect_correction(<<~RUBY)
        x = 0
        y += 0
        z[0] = 0
      RUBY
    end

    context 'ternary operators' do
      it 'registers an offense and corrects operators with no spaces' do
        expect_offense(<<~RUBY)
          x == 0?1:2
                  ^ Surrounding space missing for operator `:`.
                ^ Surrounding space missing for operator `?`.
        RUBY

        expect_correction(<<~RUBY)
          x == 0 ? 1 : 2
        RUBY
      end

      it 'registers an offense and corrects operators with just a trailing space' do
        expect_offense(<<~RUBY)
          x == 0? 1: 2
                   ^ Surrounding space missing for operator `:`.
                ^ Surrounding space missing for operator `?`.
        RUBY

        expect_correction(<<~RUBY)
          x == 0 ? 1 : 2
        RUBY
      end

      it 'registers an offense and corrects operators with just a leading space' do
        expect_offense(<<~RUBY)
          x == 0 ?1 :2
                    ^ Surrounding space missing for operator `:`.
                 ^ Surrounding space missing for operator `?`.
        RUBY

        expect_correction(<<~RUBY)
          x == 0 ? 1 : 2
        RUBY
      end
    end

    it_behaves_like 'modifier with missing space', 'if'
    it_behaves_like 'modifier with missing space', 'unless'
    it_behaves_like 'modifier with missing space', 'while'
    it_behaves_like 'modifier with missing space', 'until'

    it 'registers an offense for binary operators that could be unary' do
      expect_offense(<<~RUBY)
        a-3
         ^ Surrounding space missing for operator `-`.
        x&0xff
         ^ Surrounding space missing for operator `&`.
        z+0
         ^ Surrounding space missing for operator `+`.
      RUBY

      expect_correction(<<~RUBY)
        a - 3
        x & 0xff
        z + 0
      RUBY
    end

    it 'registers an offense and corrects arguments to a method' do
      expect_offense(<<~RUBY)
        puts 1+2
              ^ Surrounding space missing for operator `+`.
      RUBY

      expect_correction(<<~RUBY)
        puts 1 + 2
      RUBY
    end

    it 'registers an offense for operators without spaces' do
      expect_offense(<<~RUBY)
        x+= a+b-c*d/e%f^g|h&i||j
         ^^ Surrounding space missing for operator `+=`.
             ^ Surrounding space missing for operator `+`.
               ^ Surrounding space missing for operator `-`.
                 ^ Surrounding space missing for operator `*`.
                   ^ Surrounding space missing for operator `/`.
                     ^ Surrounding space missing for operator `%`.
                       ^ Surrounding space missing for operator `^`.
                         ^ Surrounding space missing for operator `|`.
                           ^ Surrounding space missing for operator `&`.
                             ^^ Surrounding space missing for operator `||`.
        y -=k&&l
          ^^ Surrounding space missing for operator `-=`.
             ^^ Surrounding space missing for operator `&&`.
      RUBY

      expect_correction(<<~RUBY)
        x += a + b - c * d / e % f ^ g | h & i || j
        y -= k && l
      RUBY
    end

    it 'registers an offense and corrects a setter call without spaces' do
      expect_offense(<<~RUBY)
        x.y=2
           ^ Surrounding space missing for operator `=`.
      RUBY

      expect_correction(<<~RUBY)
        x.y = 2
      RUBY
    end

    context 'when a hash literal is on a single line' do
      context 'and Layout/HashAlignment:EnforcedHashRocketStyle is key' do
        let(:hash_style) { 'key' }

        it 'registers an offense and corrects a hash rocket without spaces' do
          expect_offense(<<~RUBY)
            { 1=>2, a: b }
               ^^ Surrounding space missing for operator `=>`.
          RUBY

          expect_correction(<<~RUBY)
            { 1 => 2, a: b }
          RUBY
        end
      end

      context 'and Layout/HashAlignment:EnforcedHashRocketStyle is table' do
        let(:hash_style) { 'table' }

        it 'registers an offense and corrects a hash rocket without spaces' do
          expect_offense(<<~RUBY)
            { 1=>2, a: b }
               ^^ Surrounding space missing for operator `=>`.
          RUBY

          expect_correction(<<~RUBY)
            { 1 => 2, a: b }
          RUBY
        end
      end
    end

    context 'when a hash literal is on multiple lines' do
      context 'and Layout/HashAlignment:EnforcedHashRocketStyle is key' do
        let(:hash_style) { 'key' }

        it 'registers an offense and corrects a hash rocket without spaces' do
          expect_offense(<<~RUBY)
            {
              1=>2,
               ^^ Surrounding space missing for operator `=>`.
              a: b
            }
          RUBY

          expect_correction(<<~RUBY)
            {
              1 => 2,
              a: b
            }
          RUBY
        end
      end

      context 'and Layout/HashAlignment:EnforcedHashRocketStyle is table' do
        let(:hash_style) { 'table' }

        it "doesn't register an offense for a hash rocket without spaces" do
          expect_no_offenses(<<~RUBY)
            {
              1=>2,
              a: b
            }
          RUBY
        end
      end
    end

    it 'registers an offense and corrects match operators without space' do
      expect_offense(<<~RUBY)
        x=~/abc/
         ^^ Surrounding space missing for operator `=~`.
        y !~/abc/
          ^^ Surrounding space missing for operator `!~`.
      RUBY

      expect_correction(<<~RUBY)
        x =~ /abc/
        y !~ /abc/
      RUBY
    end

    it 'registers an offense and corrects various assignments without space' do
      expect_offense(<<~RUBY)
        x||=0
         ^^^ Surrounding space missing for operator `||=`.
        y&&=0
         ^^^ Surrounding space missing for operator `&&=`.
        z*=2
         ^^ Surrounding space missing for operator `*=`.
        @a=0
          ^ Surrounding space missing for operator `=`.
        @@a=0
           ^ Surrounding space missing for operator `=`.
        a,b=0
           ^ Surrounding space missing for operator `=`.
        A=0
         ^ Surrounding space missing for operator `=`.
        x[3]=0
            ^ Surrounding space missing for operator `=`.
        $A=0
          ^ Surrounding space missing for operator `=`.
        A||=0
         ^^^ Surrounding space missing for operator `||=`.
      RUBY

      expect_correction(<<~RUBY)
        x ||= 0
        y &&= 0
        z *= 2
        @a = 0
        @@a = 0
        a,b = 0
        A = 0
        x[3] = 0
        $A = 0
        A ||= 0
      RUBY
    end

    it 'registers an offense and corrects equality operators without space' do
      expect_offense(<<~RUBY)
        x==0
         ^^ Surrounding space missing for operator `==`.
        y!=0
         ^^ Surrounding space missing for operator `!=`.
        Hash===z
            ^^^ Surrounding space missing for operator `===`.
      RUBY

      expect_correction(<<~RUBY)
        x == 0
        y != 0
        Hash === z
      RUBY
    end

    it 'registers an offense and corrects `-` without space with a negative lhs operand' do
      expect_offense(<<~RUBY)
        -1-arg
          ^ Surrounding space missing for operator `-`.
      RUBY

      expect_correction(<<~RUBY)
        -1 - arg
      RUBY
    end

    it 'registers an offense and corrects inheritance < without space' do
      expect_offense(<<~RUBY)
        class ShowSourceTestClass<ShowSourceTestSuperClass
                                 ^ Surrounding space missing for operator `<`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class ShowSourceTestClass < ShowSourceTestSuperClass
        end
      RUBY
    end

    it 'registers an offense and corrects hash rocket without space at rescue' do
      expect_offense(<<~RUBY)
        begin
        rescue Exception=>e
                        ^^ Surrounding space missing for operator `=>`.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
        rescue Exception => e
        end
      RUBY
    end

    it 'registers an offense and corrects string concatenation without messing up new lines' do
      expect_offense(<<~RUBY)
        'Here is a'+
                   ^ Surrounding space missing for operator `+`.
        'joined string'+
                       ^ Surrounding space missing for operator `+`.
        'across three lines'
      RUBY

      expect_correction(<<~RUBY)
        'Here is a' +
        'joined string' +
        'across three lines'
      RUBY
    end

    it "doesn't register an offense for operators with newline on right" do
      expect_no_offenses(<<~RUBY)
        'Here is a' +
        'joined string' +
        'across three lines'
      RUBY
    end
  end

  describe 'extra space around operators' do
    shared_examples 'modifier with extra space' do |keyword|
      it "registers an offense in presence of modifier #{keyword} statement" do
        expect_offense(<<~RUBY)
          a =  1 #{keyword} condition
            ^ Operator `=` should be surrounded by a single space.
          c =   2
            ^ Operator `=` should be surrounded by a single space.
        RUBY

        expect_correction(<<~RUBY)
          a = 1 #{keyword} condition
          c = 2
        RUBY
      end
    end

    it 'registers an offense and corrects assignment with too many spaces on either side' do
      expect_offense(<<~RUBY)
        x   = 0
            ^ Operator `=` should be surrounded by a single space.
        y +=   0
          ^^ Operator `+=` should be surrounded by a single space.
        z[0]  =  0
              ^ Operator `=` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x = 0
        y += 0
        z[0] = 0
      RUBY
    end

    it 'registers an offense and corrects ternary operator with too many spaces' do
      expect_offense(<<~RUBY)
        x == 0  ? 1 :  2
                    ^ Operator `:` should be surrounded by a single space.
                ^ Operator `?` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x == 0 ? 1 : 2
      RUBY
    end

    it_behaves_like 'modifier with extra space', 'if'
    it_behaves_like 'modifier with extra space', 'unless'
    it_behaves_like 'modifier with extra space', 'while'
    it_behaves_like 'modifier with extra space', 'until'

    it 'registers an offense and corrects binary operators that could be unary' do
      expect_offense(<<~RUBY)
        a -  3
          ^ Operator `-` should be surrounded by a single space.
        x &   0xff
          ^ Operator `&` should be surrounded by a single space.
        z +  0
          ^ Operator `+` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        a - 3
        x & 0xff
        z + 0
      RUBY
    end

    it 'registers an offense and corrects arguments to a method' do
      expect_offense(<<~RUBY)
        puts 1 +  2
               ^ Operator `+` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        puts 1 + 2
      RUBY
    end

    it 'registers an offense and corrects operators with too many spaces' do
      expect_offense(<<~RUBY)
        x +=  a
          ^^ Operator `+=` should be surrounded by a single space.
        a  + b
           ^ Operator `+` should be surrounded by a single space.
        b  -  c
           ^ Operator `-` should be surrounded by a single space.
        c  * d
           ^ Operator `*` should be surrounded by a single space.
        d  /  e
           ^ Operator `/` should be surrounded by a single space.
        e  % f
           ^ Operator `%` should be surrounded by a single space.
        f  ^ g
           ^ Operator `^` should be surrounded by a single space.
        g  | h
           ^ Operator `|` should be surrounded by a single space.
        h  &  i
           ^ Operator `&` should be surrounded by a single space.
        i  ||  j
           ^^ Operator `||` should be surrounded by a single space.
        y  -=  k   &&        l
           ^^ Operator `-=` should be surrounded by a single space.
                   ^^ Operator `&&` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x += a
        a + b
        b - c
        c * d
        d / e
        e % f
        f ^ g
        g | h
        h & i
        i || j
        y -= k && l
      RUBY
    end

    it 'registers an offense and corrects operators with too many spaces on the same line' do
      expect_offense(<<~RUBY)
        x +=  a  + b -  c  * d /  e  % f  ^ g   | h &  i  ||  j
                                                          ^^ Operator `||` should be surrounded by a single space.
                                                    ^ Operator `&` should be surrounded by a single space.
                                                ^ Operator `|` should be surrounded by a single space.
                                          ^ Operator `^` should be surrounded by a single space.
                                     ^ Operator `%` should be surrounded by a single space.
                               ^ Operator `/` should be surrounded by a single space.
                           ^ Operator `*` should be surrounded by a single space.
                     ^ Operator `-` should be surrounded by a single space.
                 ^ Operator `+` should be surrounded by a single space.
          ^^ Operator `+=` should be surrounded by a single space.
        y  -=  k   &&        l
                   ^^ Operator `&&` should be surrounded by a single space.
           ^^ Operator `-=` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x += a + b - c * d / e % f ^ g | h & i || j
        y -= k && l
      RUBY
    end

    it 'registers an offense and corrects a setter call with too many spaces' do
      expect_offense(<<~RUBY)
        x.y  =  2
             ^ Operator `=` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x.y = 2
      RUBY
    end

    it 'registers an offense and corrects a hash rocket with too many spaces' do
      expect_offense(<<~RUBY)
        { 1  =>   2, a: b }
             ^^ Operator `=>` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        { 1 => 2, a: b }
      RUBY
    end

    it 'registers an offense and corrects a hash rocket with an extra space on multiple line' do
      expect_offense(<<~RUBY)
        {
          1 =>  2
            ^^ Operator `=>` should be surrounded by a single space.
        }
      RUBY

      expect_correction(<<~RUBY)
        {
          1 => 2
        }
      RUBY
    end

    it 'accepts for a hash rocket with an extra space for alignment on multiple line' do
      expect_no_offenses(<<~RUBY)
        {
          1 =>  2,
          11 => 3
        }
      RUBY
    end

    context 'when does not allowed for alignment' do
      let(:allow_for_alignment) { false }

      it 'registers an offense and corrects an extra space' do
        expect_offense(<<~RUBY)
          {
            1 =>  2,
              ^^ Operator `=>` should be surrounded by a single space.
            11 => 3
          }
        RUBY

        expect_correction(<<~RUBY)
          {
            1 => 2,
            11 => 3
          }
        RUBY
      end
    end

    it 'registers an offense and corrects match operators with too many spaces' do
      expect_offense(<<~RUBY)
        x  =~ /abc/
           ^^ Operator `=~` should be surrounded by a single space.
        y !~   /abc/
          ^^ Operator `!~` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x =~ /abc/
        y !~ /abc/
      RUBY
    end

    it 'does not register an offenses match operators between `<<` and `+=`' do
      expect_no_offenses(<<~RUBY)
        x  << foo
        yz += bar
      RUBY
    end

    it 'does not register an offenses match operators between `+=` and `<<`' do
      expect_no_offenses(<<~RUBY)
        x  += foo
        yz << bar
      RUBY
    end

    it 'registers an offense and corrects various assignments with too many spaces' do
      expect_offense(<<~RUBY)
        x ||=  0
          ^^^ Operator `||=` should be surrounded by a single space.
        y  &&=  0
           ^^^ Operator `&&=` should be surrounded by a single space.
        z  *=   2
           ^^ Operator `*=` should be surrounded by a single space.
        @a   = 0
             ^ Operator `=` should be surrounded by a single space.
        @@a   = 0
              ^ Operator `=` should be surrounded by a single space.
        a,b    =   0
               ^ Operator `=` should be surrounded by a single space.
        A  = 0
           ^ Operator `=` should be surrounded by a single space.
        x[3]   = 0
               ^ Operator `=` should be surrounded by a single space.
        $A    =   0
              ^ Operator `=` should be surrounded by a single space.
        A  ||=  0
           ^^^ Operator `||=` should be surrounded by a single space.
        A  +=    0
           ^^ Operator `+=` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x ||= 0
        y &&= 0
        z *= 2
        @a = 0
        @@a = 0
        a,b = 0
        A = 0
        x[3] = 0
        $A = 0
        A ||= 0
        A += 0
      RUBY
    end

    it 'registers an offense and corrects equality operators with too many spaces' do
      expect_offense(<<~RUBY)
        x  ==  0
           ^^ Operator `==` should be surrounded by a single space.
        y   != 0
            ^^ Operator `!=` should be surrounded by a single space.
        Hash   ===   z
               ^^^ Operator `===` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        x == 0
        y != 0
        Hash === z
      RUBY
    end

    it 'registers an offense and corrects `-` with too many spaces with negative lhs operand' do
      expect_offense(<<~RUBY)
        -1  - arg
            ^ Operator `-` should be surrounded by a single space.
      RUBY

      expect_correction(<<~RUBY)
        -1 - arg
      RUBY
    end

    it 'registers an offense and corrects inheritance < with too many spaces' do
      expect_offense(<<~RUBY)
        class Foo  <  Bar
                   ^ Operator `<` should be surrounded by a single space.
        end
      RUBY

      expect_correction(<<~RUBY)
        class Foo < Bar
        end
      RUBY
    end

    it 'registers an offense and corrects hash rocket with too many spaces at rescue' do
      expect_offense(<<~RUBY)
        begin
        rescue Exception   =>      e
                           ^^ Operator `=>` should be surrounded by a single space.
        end
      RUBY

      expect_correction(<<~RUBY)
        begin
        rescue Exception => e
        end
      RUBY
    end
  end

  describe 'when Layout/ExtraSpacing has `ForceEqualSignAlignment` configured to true' do
    let(:force_equal_sign_alignment) { true }

    it 'allows variables to be aligned' do
      expect_no_offenses(<<~RUBY)
        first  = {
          x: y
        }.freeze
        second = true
      RUBY
    end

    it 'allows constants to be aligned' do
      expect_no_offenses(<<~RUBY)
        FIRST  = {
          x: y
        }.freeze
        SECOND = true
      RUBY
    end
  end
end
