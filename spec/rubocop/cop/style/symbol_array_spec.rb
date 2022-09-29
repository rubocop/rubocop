# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::SymbolArray, :config do
  before do
    # Reset data which is shared by all instances of SymbolArray
    described_class.largest_brackets = -Float::INFINITY
  end

  let(:other_cops) do
    {
      'Style/PercentLiteralDelimiters' => {
        'PreferredDelimiters' => {
          'default' => '()'
        }
      }
    }
  end

  context 'when EnforcedStyle is percent' do
    let(:cop_config) { { 'MinSize' => 0, 'EnforcedStyle' => 'percent' } }

    it 'registers an offense for arrays of symbols' do
      expect_offense(<<~RUBY)
        [:one, :two, :three]
        ^^^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
      RUBY

      expect_correction(<<~RUBY)
        %i(one two three)
      RUBY
    end

    it 'autocorrects arrays of one symbol' do
      expect_offense(<<~RUBY)
        [:one]
        ^^^^^^ Use `%i` or `%I` for an array of symbols.
      RUBY

      expect_correction(<<~RUBY)
        %i(one)
      RUBY
    end

    it 'autocorrects arrays of symbols with embedded newlines and tabs' do
      expect_offense(<<~RUBY, tab: "\t")
        [:"%{tab}", :"two
        ^^^^{tab}^^^^^^^^ Use `%i` or `%I` for an array of symbols.
        ", :three]
      RUBY

      expect_correction(<<~'RUBY')
        %I(\t two\n three)
      RUBY
    end

    it 'autocorrects arrays of symbols with new line' do
      expect_offense(<<~RUBY)
        [:one,
        ^^^^^^ Use `%i` or `%I` for an array of symbols.
        :two, :three,
        :four]
      RUBY

      expect_correction(<<~RUBY)
        %i(one
        two three
        four)
      RUBY
    end

    it 'uses %I when appropriate' do
      expect_offense(<<~'RUBY')
        [:"\t", :"\n", :three]
        ^^^^^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
      RUBY

      expect_correction(<<~'RUBY')
        %I(\t \n three)
      RUBY
    end

    it "doesn't break when a symbol contains )" do
      expect_offense(<<~RUBY)
        [:one, :")", :three, :"(", :"]", :"["]
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
      RUBY

      expect_correction(<<~'RUBY')
        %i(one \) three \( ] [)
      RUBY
    end

    it 'does not register an offense for array with non-syms' do
      expect_no_offenses('[:one, :two, "three"]')
    end

    it 'does not register an offense for array starting with %i' do
      expect_no_offenses('%i(one two three)')
    end

    it 'does not register an offense if symbol contains whitespace' do
      expect_no_offenses('[:one, :two, :"space here"]')
    end

    it 'registers an offense in a non-ambiguous block context' do
      expect_offense(<<~RUBY)
        foo([:bar, :baz]) { qux }
            ^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
      RUBY

      expect_correction(<<~RUBY)
        foo(%i(bar baz)) { qux }
      RUBY
    end

    it 'detects right value for MinSize to use for --auto-gen-config' do
      expect_offense(<<~RUBY)
        [:one, :two, :three]
        ^^^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
        %i(a b c d)
      RUBY

      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'percent', 'MinSize' => 4)
    end

    it 'detects when the cop must be disabled to avoid offenses' do
      expect_offense(<<~RUBY)
        [:one, :two, :three]
        ^^^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
        %i(a b)
      RUBY

      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    context 'when PreferredDelimiters is specified' do
      let(:other_cops) do
        {
          'Style/PercentLiteralDelimiters' => {
            'PreferredDelimiters' => {
              'default' => '[]'
            }
          }
        }
      end

      it 'autocorrects an array with delimiters' do
        expect_offense(<<~RUBY)
          [:one, :")", :three, :"(", :"]", :"["]
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
        RUBY

        expect_correction(<<~'RUBY')
          %i[one ) three ( \] \[]
        RUBY
      end

      it 'autocorrects an array in multiple lines' do
        expect_offense(<<-RUBY)
          [
          ^ Use `%i` or `%I` for an array of symbols.
          :foo,
          :bar,
          :baz
          ]
        RUBY

        expect_correction(<<-RUBY)
          %i[
          foo
          bar
          baz
          ]
        RUBY
      end

      it 'autocorrects an array using partial newlines' do
        expect_offense(<<-RUBY)
          [:foo, :bar, :baz,
          ^^^^^^^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
          :boz, :buz,
          :biz]
        RUBY

        expect_correction(<<-RUBY)
          %i[foo bar baz
          boz buz
          biz]
        RUBY
      end
    end
  end

  context 'when EnforcedStyle is brackets' do
    let(:cop_config) { { 'EnforcedStyle' => 'brackets', 'MinSize' => 0 } }

    it 'does not register an offense for arrays of symbols' do
      expect_no_offenses('[:one, :two, :three]')
    end

    it 'registers an offense for array starting with %i' do
      expect_offense(<<~RUBY)
        %i(one two three)
        ^^^^^^^^^^^^^^^^^ Use `[:one, :two, :three]` for an array of symbols.
      RUBY

      expect_correction(<<~RUBY)
        [:one, :two, :three]
      RUBY
    end

    it 'registers an offense for empty array starting with %i' do
      expect_offense(<<~RUBY)
        %i()
        ^^^^ Use `[]` for an array of symbols.
      RUBY

      expect_correction(<<~RUBY)
        []
      RUBY
    end

    it 'autocorrects an array starting with %i' do
      expect_offense(<<~RUBY)
        %i(one @two $three four-five)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[:one, :@two, :$three, :'four-five']` for an array of symbols.
      RUBY

      expect_correction(<<~RUBY)
        [:one, :@two, :$three, :'four-five']
      RUBY
    end

    it 'autocorrects multiline %i array' do
      expect_offense(<<~RUBY)
        %i(
        ^^^ Use an array literal `[...]` for an array of symbols.
          one
          two
          three
        )
      RUBY

      expect_correction(<<~RUBY)
        [
          :one,
          :two,
          :three
        ]
      RUBY
    end

    it 'autocorrects an array has interpolations' do
      expect_offense(<<~'RUBY')
        %I(#{foo} #{foo}bar foo#{bar} foo)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use `[:"#{foo}", :"#{foo}bar", :"foo#{bar}", :foo]` for an array of symbols.
      RUBY

      expect_correction(<<~'RUBY')
        [:"#{foo}", :"#{foo}bar", :"foo#{bar}", :foo]
      RUBY
    end
  end

  context 'with non-default MinSize' do
    let(:cop_config) { { 'MinSize' => 2, 'EnforcedStyle' => 'percent' } }

    it 'does not autocorrect array of one symbol if MinSize > 1' do
      expect_no_offenses('[:one]')
    end
  end
end
