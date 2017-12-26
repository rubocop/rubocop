# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashSyntax, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured to enforce ruby19 style' do
    context 'with SpaceAroundOperators enabled' do
      let(:config) do
        RuboCop::Config.new('AllCops' => {
                              'TargetRubyVersion' => ruby_version
                            },
                            'Style/HashSyntax' => cop_config,
                            'Layout/SpaceAroundOperators' => {
                              'Enabled' => true
                            })
      end

      let(:cop_config) do
        {
          'EnforcedStyle'   => 'ruby19',
          'SupportedStyles' => %w[ruby19 hash_rockets],
          'UseHashRocketsWithSymbolValues' => false,
          'PreferHashRocketsForNonAlnumEndingSymbols' => false
        }.merge(cop_config_overrides)
      end

      let(:cop_config_overrides) { {} }

      it 'registers offense for hash rocket syntax when new is possible' do
        inspect_source('x = { :a => 0 }')
        expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'hash_rockets')
      end

      it 'registers an offense for mixed syntax when new is possible' do
        inspect_source('x = { :a => 0, b: 1 }')
        expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'registers an offense for hash rockets in method calls' do
        expect_offense(<<-RUBY.strip_indent)
          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY
      end

      it 'accepts hash rockets when keys have different types' do
        expect_no_offenses('x = { :a => 0, "b" => 1 }')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      context 'ruby < 2.2', :ruby21 do
        it 'accepts hash rockets when symbol keys have string in them' do
          expect_no_offenses('x = { :"string" => 0 }')
        end
      end

      context 'ruby >= 2.2', :ruby22 do
        it 'registers an offense when symbol keys have strings in them' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :"string" => 0 }
                  ^^^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end

        it 'preserves quotes during autocorrection' do
          new_source = autocorrect_source("{ :'&&' => foo }")
          expect(new_source).to eq("{ '&&': foo }")
        end
      end

      context 'if PreferHashRocketsForNonAlnumEndingSymbols is false' do
        it 'registers an offense for hash rockets when symbols end with ?' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :a? => 0 }
                  ^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end

        it 'registers an offense for hash rockets when symbols end with !' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :a! => 0 }
                  ^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end
      end

      context 'if PreferHashRocketsForNonAlnumEndingSymbols is true' do
        let(:cop_config_overrides) do
          {
            'PreferHashRocketsForNonAlnumEndingSymbols' => true
          }
        end

        it 'accepts hash rockets when symbols end with ?' do
          expect_no_offenses('x = { :a? => 0 }')
        end

        it 'accepts hash rockets when symbols end with !' do
          expect_no_offenses('x = { :a! => 0 }')
        end
      end

      it 'accepts hash rockets when symbol keys end with =' do
        expect_no_offenses('x = { :a= => 0 }')
      end

      it 'accepts hash rockets when symbol characters are not supported' do
        expect_no_offenses('x = { :[] => 0 }')
      end

      it 'registers offense when keys start with an uppercase letter' do
        expect_offense(<<-RUBY.strip_indent)
          x = { :A => 0 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY
      end

      it 'accepts new syntax in a hash literal' do
        expect_no_offenses('x = { a: 0, b: 1 }')
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'auto-corrects old to new style' do
        new_source = autocorrect_source('{ :a => 1, :b   =>  2}')
        expect(new_source).to eq('{ a: 1, b: 2}')
      end

      it 'auto-corrects even if it interferes with SpaceAroundOperators' do
        # Clobbering caused by two cops changing in the same range is dealt with
        # by the auto-correct loop, so there's no reason to avoid a change.
        new_source = autocorrect_source('{ :a=>1, :b=>2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end

      # Bug: https://github.com/bbatsov/rubocop/issues/5019
      it 'auto-corrects a missing space when hash is used as argument' do
        new_source = autocorrect_source('foo:bar => 1')
        expect(new_source).to eq('foo bar: 1')
      end
    end

    context 'with SpaceAroundOperators disabled' do
      let(:config) do
        RuboCop::Config.new('AllCops' => {
                              'TargetRubyVersion' => ruby_version
                            },
                            'Style/HashSyntax' => {
                              'EnforcedStyle'   => 'ruby19',
                              'SupportedStyles' => %w[ruby19 hash_rockets],
                              'UseHashRocketsWithSymbolValues' => false
                            },
                            'Layout/SpaceAroundOperators' => {
                              'Enabled' => false
                            })
      end

      it 'auto-corrects even if there is no space around =>' do
        new_source = autocorrect_source('{ :a=>1, :b=>2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end
    end

    context 'configured to use hash rockets when symbol values are found' do
      let(:config) do
        RuboCop::Config.new('Style/HashSyntax' => {
                              'EnforcedStyle' => 'ruby19',
                              'SupportedStyles' => %w[ruby19 hash_rockets],
                              'UseHashRocketsWithSymbolValues' => true
                            })
      end

      it 'accepts ruby19 syntax when no elements have symbol values' do
        expect_no_offenses('x = { a: 1, b: 2 }')
      end

      it 'accepts ruby19 syntax when no elements have symbol values ' \
        'in method calls' do
        inspect_source('func(3, a: 0)')
        expect(cop.messages.empty?).to be(true)
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      it 'registers an offense when any element uses a symbol for the value' do
        expect_offense(<<-RUBY.strip_indent)
          x = { a: 1, b: :c }
                ^^ Use hash rockets syntax.
                      ^^ Use hash rockets syntax.
        RUBY
      end

      it 'registers an offense when any element has a symbol value ' \
        'in method calls' do
        inspect_source('func(3, b: :c)')
        expect(cop.messages).to eq(['Use hash rockets syntax.'])
      end

      it 'registers an offense when using hash rockets ' \
        'and no elements have a symbol value' do
        inspect_source('x = { :a => 1, :b => 2 }')
        expect(cop.messages)
          .to eq(['Use the new Ruby 1.9 hash syntax.',
                  'Use the new Ruby 1.9 hash syntax.'])
      end

      it 'registers an offense for hashes with elements on multiple lines' do
        expect_offense(<<-RUBY.strip_indent)
          x = { a: :b,
                ^^ Use hash rockets syntax.
           c: :d }
           ^^ Use hash rockets syntax.
        RUBY
      end

      it 'auto-corrects to ruby19 style when there are no symbol values' do
        new_source = autocorrect_source('{ :a => 1, :b => 2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end

      it 'auto-corrects to hash rockets ' \
        'when there is an element with a symbol value' do
        new_source = autocorrect_source('{ a: 1, :b => :c }')
        expect(new_source).to eq('{ :a => 1, :b => :c }')
      end

      it 'auto-corrects to hash rockets ' \
        'when all elements have symbol value' do
        new_source = autocorrect_source('{ a: :b, c: :d }')
        expect(new_source).to eq('{ :a => :b, :c => :d }')
      end

      it 'auto-correct does not change anything when the hash ' \
        'is already ruby19 style and there are no symbol values' do
        new_source = autocorrect_source('{ a: 1, b: 2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end
    end
  end

  context 'configured to enforce hash rockets style' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'hash_rockets',
        'SupportedStyles' => %w[ruby19 hash_rockets],
        'UseHashRocketsWithSymbolValues' => false
      }
    end

    it 'registers offense for Ruby 1.9 style' do
      inspect_source('x = { a: 0 }')
      expect(cop.messages).to eq(['Use hash rockets syntax.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'ruby19')
    end

    it 'registers an offense for mixed syntax' do
      inspect_source('x = { :a => 0, b: 1 }')
      expect(cop.messages).to eq(['Use hash rockets syntax.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for 1.9 style in method calls' do
      expect_offense(<<-RUBY.strip_indent)
        func(3, a: 0)
                ^^ Use hash rockets syntax.
      RUBY
    end

    it 'accepts hash rockets in a hash literal' do
      expect_no_offenses('x = { :a => 0, :b => 1 }')
    end

    it 'accepts hash rockets in method calls' do
      expect_no_offenses('func(3, :a => 0)')
    end

    it 'accepts an empty hash' do
      expect_no_offenses('{}')
    end

    it 'auto-corrects new style to hash rockets' do
      new_source = autocorrect_source('{ a: 1, b: 2}')
      expect(new_source).to eq('{ :a => 1, :b => 2}')
    end

    context 'UseHashRocketsWithSymbolValues has no impact' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'hash_rockets',
          'SupportedStyles' => %w[ruby19 hash_rockets],
          'UseHashRocketsWithSymbolValues' => true
        }
      end

      it 'does not register an offense when there is a symbol value' do
        expect_no_offenses('{ :a => :b, :c => :d }')
      end
    end
  end

  context 'configured to enforce ruby 1.9 style with no mixed keys' do
    context 'UseHashRocketsWithSymbolValues disabled' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'ruby19_no_mixed_keys',
          'UseHashRocketsWithSymbolValues' => false
        }
      end

      it 'accepts new syntax in a hash literal' do
        expect_no_offenses('x = { a: 0, b: 1 }')
      end

      it 'registers offense for hash rocket syntax when new is possible' do
        inspect_source('x = { :a => 0 }')
        expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'hash_rockets')
      end

      it 'registers an offense for mixed syntax when new is possible' do
        inspect_source('x = { :a => 0, b: 1 }')
        expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'registers an offense for hash rockets in method calls' do
        expect_offense(<<-RUBY.strip_indent)
          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY
      end

      it 'accepts hash rockets when keys have different types' do
        expect_no_offenses('x = { :a => 0, "b" => 1 }')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      it 'registers an offense when keys have different types and styles' do
        inspect_source('x = { a: 0, "b" => 1 }')
        expect(cop.messages).to eq(["Don't mix styles in the same hash."])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      context 'ruby < 2.2', :ruby21 do
        it 'accepts hash rockets when keys have whitespaces in them' do
          expect_no_offenses('x = { :"t o" => 0, :b => 1 }')
        end

        it 'registers an offense when keys have whitespaces and mix styles' do
          inspect_source('x = { :"t o" => 0, b: 1 }')
          expect(cop.messages).to eq(["Don't mix styles in the same hash."])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys have special symbols in them' do
          expect_no_offenses('x = { :"\\tab" => 1, :b => 1 }')
        end

        it 'registers an offense when keys have special symbols and '\
          'mix styles' do
          inspect_source('x = { :"\tab" => 1, b: 1 }')
          expect(cop.messages).to eq(["Don't mix styles in the same hash."])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys start with a digit' do
          expect_no_offenses('x = { :"1" => 1, :b => 1 }')
        end

        it 'registers an offense when keys start with a digit and mix styles' do
          inspect_source('x = { :"1" => 1, b: 1 }')
          expect(cop.messages).to eq(["Don't mix styles in the same hash."])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end
      end

      context 'ruby >= 2.2', :ruby22 do
        it 'registers an offense when keys have whitespaces in them' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :"t o" => 0 }
                  ^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end

        it 'registers an offense when keys have special symbols in them' do
          expect_offense(<<-'RUBY'.strip_indent)
            x = { :"\tab" => 1 }
                  ^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end

        it 'registers an offense when keys start with a digit' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :"1" => 1 }
                  ^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end
      end

      it 'auto-corrects old to new style' do
        new_source = autocorrect_source('{ :a => 1, :b => 2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end

      it 'auto-corrects to hash rockets when new style cannot be used ' \
        'for all' do
        new_source = autocorrect_source('{ a: 1, "b" => 2 }')
        expect(new_source).to eq('{ :a => 1, "b" => 2 }')
      end
    end

    context 'UseHashRocketsWithSymbolValues enabled' do
      let(:cop_config) do
        {
          'EnforcedStyle' => 'ruby19_no_mixed_keys',
          'UseHashRocketsWithSymbolValues' => true
        }
      end

      it 'registers an offense when any element uses a symbol for the value' do
        expect_offense(<<-RUBY.strip_indent)
          x = { a: 1, b: :c }
                ^^ Use hash rockets syntax.
                      ^^ Use hash rockets syntax.
        RUBY
      end

      it 'registers an offense when any element has a symbol value ' \
        'in method calls' do
        inspect_source('func(3, b: :c)')
        expect(cop.messages).to eq(['Use hash rockets syntax.'])
      end

      it 'auto-corrects to hash rockets ' \
        'when there is an element with a symbol value' do
        new_source = autocorrect_source('{ a: 1, :b => :c }')
        expect(new_source).to eq('{ :a => 1, :b => :c }')
      end

      it 'auto-corrects to hash rockets ' \
        'when all elements have symbol value' do
        new_source = autocorrect_source('{ a: :b, c: :d }')
        expect(new_source).to eq('{ :a => :b, :c => :d }')
      end

      it 'accepts new syntax in a hash literal' do
        expect_no_offenses('x = { a: 0, b: 1 }')
      end

      it 'registers offense for hash rocket syntax when new is possible' do
        inspect_source('x = { :a => 0 }')
        expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
        expect(cop.config_to_allow_offenses)
          .to eq('EnforcedStyle' => 'hash_rockets')
      end

      it 'registers an offense for mixed syntax when new is possible' do
        inspect_source('x = { :a => 0, b: 1 }')
        expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'registers an offense for hash rockets in method calls' do
        expect_offense(<<-RUBY.strip_indent)
          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY
      end

      it 'accepts hash rockets when keys have different types' do
        expect_no_offenses('x = { :a => 0, "b" => 1 }')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      it 'registers an offense when keys have different types and styles' do
        inspect_source('x = { a: 0, "b" => 1 }')
        expect(cop.messages).to eq(["Don't mix styles in the same hash."])
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      end

      context 'ruby < 2.2', :ruby21 do
        it 'accepts hash rockets when keys have whitespaces in them' do
          expect_no_offenses('x = { :"t o" => 0, :b => 1 }')
        end

        it 'registers an offense when keys have whitespaces and mix styles' do
          inspect_source('x = { :"t o" => 0, b: 1 }')
          expect(cop.messages).to eq(["Don't mix styles in the same hash."])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys have special symbols in them' do
          expect_no_offenses('x = { :"\\tab" => 1, :b => 1 }')
        end

        it 'registers an offense when keys have special symbols and ' \
          'mix styles' do
          inspect_source('x = { :"\tab" => 1, b: 1 }')
          expect(cop.messages).to eq(["Don't mix styles in the same hash."])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys start with a digit' do
          expect_no_offenses('x = { :"1" => 1, :b => 1 }')
        end

        it 'registers an offense when keys start with a digit and mix styles' do
          inspect_source('x = { :"1" => 1, b: 1 }')
          expect(cop.messages).to eq(["Don't mix styles in the same hash."])
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end
      end

      context 'ruby >= 2.2', :ruby22 do
        it 'registers an offense when keys have whitespaces in them' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :"t o" => 0 }
                  ^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end

        it 'registers an offense when keys have special symbols in them' do
          expect_offense(<<-'RUBY'.strip_indent)
            x = { :"\tab" => 1 }
                  ^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end

        it 'registers an offense when keys start with a digit' do
          expect_offense(<<-RUBY.strip_indent)
            x = { :"1" => 1 }
                  ^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY
        end
      end

      it 'auto-corrects old to new style' do
        new_source = autocorrect_source('{ :a => 1, :b => 2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end

      it 'auto-corrects to hash rockets when new style cannot be used ' \
        'for all' do
        new_source = autocorrect_source('{ a: 1, "b" => 2 }')
        expect(new_source).to eq('{ :a => 1, "b" => 2 }')
      end
    end
  end

  context 'configured to enforce no mixed keys' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'no_mixed_keys'
      }
    end

    it 'accepts new syntax in a hash literal' do
      expect_no_offenses('x = { a: 0, b: 1 }')
    end

    it 'accepts the hash rocket syntax when new is possible' do
      expect_no_offenses('x = { :a => 0 }')
    end

    it 'registers an offense for mixed syntax when new is possible' do
      inspect_source('x = { :a => 0, b: 1 }')
      expect(cop.messages).to eq(['Don\'t mix styles in the same hash.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts new syntax in method calls' do
      expect_no_offenses('func(3, a: 0)')
    end

    it 'accepts hash rockets in method calls' do
      expect_no_offenses('func(3, :a => 0)')
    end

    it 'accepts hash rockets when keys have different types' do
      expect_no_offenses('x = { :a => 0, "b" => 1 }')
    end

    it 'accepts an empty hash' do
      expect_no_offenses('{}')
    end

    it 'registers an offense when keys have different types and styles' do
      inspect_source('x = { a: 0, "b" => 1 }')
      expect(cop.messages).to eq(["Don't mix styles in the same hash."])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts hash rockets when keys have whitespaces in them' do
      expect_no_offenses('x = { :"t o" => 0, :b => 1 }')
    end

    it 'registers an offense when keys have whitespaces and mix styles' do
      inspect_source('x = { :"t o" => 0, b: 1 }')
      expect(cop.messages).to eq(["Don't mix styles in the same hash."])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts hash rockets when keys have special symbols in them' do
      expect_no_offenses('x = { :"\\tab" => 1, :b => 1 }')
    end

    it 'registers an offense when keys have special symbols and '\
      'mix styles' do
      inspect_source('x = { :"\tab" => 1, b: 1 }')
      expect(cop.messages).to eq(["Don't mix styles in the same hash."])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'accepts hash rockets when keys start with a digit' do
      expect_no_offenses('x = { :"1" => 1, :b => 1 }')
    end

    it 'registers an offense when keys start with a digit and mix styles' do
      inspect_source('x = { :"1" => 1, b: 1 }')
      expect(cop.messages).to eq(["Don't mix styles in the same hash."])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'does not auto-correct old to new style' do
      new_source = autocorrect_source('{ :a => 1, :b => 2 }')
      expect(new_source).to eq('{ :a => 1, :b => 2 }')
    end

    it 'does not auto-correct new to hash rockets style' do
      new_source = autocorrect_source('{ a: 1, b: 2 }')
      expect(new_source).to eq('{ a: 1, b: 2 }')
    end

    it 'auto-corrects mixed key hashes' do
      new_source = autocorrect_source('{ a: 1, :b => 2 }')
      expect(new_source).to eq('{ a: 1, b: 2 }')
    end

    it 'auto-corrects to hash rockets when new style cannot be used ' \
      'for all' do
      new_source = autocorrect_source('{ a: 1, "b" => 2 }')
      expect(new_source).to eq('{ :a => 1, "b" => 2 }')
    end
  end
end
