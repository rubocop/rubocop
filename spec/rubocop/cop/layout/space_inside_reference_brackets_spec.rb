# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Layout::SpaceInsideReferenceBrackets, :config do
  subject(:cop) { described_class.new(config) }

  context 'with space inside empty brackets not allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'no_space' } }

    it 'accepts empty brackets with no space inside' do
      expect_no_offenses('a[]')
    end

    it 'registers an offense for empty brackets with one space inside' do
      expect_offense(<<-RUBY.strip_indent)
        foo[ ]
           ^^^ Do not use space inside empty reference brackets.
      RUBY
    end

    it 'registers an offense for empty brackets with lots of space inside' do
      expect_offense(<<-RUBY.strip_indent)
        a[     ]
         ^^^^^^^ Do not use space inside empty reference brackets.
      RUBY
    end

    it 'auto-corrects whitespaces in empty brackets' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        a[ ]
        a[    ]
        a[ ] = foo
        a[   ] = bar
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        a[]
        a[]
        a[] = foo
        a[] = bar
      RUBY
    end
  end

  context 'with space inside empty braces allowed' do
    let(:cop_config) { { 'EnforcedStyleForEmptyBrackets' => 'space' } }

    it 'accepts empty brackets with space inside' do
      expect_no_offenses('a[ ]')
    end

    it 'registers offense for empty brackets with no space inside' do
      expect_offense(<<-RUBY.strip_indent)
        foo[]
           ^^ Use one space inside empty reference brackets.
      RUBY
    end

    it 'registers offense for empty brackets with more than one space inside' do
      expect_offense(<<-RUBY.strip_indent)
        a[      ]
         ^^^^^^^^ Use one space inside empty reference brackets.
      RUBY
    end

    it 'auto-corrects multiple offenses for empty brackets' do
      new_source = autocorrect_source(<<-RUBY.strip_indent)
        a[]
        a[    ]
        a[] = foo
        a[   ] = bar
      RUBY
      expect(new_source).to eq(<<-RUBY.strip_indent)
        a[ ]
        a[ ]
        a[ ] = foo
        a[ ] = bar
      RUBY
    end
  end

  context 'when EnforcedStyle is no_space' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_space' } }

    it 'does not register offense for array literals' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [1, 2 ]
        b = [ 3, 4]
        c = [5, 6]
        d = [ 7, 8 ]
      RUBY
    end

    it 'does not register offense for reference brackets with no spaces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a[1]
        b[index, 2]
        c["foo"]
        d[:bar]
        e[]
      RUBY
    end

    it 'does not register offense for ref bcts with no spaces that assign' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a[1] = 2
        b[345] = [ 678, var, "", nil]
        c["foo"] = "qux"
        d[:bar] = var
        e[] = foo
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

    it 'accepts an array as a reference object' do
      expect_no_offenses('a[[ 1, 2 ]]')
    end

    it 'registers offense in ref brackets with leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[  :key]
          ^^ Do not use space inside reference brackets.
      RUBY
    end

    it 'registers offense in ref brackets with trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        b[:key ]
              ^ Do not use space inside reference brackets.
      RUBY
    end

    it 'registers offense in second ref brackets with leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[:key][ "key"]
                ^ Do not use space inside reference brackets.
      RUBY
    end

    it 'registers offense in second ref brackets with trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[1][:key   ]
                 ^^^ Do not use space inside reference brackets.
      RUBY
    end

    it 'registers offense in third ref brackets with leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[:key][3][ :key]
                   ^ Do not use space inside reference brackets.
      RUBY
    end

    it 'registers offense in third ref brackets with trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[var]["key", 3][:key ]
                             ^ Do not use space inside reference brackets.
      RUBY
    end

    it 'registers multiple offenses in one set of ref brackets' do
      inspect_source(<<-RUBY.strip_indent)
        b[ 89  ]
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages.uniq)
        .to eq(['Do not use space inside reference brackets.'])
    end

    it 'registers multiple offenses for multiple sets of ref brackets' do
      inspect_source(<<-RUBY.strip_indent)
        a[ :key]["foo"  ][   0 ]
      RUBY
      expect(cop.offenses.size).to eq(4)
      expect(cop.messages.uniq)
        .to eq(['Do not use space inside reference brackets.'])
    end

    context 'auto-correct' do
      it 'fixes multiple offenses in one set of ref brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          bar[ 89  ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          bar[89]
        RUBY
      end

      it 'fixes multiple offenses for multiple sets of ref brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          b[ :key]["foo"  ][   0 ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          b[:key]["foo"][0]
        RUBY
      end

      it 'avoids altering array brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          j[ "pop"] = [89, nil, ""    ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          j["pop"] = [89, nil, ""    ]
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is space' do
    let(:cop_config) do
      { 'EnforcedStyle' => 'space',
        'EnforcedStyleForEmptyBrackets' => 'space' }
    end

    it 'does not register offense for array literals' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a = [1, 2 ]
        b = [ 3, 4]
        c = [5, 6]
        d = [ 7, 8 ]
      RUBY
    end

    it 'does not register offense for reference brackets with spaces' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a[ 1 ]
        b[ index, 3 ]
        c[ "foo" ]
        d[ :bar ]
        e[ ]
      RUBY
    end

    it 'does not register offense for ref bcts with spaces that assign' do
      expect_no_offenses(<<-RUBY.strip_indent)
        a[ 1 ] = 2
        b[ 345 ] = [ 678, var, "", nil]
        c[ "foo" ] = "qux"
        d[ :bar ] = var
        e[ ] = baz
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

    it 'accepts an array as a reference object' do
      expect_no_offenses('a[ [1, 2] ]')
    end

    it 'registers offense in ref brackets with no leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[:key ]
         ^ Use space inside reference brackets.
      RUBY
    end

    it 'registers offense in ref brackets with no trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        b[ :key]
               ^ Use space inside reference brackets.
      RUBY
    end

    it 'registers offense in second ref brackets with no leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[ :key ]["key" ]
                 ^ Use space inside reference brackets.
      RUBY
    end

    it 'registers offense in second ref brackets with no trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[ 5, 1 ][ :key]
                       ^ Use space inside reference brackets.
      RUBY
    end

    it 'registers offense in third ref brackets with no leading whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[ :key ][ 3 ][:key ]
                      ^ Use space inside reference brackets.
      RUBY
    end

    it 'registers offense in third ref brackets with no trailing whitespace' do
      expect_offense(<<-RUBY.strip_indent)
        a[ var ][ "key" ][ :key]
                               ^ Use space inside reference brackets.
      RUBY
    end

    it 'registers multiple offenses in one set of ref brackets' do
      inspect_source(<<-RUBY.strip_indent)
        b[89]
      RUBY
      expect(cop.offenses.size).to eq(2)
      expect(cop.messages.uniq)
        .to eq(['Use space inside reference brackets.'])
    end

    it 'registers multiple offenses for multiple sets of ref brackets' do
      inspect_source(<<-RUBY.strip_indent)
        a[:key]["foo" ][0]
      RUBY
      expect(cop.offenses.size).to eq(5)
      expect(cop.messages.uniq)
        .to eq(['Use space inside reference brackets.'])
    end

    context 'auto-correct' do
      it 'fixes multiple offenses in one set of ref brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          bar[89]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          bar[ 89 ]
        RUBY
      end

      it 'fixes multiple offenses for multiple sets of ref brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          b[:key][ "foo"][0 ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          b[ :key ][ "foo" ][ 0 ]
        RUBY
      end

      it 'avoids altering array brackets' do
        new_source = autocorrect_source(<<-RUBY.strip_indent)
          j[ "pop"] = [89, nil, ""    ]
        RUBY
        expect(new_source).to eq(<<-RUBY.strip_indent)
          j[ "pop" ] = [89, nil, ""    ]
        RUBY
      end
    end
  end
end
