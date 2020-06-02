# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideArrayLiteralBrackets, :config do
  it 'does not register offense for any kind of reference brackets' do
    expect_no_offenses(<<~RUBY)
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

    it 'registers an offense and corrects empty brackets with 1 space inside' do
      expect_offense(<<~RUBY)
        a = [ ]
            ^^^ Do not use space inside empty array brackets.
      RUBY

      expect_correction(<<~RUBY)
        a = []
      RUBY
    end

    it 'registers an offense and corrects empty brackets ' \
      'with multiple spaces inside' do
      expect_offense(<<~RUBY)
        a = [     ]
            ^^^^^^^ Do not use space inside empty array brackets.
      RUBY

      expect_correction(<<~RUBY)
        a = []
      RUBY
    end

    it 'registers an offense and corrects multiline spaces' do
      expect_offense(<<~RUBY)
        a = [
            ^ Do not use space inside empty array brackets.
        ]
      RUBY

      expect_correction(<<~RUBY)
        a = []
      RUBY
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'space' } }

    it 'accepts empty brackets with space inside' do
      expect_no_offenses('a = [ ]')
    end

    it 'registers an offense and corrects empty brackets ' \
      'with no space inside' do
      expect_offense(<<~RUBY)
        a = []
            ^^ Use one space inside empty array brackets.
      RUBY

      expect_correction(<<~RUBY)
        a = [ ]
      RUBY
    end

    it 'registers an offense and corrects empty brackets ' \
      'with more than one space inside' do
      expect_offense(<<~RUBY)
        a = [      ]
            ^^^^^^^^ Use one space inside empty array brackets.
      RUBY

      expect_correction(<<~RUBY)
        a = [ ]
      RUBY
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'does not register offense for arrays with no spaces' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3]
        [foo, bar]
        ["qux", "baz"]
        [[1, 2], [3, 4]]
        [{ foo: 1 }, { bar: 2}]
      RUBY
    end

    it 'does not register offense for arrays using ref brackets' do
      expect_no_offenses(<<~RUBY)
        [1, 2, 3][0]
        [foo, bar][ 1]
        ["qux", "baz"][ -1 ]
        [[1, 2], [3, 4]][1 ]
        [{ foo: 1 }, { bar: 2}][0]
      RUBY
    end

    it 'does not register offense when 2 arrays on one line' do
      expect_no_offenses(<<~RUBY)
        [2,3,4] + [5,6,7]
      RUBY
    end

    it 'does not register offense for array when brackets get own line' do
      expect_no_offenses(<<~RUBY)
        stuff = [
          a,
          b
        ]
      RUBY
    end

    it 'does not register offense for indented array ' \
       'when bottom bracket gets its own line & is misaligned' do
      expect_no_offenses(<<~RUBY)
        def do_stuff
          a = [
            1, 2
            ]
        end
      RUBY
    end

    it 'does not register offense when bottom bracket gets its ' \
       'own line & has trailing method' do
      expect_no_offenses(<<~RUBY)
        a = [
          1, 2, nil
            ].compact
      RUBY
    end

    it 'does not register offense when bottom bracket gets its ' \
       'own line indented with tabs' do
      expect_no_offenses(<<~RUBY)
        a =
        \t[
        \t1, 2, nil
        \t].compact
      RUBY
    end

    it 'does not register offense for valid multiline array' do
      expect_no_offenses(<<~RUBY)
        ['Encoding:',
         '  Enabled: false']
      RUBY
    end

    it 'does not register offense for valid 2-dimensional array' do
      expect_no_offenses(<<~RUBY)
        [1, [2,3,4], [5,6,7]]
      RUBY
    end

    it 'accepts space inside array brackets if with comment' do
      expect_no_offenses(<<~RUBY)
        a = [ # Comment
             1, 2
            ]
      RUBY
    end

    it 'accepts square brackets as method name' do
      expect_no_offenses(<<~RUBY)
        def Vector.[](*array)
        end
      RUBY
    end

    it 'does not register offense when contains an array literal as ' \
       'an argument after a heredoc is started' do
      expect_no_offenses(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<-SQL, [self.class.to_s]).first["count"]
          SELECT COUNT(widgets.id) FROM widgets
          WHERE widget_type = $1
        SQL
      RUBY
    end

    it 'accepts square brackets called with method call syntax' do
      expect_no_offenses('subject.[](0)')
    end

    it 'registers an offense and corrects array brackets ' \
      'with leading whitespace' do
      expect_offense(<<~RUBY)
        [ 2, 3, 4]
         ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [2, 3, 4]
      RUBY
    end

    it 'registers an offense and corrects array brackets ' \
      'with trailing whitespace' do
      expect_offense(<<~RUBY)
        [b, c, d   ]
                ^^^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [b, c, d]
      RUBY
    end

    it 'registers an offense and corrects an array when two on one line' do
      expect_offense(<<~RUBY)
        ['qux', 'baz'  ] - ['baz']
                     ^^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        ['qux', 'baz'] - ['baz']
      RUBY
    end

    it 'registers an offense and corrects multiline array on end bracket' do
      expect_offense(<<~RUBY)
        ['ok',
         'still good',
         'not good' ]
                   ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        ['ok',
         'still good',
         'not good']
      RUBY
    end

    it 'registers an offense and corrects multiline array on end bracket' \
       'with trailing method' do
      expect_offense(<<~RUBY)
        [:good,
         :bad  ].compact
             ^^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [:good,
         :bad].compact
      RUBY
    end

    it 'registers an offense and corrects 2 arrays on one line' do
      expect_offense(<<~RUBY)
        [2,3,4] - [ 3,4]
                   ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [2,3,4] - [3,4]
      RUBY
    end

    it 'registers an offense and corrects an array literal as ' \
       'an argument with trailing whitespace after a heredoc is started' do
      expect_offense(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<-SQL, [self.class.to_s ]).first["count"]
                                                                      ^ Do not use space inside array brackets.
          SELECT COUNT(widgets.id) FROM widgets
          WHERE widget_type = $1
        SQL
      RUBY

      expect_correction(<<~RUBY)
        ActiveRecord::Base.connection.execute(<<-SQL, [self.class.to_s]).first["count"]
          SELECT COUNT(widgets.id) FROM widgets
          WHERE widget_type = $1
        SQL
      RUBY
    end

    it 'accepts a multiline array with whitespace before end bracket' do
      expect_no_offenses(<<~RUBY)
        stuff = [
          a,
          b
           ]
      RUBY
    end
  end

  shared_examples 'space inside arrays' do
    it 'does not register offense for arrays with spaces' do
      expect_no_offenses(<<~RUBY)
        [ 1, 2, 3 ]
        [ foo, bar ]
        [ "qux", "baz" ]
        [ { foo: 1 }, { bar: 2} ]
      RUBY
    end

    it 'does not register offense for arrays using ref brackets' do
      expect_no_offenses(<<~RUBY)
        [ 1, 2, 3 ][0]
        [ foo, bar ][ 1]
        [ "qux", "baz" ][ -1 ]
        [ { foo: 1 }, { bar: 2} ][0]
      RUBY
    end

    it 'does not register offense when 2 arrays on one line' do
      expect_no_offenses(<<~RUBY)
        [ 2,3,4 ] + [ 5,6,7 ]
      RUBY
    end

    it 'does not register offense for array when brackets get their own line' do
      expect_no_offenses(<<~RUBY)
        stuff = [
          a,
          b
        ]
      RUBY
    end

    it 'does not register offense for indented array ' \
       'when bottom bracket gets its own line & is misaligned' do
      expect_no_offenses(<<~RUBY)
        def do_stuff
          a = [
            1, 2
            ]
        end
      RUBY
    end

    it 'does not register offense when bottom bracket gets its ' \
       'own line & has trailing method' do
      expect_no_offenses(<<~RUBY)
        a = [
          1, 2, nil
            ].compact
      RUBY
    end

    it 'does not register offense for valid multiline array' do
      expect_no_offenses(<<~RUBY)
        [ 'Encoding:',
          'Enabled: false' ]
      RUBY
    end

    it 'accepts space inside array brackets with comment' do
      expect_no_offenses(<<~RUBY)
        a = [ # Comment
             1, 2
            ]
      RUBY
    end

    it 'accepts square brackets as method name' do
      expect_no_offenses(<<~RUBY)
        def Vector.[](*array)
        end
      RUBY
    end

    it 'accepts square brackets called with method call syntax' do
      expect_no_offenses('subject.[](0)')
    end

    it 'registers an offense and corrects array brackets ' \
      'with no leading whitespace' do
      expect_offense(<<~RUBY)
        [2, 3, 4 ]
        ^ Use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ 2, 3, 4 ]
      RUBY
    end

    it 'registers an offense and corrects array brackets ' \
      'with no trailing whitespace' do
      expect_offense(<<~RUBY)
        [ b, c, d]
                 ^ Use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ b, c, d ]
      RUBY
    end

    it 'registers an offense and corrects an array missing whitespace ' \
      'when there is more than one array on a line' do
      expect_offense(<<~RUBY)
        [ 'qux', 'baz'] - [ 'baz' ]
                      ^ Use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ 'qux', 'baz' ] - [ 'baz' ]
      RUBY
    end

    it 'registers an offense and corrects multiline array on end bracket' do
      expect_offense(<<~RUBY)
        [ 'ok',
          'still good',
          'not good']
                    ^ Use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ 'ok',
          'still good',
          'not good' ]
      RUBY
    end

    it 'registers an offense and corrects multiline array on end bracket' \
       'with trailing method' do
      expect_offense(<<~RUBY)
        [ :good,
          :bad].compact
              ^ Use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ :good,
          :bad ].compact
      RUBY
    end

    it 'register an offense and corrects when 2 arrays are on one line' do
      expect_offense(<<~RUBY)
        [ 2, 3, 4 ] - [3, 4 ]
                      ^ Use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ 2, 3, 4 ] - [ 3, 4 ]
      RUBY
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) { { 'EnforcedStyle' => 'space' } }

    it_behaves_like 'space inside arrays'

    it 'does not register offense for valid 2-dimensional array' do
      expect_no_offenses(<<~RUBY)
        [ 1, [ 2,3,4 ], [ 5,6,7 ] ]
      RUBY
    end
  end

  context 'when EnforcedStyle is compact' do
    let(:cop_config) { { 'EnforcedStyle' => 'compact' } }

    it_behaves_like 'space inside arrays'

    it 'does not register offense for valid 2-dimensional array' do
      expect_no_offenses(<<~RUBY)
        [ 1, [ 2,3,4 ], [ 5,6,7 ]]
      RUBY
    end

    it 'does not register offense for valid 3-dimensional array' do
      expect_no_offenses(<<~RUBY)
        [[ 2, 3, [ 4 ]]]
      RUBY
    end

    it 'does not register offense for valid 4-dimensional array' do
      expect_no_offenses(<<~RUBY)
        [[[[ boom ]]]]
      RUBY
    end

    it 'registers an offense and corrects space between 2 closing brackets' do
      expect_offense(<<~RUBY)
        [ 1, [ 2,3,4 ], [ 5,6,7 ] ]
                                 ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [ 1, [ 2,3,4 ], [ 5,6,7 ]]
      RUBY
    end

    it 'registers an offense and corrects space between 2 opening brackets' do
      expect_offense(<<~RUBY)
        [ [ 2,3,4 ], [ 5,6,7 ], 8 ]
         ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [[ 2,3,4 ], [ 5,6,7 ], 8 ]
      RUBY
    end

    it 'accepts multiline array' do
      expect_no_offenses(<<~RUBY)
        array = [[ a ],
          [ b, c ]]
      RUBY
    end

    context 'multiline array does not collapse successive right-brackets' do
      it 'registers an offense and corrects' do
        expect_offense(<<~RUBY)
          multiline = [[ 1, 2, 3, 4 ],
            [ 3, 4, 5, 6 ] ]
                          ^ Do not use space inside array brackets.
        RUBY

        expect_correction(<<~RUBY, loop: false)
          multiline = [ [ 1, 2, 3, 4 ],
            [ 3, 4, 5, 6 ]]
        RUBY
      end
    end

    it 'registers an offense and corrects 2-dimensional array ' \
      'with extra spaces' do
      expect_offense(<<~RUBY)
        [ [ a, b ], [ 1, 7 ] ]
                            ^ Do not use space inside array brackets.
         ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [[ a, b ], [ 1, 7 ]]
      RUBY
    end

    it 'registers an offense and corrects 3-dimensional array ' \
      'with extra spaces' do
      expect_offense(<<~RUBY)
        [ [a, b ], [foo, [bar, baz] ] ]
                                     ^ Do not use space inside array brackets.
                                   ^ Do not use space inside array brackets.
                                  ^ Use space inside array brackets.
                         ^ Use space inside array brackets.
                   ^ Use space inside array brackets.
          ^ Use space inside array brackets.
         ^ Do not use space inside array brackets.
      RUBY

      expect_correction(<<~RUBY)
        [[ a, b ], [ foo, [ bar, baz ]]]
      RUBY
    end

    context 'multiline array does not collapse successive left-brackets' do
      it 'registers an offense' do
        # In this example, we cannot use `expect_offense` because the offense
        # has no highlight (actually, a zero-width `column_range`) so our caret
        # would not match.
        inspect_source(<<~RUBY)
          multiline = [
            [ 1, 2, 3, 4 ],
            [ 3, 4, 5, 6 ]]
        RUBY

        expect(cop.offenses.size).to eq(1)
        offense = cop.offenses.first
        expect(offense.line).to eq(1)
        expect(offense.column_range).to eq(13...13) # thus, can't expect_offense
        expect(offense.message).to eq('Do not use space inside array brackets.')
      end

      it 'auto-corrects' do
        new_source = autocorrect_source(<<~RUBY)
          multiline = [
            [ 1, 2, 3, 4 ],
            [ 3, 4, 5, 6 ]]
        RUBY

        expect(new_source).to eq(<<~RUBY)
          multiline = [
            [ 1, 2, 3, 4 ],
            [ 3, 4, 5, 6 ] ]
        RUBY
      end
    end

    context 'multiline array does not collapse any successive brackets' do
      it 'registers an offense' do
        # In this example, we cannot use `expect_offense` because the offense
        # has no highlight (actually, a zero-width `column_range`) so our caret
        # would not match.
        inspect_source(<<~RUBY)
          array = [
            [ a ],
            [ b, c ]
          ]
        RUBY

        expect(cop.offenses.size).to eq(1)
        offense = cop.offenses.first
        expect(offense.line).to eq(1)
        expect(offense.column_range).to eq(9...9) # thus, can't expect_offense
        expect(offense.message).to eq('Do not use space inside array brackets.')
      end

      it 'does not auto-corrects' do
        source = <<~RUBY
          array = [
            [ a ],
            [ b, c ]
          ]
        RUBY

        new_source = autocorrect_source(source)

        expect(new_source).to eq(source)
      end
    end
  end
end
