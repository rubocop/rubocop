# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideReferenceBrackets, :config do
  context 'with space inside empty brackets not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'no_space' } }

    it 'accepts empty brackets with no space inside' do
      expect_no_offenses('a[]')
    end

    it 'registers an offense and corrects empty brackets with 1 space inside' do
      expect_offense(<<~RUBY)
        foo[ ]
           ^^^ Do not use space inside empty reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        foo[]
      RUBY
    end

    it 'registers an offense and corrects empty brackets with multiple spaces inside' do
      expect_offense(<<~RUBY)
        a[     ]
         ^^^^^^^ Do not use space inside empty reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[]
      RUBY
    end

    it 'registers an offense and corrects empty brackets with newline inside' do
      expect_offense(<<~RUBY)
        a[
         ^ Do not use space inside empty reference brackets.
        ]
      RUBY

      expect_correction(<<~RUBY)
        a[]
      RUBY
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'space' } }

    it 'accepts empty brackets with space inside' do
      expect_no_offenses('a[ ]')
    end

    it 'registers offense and corrects empty brackets with no space inside' do
      expect_offense(<<~RUBY)
        foo[]
           ^^ Use one space inside empty reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        foo[ ]
      RUBY
    end

    it 'registers offense and corrects empty brackets with more than one space inside' do
      expect_offense(<<~RUBY)
        a[      ]
         ^^^^^^^^ Use one space inside empty reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ ]
      RUBY
    end

    it 'registers offense and corrects empty brackets with newline inside' do
      expect_offense(<<~RUBY)
        a[
         ^ Use one space inside empty reference brackets.
        ]
      RUBY

      expect_correction(<<~RUBY)
        a[ ]
      RUBY
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'does not register offense for array literals' do
      expect_no_offenses(<<~RUBY)
        a = [1, 2 ]
        b = [ 3, 4]
        c = [5, 6]
        d = [ 7, 8 ]
      RUBY
    end

    it 'does not register offense for reference brackets with no spaces' do
      expect_no_offenses(<<~RUBY)
        a[1]
        b[index, 2]
        c["foo"]
        d[:bar]
        e[]
      RUBY
    end

    it 'does not register offense for ref bcts with no spaces that assign' do
      expect_no_offenses(<<~RUBY)
        a[1] = 2
        b[345] = [ 678, var, "", nil]
        c["foo"] = "qux"
        d[:bar] = var
        e[] = foo
      RUBY
    end

    it 'does not register offense for non-empty brackets with newline inside' do
      expect_no_offenses(<<-RUBY)
        foo[
          bar
        ]
      RUBY
    end

    it 'registers an offense and corrects when a reference bracket with a ' \
       'leading whitespace is assigned by another reference bracket' do
      expect_offense(<<~RUBY)
        a[ "foo"] = b["something"]
          ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a["foo"] = b["something"]
      RUBY
    end

    it 'registers an offense and corrects when a reference bracket with a ' \
       'trailing whitespace is assigned by another reference bracket' do
      expect_offense(<<~RUBY)
        a["foo" ] = b["something"]
               ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a["foo"] = b["something"]
      RUBY
    end

    it 'registers an offense and corrects when a reference bracket is ' \
       'assigned by another reference bracket with trailing whitespace' do
      expect_offense(<<~RUBY)
        a["foo"] = b["something" ]
                                ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a["foo"] = b["something"]
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

    it 'accepts an array as a reference object' do
      expect_no_offenses('a[[ 1, 2 ]]')
    end

    it 'registers an offense and corrects ref brackets with leading whitespace' do
      expect_offense(<<~RUBY)
        a[  :key]
          ^^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[:key]
      RUBY
    end

    it 'registers an offense and corrects ref brackets with trailing whitespace' do
      expect_offense(<<~RUBY)
        b[:key ]
              ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        b[:key]
      RUBY
    end

    it 'registers an offense and corrects second ref brackets with leading whitespace' do
      expect_offense(<<~RUBY)
        a[:key][ "key"]
                ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[:key]["key"]
      RUBY
    end

    it 'registers an offense and corrects second ref brackets with trailing whitespace' do
      expect_offense(<<~RUBY)
        a[1][:key   ]
                 ^^^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[1][:key]
      RUBY
    end

    it 'registers an offense and corrects third ref brackets with leading whitespace' do
      expect_offense(<<~RUBY)
        a[:key][3][ :key]
                   ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[:key][3][:key]
      RUBY
    end

    it 'registers an offense and corrects third ref brackets with trailing whitespace' do
      expect_offense(<<~RUBY)
        a[var]["key", 3][:key ]
                             ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[var]["key", 3][:key]
      RUBY
    end

    it 'registers multiple offenses and corrects one set of ref brackets' do
      expect_offense(<<~RUBY)
        b[ 89  ]
          ^ Do not use space inside reference brackets.
             ^^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        b[89]
      RUBY
    end

    it 'registers multiple offenses and corrects multiple sets of ref brackets' do
      expect_offense(<<~RUBY)
        a[ :key]["foo"  ][   0 ]
          ^ Do not use space inside reference brackets.
                      ^^ Do not use space inside reference brackets.
                          ^^^ Do not use space inside reference brackets.
                              ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[:key]["foo"][0]
      RUBY
    end

    it 'registers an offense and corrects outer ref brackets' do
      expect_offense(<<~RUBY)
        record[ options[:attribute] ]
               ^ Do not use space inside reference brackets.
                                   ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        record[options[:attribute]]
      RUBY
    end

    it 'register and correct multiple offenses for multiple sets of ref brackets' do
      expect_offense(<<~RUBY)
        b[ :key]["foo"  ][   0 ]
          ^ Do not use space inside reference brackets.
                      ^^ Do not use space inside reference brackets.
                          ^^^ Do not use space inside reference brackets.
                              ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        b[:key]["foo"][0]
      RUBY
    end

    it 'accepts extra spacing in array brackets' do
      expect_offense(<<~RUBY)
        j[ "pop"] = [89, nil, ""    ]
          ^ Do not use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        j["pop"] = [89, nil, ""    ]
      RUBY
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'space',
        'EnforcedStyleForEmptyBrackets' => 'space' }
    end

    it 'does not register offense for array literals' do
      expect_no_offenses(<<~RUBY)
        a = [1, 2 ]
        b = [ 3, 4]
        c = [5, 6]
        d = [ 7, 8 ]
      RUBY
    end

    it 'does not register offense for reference brackets with spaces' do
      expect_no_offenses(<<~RUBY)
        a[ 1 ]
        b[ index, 3 ]
        c[ "foo" ]
        d[ :bar ]
        e[ ]
      RUBY
    end

    it 'does not register offense for ref bcts with spaces that assign' do
      expect_no_offenses(<<~RUBY)
        a[ 1 ] = 2
        b[ 345 ] = [ 678, var, "", nil]
        c[ "foo" ] = "qux"
        d[ :bar ] = var
        e[ ] = baz
      RUBY
    end

    it 'registers an offense and corrects when a reference bracket with no ' \
       'leading whitespace is assigned by another reference bracket' do
      expect_offense(<<~RUBY)
        a["foo" ] = b[ "something" ]
         ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ "foo" ] = b[ "something" ]
      RUBY
    end

    it 'registers an offense and corrects when a reference bracket with no ' \
       'trailing whitespace is assigned by another reference bracket' do
      expect_offense(<<~RUBY)
        a[ "foo"] = b[ "something" ]
                ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ "foo" ] = b[ "something" ]
      RUBY
    end

    it 'registers an offense and corrects when a reference bracket is ' \
       'assigned by another reference bracket with no trailing whitespace' do
      expect_offense(<<~RUBY)
        a[ "foo" ] = b[ "something"]
                                   ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ "foo" ] = b[ "something" ]
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

    it 'accepts an array as a reference object' do
      expect_no_offenses('a[ [1, 2] ]')
    end

    it 'registers an offense and corrects ref brackets with no leading whitespace' do
      expect_offense(<<~RUBY)
        a[:key ]
         ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ :key ]
      RUBY
    end

    it 'registers an offense and corrects ref brackets with no trailing whitespace' do
      expect_offense(<<~RUBY)
        b[ :key]
               ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        b[ :key ]
      RUBY
    end

    it 'registers an offense and corrects second ref brackets with no leading whitespace' do
      expect_offense(<<~RUBY)
        a[ :key ]["key" ]
                 ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ :key ][ "key" ]
      RUBY
    end

    it 'registers an offense and corrects second ref brackets with no trailing whitespace' do
      expect_offense(<<~RUBY)
        a[ 5, 1 ][ :key]
                       ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ 5, 1 ][ :key ]
      RUBY
    end

    it 'registers an offense and corrects third ref brackets with no leading whitespace' do
      expect_offense(<<~RUBY)
        a[ :key ][ 3 ][:key ]
                      ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ :key ][ 3 ][ :key ]
      RUBY
    end

    it 'registers an offense and correct third ref brackets with no trailing whitespace' do
      expect_offense(<<~RUBY)
        a[ var ][ "key" ][ :key]
                               ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ var ][ "key" ][ :key ]
      RUBY
    end

    it 'registers and corrects multiple offenses in one set of ref brackets' do
      expect_offense(<<~RUBY)
        b[89]
         ^ Use space inside reference brackets.
            ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        b[ 89 ]
      RUBY
    end

    it 'registers and corrects multiple offenses for multiple sets of ref brackets' do
      expect_offense(<<~RUBY)
        a[:key]["foo" ][0]
         ^ Use space inside reference brackets.
              ^ Use space inside reference brackets.
               ^ Use space inside reference brackets.
                       ^ Use space inside reference brackets.
                         ^ Use space inside reference brackets.
      RUBY

      expect_correction(<<~RUBY)
        a[ :key ][ "foo" ][ 0 ]
      RUBY
    end

    it 'accepts spaces in array brackets' do
      expect_no_offenses(<<~RUBY)
        j = [89, nil, ""    ]
      RUBY
    end
  end
end
