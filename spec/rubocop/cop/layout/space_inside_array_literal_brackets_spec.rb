# frozen_string_literal: true

describe RuboCop::Cop::Layout::SpaceInsideArrayLiteralBrackets, :config do
  subject(:cop) { described_class.new(config) }

  it 'does not register offense for any kind of reference brackets' do
    expect_no_offenses(<<-RUBY.strip_indent)
      a[1]
      b[ 3]
      c[ foo ]
      d[index, 2]
    RUBY
  end

  context 'with space inside empty brackets not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'no_space' } }

    it 'accepts empty brackets with no space inside' do
      expect_no_offenses('a = []')
    end

    it 'registers an offense for empty brackets with one space inside' do
      expect_offense(<<-RUBY.strip_indent)
        a = [ ]
            ^^^ Do not use space inside empty array brackets.
      RUBY
    end

    it 'registers an offense for empty brackets with lots of space inside' do
      expect_offense(<<-RUBY.strip_indent)
        a = [     ]
            ^^^^^^^ Do not use space inside empty array brackets.
      RUBY
    end

    it 'auto-corrects an unwanted single space' do
      new_source = autocorrect_source('a = [ ]')
      expect(new_source).to eq('a = []')
    end

    it 'auto-corrects multiple unwanted spaces' do
      new_source = autocorrect_source('a = [           ]')
      expect(new_source).to eq('a = []')
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'space' } }

    it 'accepts empty brackets with space inside' do
      expect_no_offenses('a = [ ]')
    end

    it 'registers offense for empty brackets with no space inside' do
      expect_offense(<<-RUBY.strip_indent)
        a = []
            ^^ Use one space inside empty array brackets.
      RUBY
    end

    it 'registers offense for empty brackets with more than one space inside' do
      expect_offense(<<-RUBY.strip_indent)
        a = [      ]
            ^^^^^^^^ Use one space inside empty array brackets.
      RUBY
    end

    it 'auto-corrects missing space' do
      new_source = autocorrect_source('a = []')
      expect(new_source).to eq('a = [ ]')
    end

    it 'auto-corrects too many spaces' do
      new_source = autocorrect_source('a = [      ]')
      expect(new_source).to eq('a = [ ]')
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'does not register offense for arrays with no spaces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [1, 2, 3]
        [foo, bar]
        ["qux", "baz"]
        [[1, 2], [3, 4]]
        [{ foo: 1 }, { bar: 2}]
      RUBY
    end

    it 'does not register offense for arrays using ref brackets' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [1, 2, 3][0]
        [foo, bar][ 1]
        ["qux", "baz"][ -1 ]
        [[1, 2], [3, 4]][1 ]
        [{ foo: 1 }, { bar: 2}][0]
      RUBY
    end

    it 'does not register offense when 2 arrays on one line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [2,3,4] + [5,6,7]
      RUBY
    end

    it 'does not register offense for array when brackets get own line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        stuff = [
          a,
          b
        ]
      RUBY
    end

    it 'does not register offense for indented array ' \
       'when bottom bracket gets its own line & is misaligned' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def do_stuff
          a = [
            1, 2
            ]
        end
      RUBY
    end

    it 'does not register offense when bottom bracket gets its ' \
       'own line & has trailing method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
          1, 2, nil
            ].compact
      RUBY
    end

    it 'does not register offense for valid multiline array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        ['Encoding:',
         '  Enabled: false']
      RUBY
    end

    it 'does not register offense for valid 2-dimensional array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [1, [2,3,4], [5,6,7]]
      RUBY
    end

    it 'accepts space inside array brackets if with comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [ # Comment
             1, 2
            ]
      RUBY
    end

    it 'accepts square brackets as method name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def Vector.[](*array)
        end
      RUBY
    end

    it 'accepts square brackets called with method call syntax' do
      expect_no_offenses('subject.[](0)')
    end

    it 'registers offense in array brackets with leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        [ 2, 3, 4]
         ^ Do not use space inside array brackets.
      RUBY
    end

    it 'registers offense in array brackets with trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        [b, c, d   ]
                ^^^ Do not use space inside array brackets.
      RUBY
    end

    it 'registers offense in correct array when two on one line' do
      expect_offense(<<-RUBY.strip_indent)
        ['qux', 'baz'  ] - ['baz']
                     ^^ Do not use space inside array brackets.
      RUBY
    end

    it 'registers offense in multiline array on end bracket' do
      expect_offense(<<-RUBY.strip_indent)
        ['ok',
         'still good',
         'not good' ]
                   ^ Do not use space inside array brackets.
      RUBY
    end

    it 'registers offense in multiline array on end bracket' \
       'with trailing method' do
      expect_offense(<<-RUBY.strip_indent)
        [:good,
         :bad  ].compact
             ^^ Do not use space inside array brackets.
      RUBY
    end

    it 'register offense when 2 arrays on one line' do
      expect_offense(<<-RUBY.strip_indent)
        [2,3,4] - [ 3,4]
                   ^ Do not use space inside array brackets.
      RUBY
    end

    context 'auto-corrects' do
      it 'fixes multiple offenses in one set of array brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [ 89, 90, 91 ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [89, 90, 91]
        RUBY
      end

      it 'fixes multiple offenses in two sets of array brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [ 89, 90, 91] + [ 1, 7, 9]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [89, 90, 91] + [1, 7, 9]
        RUBY
      end

      it 'fixes multiline offenses but does not fuss with alignment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [ :foo,
            :bar,
            nil   ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [:foo,
            :bar,
            nil]
        RUBY
      end

      it 'fixes multiline offenses with trailing method' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [   a,
              b,
              c   ].compact
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [a,
              b,
              c].compact
        RUBY
      end

      it 'ignores multiline array with whitespace before end bracket' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          stuff = [
            a,
            b
             ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          stuff = [
            a,
            b
             ]
        RUBY
      end
    end
  end

  shared_examples 'space inside arrays' do
    it 'does not register offense for arrays with spaces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [ 1, 2, 3 ]
        [ foo, bar ]
        [ "qux", "baz" ]
        [ { foo: 1 }, { bar: 2} ]
      RUBY
    end

    it 'does not register offense for arrays using ref brackets' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [ 1, 2, 3 ][0]
        [ foo, bar ][ 1]
        [ "qux", "baz" ][ -1 ]
        [ { foo: 1 }, { bar: 2} ][0]
      RUBY
    end

    it 'does not register offense when 2 arrays on one line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [ 2,3,4 ] + [ 5,6,7 ]
      RUBY
    end

    it 'does not register offense for array when brackets get their own line' do
      expect_no_offenses(<<-RUBY.strip_indent)
        stuff = [
          a,
          b
        ]
      RUBY
    end

    it 'does not register offense for indented array ' \
       'when bottom bracket gets its own line & is misaligned' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def do_stuff
          a = [
            1, 2
            ]
        end
      RUBY
    end

    it 'does not register offense when bottom bracket gets its ' \
       'own line & has trailing method' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [
          1, 2, nil
            ].compact
      RUBY
    end

    it 'does not register offense for valid multiline array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [ 'Encoding:',
          'Enabled: false' ]
      RUBY
    end

    it 'accepts space inside array brackets with comment' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [ # Comment
             1, 2
            ]
      RUBY
    end

    it 'accepts square brackets as method name' do
      expect_no_offenses(<<-RUBY.strip_indent)
        def Vector.[](*array)
        end
      RUBY
    end

    it 'accepts square brackets called with method call syntax' do
      expect_no_offenses('subject.[](0)')
    end

    it 'registers offense in array brackets with no leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        [2, 3, 4 ]
        ^ Use space inside array brackets.
      RUBY
    end

    it 'registers offense in array brackets with no trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        [ b, c, d]
                 ^ Use space inside array brackets.
      RUBY
    end

    it 'registers offense in correct array when two on one line' do
      expect_offense(<<-RUBY.strip_indent)
        [ 'qux', 'baz'] - [ 'baz' ]
                      ^ Use space inside array brackets.
      RUBY
    end

    it 'registers offense in multiline array on end bracket' do
      expect_offense(<<-RUBY.strip_indent)
        [ 'ok',
          'still good',
          'not good']
                    ^ Use space inside array brackets.
      RUBY
    end

    it 'registers offense in multiline array on end bracket' \
       'with trailing method' do
      expect_offense(<<-RUBY.strip_indent)
        [ :good,
          :bad].compact
              ^ Use space inside array brackets.
      RUBY
    end

    it 'register offense when 2 arrays on one line' do
      expect_offense(<<-RUBY.strip_indent)
        [ 2, 3, 4 ] - [3, 4 ]
                      ^ Use space inside array brackets.
      RUBY
    end

    context 'auto-corrects' do
      it 'fixes multiple offenses in one set of array brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [89, 90, 91]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [ 89, 90, 91 ]
        RUBY
      end

      it 'fixes multiple offenses in two sets of array brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [ 89, 90, 91] + [ 1, 7, 9]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [ 89, 90, 91 ] + [ 1, 7, 9 ]
        RUBY
      end

      it 'fixes multiline offenses but does not fuss with alignment' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [:foo,
           :bar,
           nil]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [ :foo,
           :bar,
           nil ]
        RUBY
      end

      it 'fixes multiline offenses with trailing method' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [a,
           b,
           c].compact
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [ a,
           b,
           c ].compact
        RUBY
      end

      it 'ignores multiline array with no whitespace before end bracket' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          stuff = [
            a,
            b
          ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          stuff = [
            a,
            b
          ]
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it_behaves_like 'space inside arrays'

    it 'does not register offense for valid 2-dimensional array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [ 1, [ 2,3,4 ], [ 5,6,7 ] ]
      RUBY
    end
  end

  context 'when EnforcedStyle is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it_behaves_like 'space inside arrays'

    it 'does not register offense for valid 2-dimensional array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [ 1, [ 2,3,4 ], [ 5,6,7 ]]
      RUBY
    end

    it 'does not register offense for valid 3-dimensional array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [[ 2, 3, [ 4 ]]]
      RUBY
    end

    it 'does not register offense for valid 4-dimensional array' do
      expect_no_offenses(<<-RUBY.strip_indent)
        [[[[ boom ]]]]
      RUBY
    end

    it 'registers offense if space between 2 closing brackets' do
      expect_offense(<<-RUBY.strip_indent)
        [ 1, [ 2,3,4 ], [ 5,6,7 ] ]
                                 ^ Do not use space inside array brackets.
      RUBY
    end

    it 'registers offense if space between 2 opening brackets' do
      expect_offense(<<-RUBY.strip_indent)
        [ [ 2,3,4 ], [ 5,6,7 ], 8 ]
         ^ Do not use space inside array brackets.
      RUBY
    end

    context 'auto-corrects' do
      it 'fixes 2-dimensional array with extra spaces' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [ [ a, b ], [ 1, 7 ] ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [[ a, b ], [ 1, 7 ]]
        RUBY
      end

      it 'fixes offensive 3-dimensional array' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          [ [a, b ], [foo, [bar, baz] ] ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          [[ a, b ], [ foo, [ bar, baz ]]]
        RUBY
      end

      it 'ignores multi-dimensional multiline array with no ' \
         'whitespace before end bracket' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          stuff = [
            a,
            [ b, c ]
            ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          stuff = [
            a,
            [ b, c ]
            ]
        RUBY
      end
    end
  end
end
