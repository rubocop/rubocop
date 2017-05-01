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
      inspect_source(cop, '[:one, :two, :three]')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'brackets')
    end

    it 'autocorrects arrays of symbols' do
      new_source = autocorrect_source(cop, '[:one, :two, :three]')
      expect(new_source).to eq('%i(one two three)')
    end

    it 'autocorrects arrays of symbols with new line' do
      new_source = autocorrect_source(cop, "[:one,\n:two, :three,\n:four]")
      expect(new_source).to eq("%i(one \ntwo three \nfour)")
    end

    it 'uses %I when appropriate' do
      new_source = autocorrect_source(cop, '[:"\\t", :"\\n", :three]')
      expect(new_source).to eq('%I(\\t \\n three)')
    end

    it "doesn't break when a symbol contains )" do
      source = '[:one, :")", :three, :"(", :"]", :"["]'
      new_source = autocorrect_source(cop, source)
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

    it 'detects right value for MinSize to use for --auto-gen-config' do
      inspect_source(cop, <<-END.strip_indent)
        [:one, :two, :three]
        %i(a b c d)
      END

      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'percent',
                                                 'MinSize' => 4)
    end

    it 'detects when the cop must be disabled to avoid offenses' do
      inspect_source(cop, <<-END.strip_indent)
        [:one, :two, :three]
        %i(a b)
      END
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `%i` or `%I` for an array of symbols.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    context 'Ruby 1.9', :ruby19 do
      it 'accepts arrays of smybols' do
        expect_no_offenses('[:one, :two, :three]')
      end
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
        new_source = autocorrect_source(cop, source)
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
      inspect_source(cop, '%i(one two three)')
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages).to eq(['Use `[]` for an array of symbols.'])
    end

    it 'autocorrects an array starting with %i' do
      new_source = autocorrect_source(cop, '%i(one @two $three four-five)')
      expect(new_source).to eq("[:one, :@two, :$three, :'four-five']")
    end
  end
end
