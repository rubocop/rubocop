# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceAroundOperators do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config
      .new(
        'Layout/AlignHash' => { 'EnforcedHashRocketStyle' => hash_style },
        'Layout/SpaceAroundOperators' => {
          'AllowForAlignment' => allow_for_alignment
        }
      )
  end
  let(:hash_style) { 'key' }
  let(:allow_for_alignment) { true }

  it 'accepts operator surrounded by tabs' do
    expect_no_offenses("a\t+\tb")
  end

  it 'accepts operator symbols' do
    expect_no_offenses('func(:-)')
  end

  it 'accepts ranges' do
    expect_no_offenses('a, b = (1..2), (1...3)')
  end

  it 'accepts scope operator' do
    expect_no_offenses('@io.class == Zlib::GzipWriter')
  end

  it 'accepts ::Kernel::raise' do
    expect_no_offenses('::Kernel::raise IllegalBlockError.new')
  end

  it 'accepts exclamation point negation' do
    expect_offense(<<-RUBY.strip_indent)
      x = !a&&!b
            ^^ Surrounding space missing for operator `&&`.
    RUBY
  end

  it 'accepts exclamation point definition' do
    expect_no_offenses(<<-RUBY.strip_indent)
      def !
        !__getobj__
      end
    RUBY
  end

  it 'accepts a unary' do
    expect_no_offenses(<<-RUBY.strip_indent)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      def +(other); end
      def self.===(other); end
    RUBY
  end

  it 'accepts an operator at the end of a line' do
    expect_no_offenses(<<-RUBY.strip_indent)
      ['Favor unless over if for negative ' +
       'conditions.'] * 2
    RUBY
  end

  it 'accepts an assignment with spaces' do
    expect_no_offenses('x = 0')
  end

  it 'accepts an assignment by `for` statement' do
    expect_no_offenses(<<-RUBY.strip_indent)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      x += a + b - c * d / e % f ^ g | h & i || j
      y -= k && l
    RUBY
  end

  it "accepts some operators that are exceptions & don't need spaces" do
    expect_no_offenses(<<-RUBY.strip_indent)
      (1..3)
      ActionController::Base
      each { |s, t| }
    RUBY
  end

  it 'accepts an assignment followed by newline' do
    expect_no_offenses(<<-RUBY.strip_indent)
      x =
      0
    RUBY
  end

  it 'accepts an operator at the beginning of a line' do
    expect_no_offenses(<<-'RUBY'.strip_indent)
      a = b \
          && c
    RUBY
  end

  it 'registers an offenses for exponent operator with spaces' do
    expect_offense(<<-RUBY.strip_indent)
      x = a * b ** 2
                ^^ Space around operator `**` detected.
    RUBY
  end

  it 'auto-corrects unwanted space around **' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      x = a * b ** 2
      y = a * b** 2
    RUBY
    expect(new_source).to eq(<<-RUBY.strip_indent)
      x = a * b**2
      y = a * b**2
    RUBY
  end

  it 'accepts exponent operator without spaces' do
    expect_no_offenses('x = a * b**2')
  end

  it 'accepts unary operators without space' do
    expect_no_offenses(<<-RUBY.strip_indent)
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
    expect_no_offenses(<<-RUBY.strip_indent)
      def init(name=nil)
      end
    RUBY
  end

  it 'accepts the construct class <<self with no space after <<' do
    expect_no_offenses(<<-RUBY.strip_indent)
      class <<self
      end
    RUBY
  end

  describe 'missing space around operators' do
    shared_examples 'modifier with missing space' do |keyword|
      it "registers an offense in presence of modifier #{keyword} statement" do
        src = <<-RUBY.strip_indent
          a=1 #{keyword} condition
          c=2
        RUBY
        inspect_source(src)
        expect(cop.offenses.map(&:line)).to eq([1, 2])
        expect(cop.messages).to eq(
          ['Surrounding space missing for operator `=`.'] * 2
        )

        new_source = autocorrect_source(src)
        expect(new_source).to eq(<<-RUBY.strip_indent)
          a = 1 #{keyword} condition
          c = 2
        RUBY
      end
    end

    it 'registers an offense for assignment without space on both sides' do
      expect_offense(<<-RUBY.strip_indent)
        x=0
         ^ Surrounding space missing for operator `=`.
        y+= 0
         ^^ Surrounding space missing for operator `+=`.
        z[0] =0
             ^ Surrounding space missing for operator `=`.
      RUBY
    end

    it 'auto-corrects assignment without space on both sides' do
      new_source = autocorrect_source(['x=0', 'y= 0', 'z =0'])
      expect(new_source).to eq(['x = 0', 'y = 0', 'z = 0'].join("\n"))
    end

    context 'ternary operators' do
      it 'registers an offense for operators with no spaces' do
        expect_offense(<<-RUBY.strip_indent)
          x == 0?1:2
                  ^ Surrounding space missing for operator `:`.
                ^ Surrounding space missing for operator `?`.
        RUBY
      end

      it 'registers an offense for operators with just a trailing space' do
        expect_offense(<<-RUBY.strip_indent)
          x == 0? 1: 2
                   ^ Surrounding space missing for operator `:`.
                ^ Surrounding space missing for operator `?`.
        RUBY
      end

      it 'registers an offense for operators with just a leading space' do
        expect_offense(<<-RUBY.strip_indent)
          x == 0 ?1 :2
                    ^ Surrounding space missing for operator `:`.
                 ^ Surrounding space missing for operator `?`.
        RUBY
      end

      it 'auto-corrects a ternary operator without space' do
        new_source = autocorrect_source('x == 0?1:2')
        expect(new_source).to eq('x == 0 ? 1 : 2')
      end
    end

    it_behaves_like 'modifier with missing space', 'if'
    it_behaves_like 'modifier with missing space', 'unless'
    it_behaves_like 'modifier with missing space', 'while'
    it_behaves_like 'modifier with missing space', 'until'

    it 'registers an offense for binary operators that could be unary' do
      expect_offense(<<-RUBY.strip_indent)
        a-3
         ^ Surrounding space missing for operator `-`.
        x&0xff
         ^ Surrounding space missing for operator `&`.
        z+0
         ^ Surrounding space missing for operator `+`.
      RUBY
    end

    it 'auto-corrects missing space in binary operators that could be unary' do
      new_source = autocorrect_source(['a-3', 'x&0xff', 'z+0'])
      expect(new_source).to eq(['a - 3', 'x & 0xff', 'z + 0'].join("\n"))
    end

    it 'registers an offense for arguments to a method' do
      expect_offense(<<-RUBY.strip_indent)
        puts 1+2
              ^ Surrounding space missing for operator `+`.
      RUBY
    end

    it 'auto-corrects missing space in arguments to a method' do
      new_source = autocorrect_source('puts 1+2')
      expect(new_source).to eq('puts 1 + 2')
    end

    it 'registers an offense for operators without spaces' do
      expect_offense(<<-RUBY.strip_indent)
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
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        x+= a+b-c*d/e%f^g|h&i||j
        y -=k&&l
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        x += a + b - c * d / e % f ^ g | h & i || j
        y -= k && l
      RUBY
    end

    it 'registers an offense for a setter call without spaces' do
      expect_offense(<<-RUBY.strip_indent)
        x.y=2
           ^ Surrounding space missing for operator `=`.
      RUBY
    end

    context 'when a hash literal is on a single line' do
      before { inspect_source('{ 1=>2, a: b }') }

      context 'and Layout/AlignHash:EnforcedHashRocketStyle is key' do
        let(:hash_style) { 'key' }

        it 'registers an offense for a hash rocket without spaces' do
          expect(cop.messages)
            .to eq(['Surrounding space missing for operator `=>`.'])
        end
      end

      context 'and Layout/AlignHash:EnforcedHashRocketStyle is table' do
        let(:hash_style) { 'table' }

        it 'registers an offense for a hash rocket without spaces' do
          expect(cop.messages)
            .to eq(['Surrounding space missing for operator `=>`.'])
        end
      end
    end

    context 'when a hash literal is on multiple lines' do
      before do
        inspect_source(<<-RUBY.strip_indent)
          {
            1=>2,
            a: b
          }
        RUBY
      end

      context 'and Layout/AlignHash:EnforcedHashRocketStyle is key' do
        let(:hash_style) { 'key' }

        it 'registers an offense for a hash rocket without spaces' do
          expect(cop.messages)
            .to eq(['Surrounding space missing for operator `=>`.'])
        end
      end

      context 'and Layout/AlignHash:EnforcedHashRocketStyle is table' do
        let(:hash_style) { 'table' }

        it "doesn't register an offense for a hash rocket without spaces" do
          expect_no_offenses(<<-RUBY.strip_indent)
            {
              1=>2,
              a: b
            }
          RUBY
        end
      end
    end

    it 'registers an offense for match operators without space' do
      expect_offense(<<-RUBY.strip_indent)
        x=~/abc/
         ^^ Surrounding space missing for operator `=~`.
        y !~/abc/
          ^^ Surrounding space missing for operator `!~`.
      RUBY
    end

    it 'registers an offense for various assignments without space' do
      expect_offense(<<-RUBY.strip_indent)
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
    end

    it 'registers an offense for equality operators without space' do
      expect_offense(<<-RUBY.strip_indent)
        x==0
         ^^ Surrounding space missing for operator `==`.
        y!=0
         ^^ Surrounding space missing for operator `!=`.
        Hash===z
            ^^^ Surrounding space missing for operator `===`.
      RUBY
    end

    it 'registers an offense for - without space with negative lhs operand' do
      expect_offense(<<-RUBY.strip_indent)
        -1-arg
          ^ Surrounding space missing for operator `-`.
      RUBY
    end

    it 'registers an offense for inheritance < without space' do
      expect_offense(<<-RUBY.strip_indent)
        class ShowSourceTestClass<ShowSourceTestSuperClass
                                 ^ Surrounding space missing for operator `<`.
        end
      RUBY
    end

    it 'registers an offense for hash rocket without space at rescue' do
      expect_offense(<<-RUBY.strip_indent)
        begin
        rescue Exception=>e
                        ^^ Surrounding space missing for operator `=>`.
        end
      RUBY
    end

    it "doesn't eat a newline when auto-correcting" do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        'Here is a'+
        'joined string'+
        'across three lines'
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        'Here is a' +
        'joined string' +
        'across three lines'
      RUBY
    end

    it "doesn't register an offense for operators with newline on right" do
      expect_no_offenses(<<-RUBY.strip_indent)
        'Here is a' +
        'joined string' +
        'across three lines'
      RUBY
    end
  end

  describe 'extra space around operators' do
    shared_examples 'modifier with extra space' do |keyword|
      it "registers an offense in presence of modifier #{keyword} statement" do
        src = <<-RUBY.strip_indent
          a =  1 #{keyword} condition
          c =   2
        RUBY
        inspect_source(src)
        expect(cop.offenses.map(&:line)).to eq([1, 2])
        expect(cop.messages).to eq(
          ['Operator `=` should be surrounded by a single space.'] * 2
        )

        new_source = autocorrect_source(src)
        expect(new_source).to eq(<<-RUBY.strip_indent)
          a = 1 #{keyword} condition
          c = 2
        RUBY
      end
    end

    it 'registers an offense for assignment with many spaces on either side' do
      expect_offense(<<-RUBY.strip_indent)
        x   = 0
            ^ Operator `=` should be surrounded by a single space.
        y +=   0
          ^^ Operator `+=` should be surrounded by a single space.
        z[0]  =  0
              ^ Operator `=` should be surrounded by a single space.
      RUBY
    end

    it 'auto-corrects assignment with too many spaces on either side' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        x  = 0
        y =   0
        z  =   0
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        x = 0
        y = 0
        z = 0
      RUBY
    end

    it 'registers an offense for ternary operator with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
        x == 0  ? 1 :  2
                    ^ Operator `:` should be surrounded by a single space.
                ^ Operator `?` should be surrounded by a single space.
      RUBY
    end

    it 'auto-corrects a ternary operator too many spaces' do
      new_source = autocorrect_source('x == 0  ? 1 :  2')
      expect(new_source).to eq('x == 0 ? 1 : 2')
    end

    it_behaves_like 'modifier with extra space', 'if'
    it_behaves_like 'modifier with extra space', 'unless'
    it_behaves_like 'modifier with extra space', 'while'
    it_behaves_like 'modifier with extra space', 'until'

    it 'registers an offense for binary operators that could be unary' do
      expect_offense(<<-RUBY.strip_indent)
        a -  3
          ^ Operator `-` should be surrounded by a single space.
        x &   0xff
          ^ Operator `&` should be surrounded by a single space.
        z +  0
          ^ Operator `+` should be surrounded by a single space.
      RUBY
    end

    it 'auto-corrects missing space in binary operators that could be unary' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        a -  3
        x &   0xff
        z +  0
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        a - 3
        x & 0xff
        z + 0
      RUBY
    end

    it 'registers an offense for arguments to a method' do
      expect_offense(<<-RUBY.strip_indent)
        puts 1 +  2
               ^ Operator `+` should be surrounded by a single space.
      RUBY
    end

    it 'auto-corrects missing space in arguments to a method' do
      new_source = autocorrect_source('puts 1 +  2')
      expect(new_source).to eq('puts 1 + 2')
    end

    it 'registers an offense for operators with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
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
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source(
        <<-RUBY.strip_indent
          x +=  a  + b -  c  * d /  e  % f  ^ g   | h &  i  ||  j
          y  -=  k   &&        l
        RUBY
      )
      expect(new_source).to eq(<<-RUBY.strip_indent)
        x += a + b - c * d / e % f ^ g | h & i || j
        y -= k && l
      RUBY
    end

    it 'registers an offense for a setter call with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
        x.y  =  2
             ^ Operator `=` should be surrounded by a single space.
      RUBY
    end

    it 'registers an offense for a hash rocket with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
        { 1  =>   2, a: b }
             ^^ Operator `=>` should be surrounded by a single space.
      RUBY
    end

    it 'registers an offense for a hash rocket with an extra space' \
      'on multiple line' do
      inspect_source(<<-RUBY.strip_indent)
        {
          1 =>  2
        }
      RUBY
      expect(cop.messages).to eq(
        ['Operator `=>` should be surrounded by a single space.']
      )
    end

    it 'accepts for a hash rocket with an extra space for alignment' \
      'on multiple line' do
      inspect_source(<<-RUBY.strip_indent)
        {
          1 =>  2,
          11 => 3
        }
      RUBY
      expect(cop.offenses.empty?).to be(true)
    end

    context 'when does not allowed for alignment' do
      let(:allow_for_alignment) { false }

      it 'accepts an extra space' do
        expect_offense(<<-RUBY.strip_indent)
          {
            1 =>  2,
              ^^ Operator `=>` should be surrounded by a single space.
            11 => 3
          }
        RUBY
      end
    end

    it 'registers an offense for match operators with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
        x  =~ /abc/
           ^^ Operator `=~` should be surrounded by a single space.
        y !~   /abc/
          ^^ Operator `!~` should be surrounded by a single space.
      RUBY
    end

    it 'registers an offense for various assignments with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
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
    end

    it 'registers an offense for equality operators with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
        x  ==  0
           ^^ Operator `==` should be surrounded by a single space.
        y   != 0
            ^^ Operator `!=` should be surrounded by a single space.
        Hash   ===   z
               ^^^ Operator `===` should be surrounded by a single space.
      RUBY
    end

    it 'registers an offense for - with too many spaces with ' \
       'negative lhs operand' do
      inspect_source('-1  - arg')
      expect(cop.messages)
        .to eq(['Operator `-` should be surrounded by a single space.'])
    end

    it 'registers an offense for inheritance < with too many spaces' do
      expect_offense(<<-RUBY.strip_indent)
        class Foo  <  Bar
                   ^ Operator `<` should be surrounded by a single space.
        end
      RUBY
    end

    it 'registers an offense for hash rocket with too many spaces at rescue' do
      expect_offense(<<-RUBY.strip_indent)
        begin
        rescue Exception   =>      e
                           ^^ Operator `=>` should be surrounded by a single space.
        end
      RUBY
    end
  end
end
