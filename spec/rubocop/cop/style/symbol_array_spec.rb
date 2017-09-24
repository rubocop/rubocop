# frozen_string_literal: true

describe RuboCop::Cop::Style::SymbolArray, :config do
  subject(:cop) { described_class.new(config) }

  before(:each) do
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
    let(:cop_config) do
      { 'MinSize' => 0,
        'EnforcedStyle' => 'percent' }
    end

    it 'registers an offense for arrays of symbols' do
      inspect_source('[:one, :two, :three]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'brackets')
    end

    it 'autocorrects arrays of symbols' do
      new_source = autocorrect_source('[:one, :two, :three]')
      expect(new_source).to eq('%i(one two three)')
    end

    it 'autocorrects arrays of symbols with new line' do
      new_source = autocorrect_source("[:one,\n:two, :three,\n:four]")
      expect(new_source).to eq("%i(one \ntwo three \nfour)")
    end

    it 'uses %I when appropriate' do
      new_source = autocorrect_source('[:"\\t", :"\\n", :three]')
      expect(new_source).to eq('%I(\\t \\n three)')
    end

    it "doesn't break when a symbol contains )" do
      source = '[:one, :")", :three, :"(", :"]", :"["]'
      new_source = autocorrect_source(source)
      expect(new_source).to eq('%i(one \\) three \\( ] [)')
    end

    it 'does not register an offense for array with non-syms' do
      expect_no_offenses('[:one, :two, "three"]')
    end

    it 'does not register an offense for array starting with %i' do
      expect_no_offenses('%i(one two three)')
    end

    it 'does not register an offense for array with one element' do
      expect_no_offenses('[:three]')
    end

    it 'does not register an offense if symbol contains whitespace' do
      expect_no_offenses('[:one, :two, :"space here"]')
    end

    # Bug: https://github.com/bbatsov/rubocop/issues/4481
    it 'does not register an offense in an ambiguous block context' do
      expect_no_offenses('foo [:bar, :baz] { qux }')
    end

    it 'registers an offense in a non-ambiguous block context' do
      expect_offense(<<-RUBY.strip_indent)
        foo([:bar, :baz]) { qux }
            ^^^^^^^^^^^^ Use `%i` or `%I` for an array of symbols.
      RUBY
    end

    it 'detects right value for MinSize to use for --auto-gen-config' do
      inspect_source(<<-RUBY.strip_indent)
        [:one, :two, :three]
        %i(a b c d)
      RUBY

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'percent',
                                                 'MinSize' => 4)
    end

    it 'detects when the cop must be disabled to avoid offenses' do
      inspect_source(<<-RUBY.strip_indent)
        [:one, :two, :three]
        %i(a b)
      RUBY
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
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
        source = '[:one, :")", :three, :"(", :"]", :"["]'
        new_source = autocorrect_source(source)
        expect(new_source).to eq('%i[one ) three ( \\] \\[]')
      end
    end
  end

  context 'when EnforcedStyle is array' do
    let(:cop_config) { { 'EnforcedStyle' => 'brackets', 'MinSize' => 0 } }

    it 'does not register an offense for arrays of symbols' do
      expect_no_offenses('[:one, :two, :three]')
    end

    it 'registers an offense for array starting with %i' do
      expect_offense(<<-RUBY.strip_indent)
        %i(one two three)
        ^^^^^^^^^^^^^^^^^ Use `[]` for an array of symbols.
      RUBY
    end

    it 'autocorrects an array starting with %i' do
      new_source = autocorrect_source('%i(one @two $three four-five)')
      expect(new_source).to eq("[:one, :@two, :$three, :'four-five']")
    end
  end
end
