# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::HashSyntax, :config do
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
          'EnforcedStyle' => 'ruby19',
          'SupportedStyles' => %w[ruby19 hash_rockets],
          'EnforcedShorthandSyntax' => 'always',
          'SupportedShorthandSyntax' => %w[always never],
          'UseHashRocketsWithSymbolValues' => false,
          'PreferHashRocketsForNonAlnumEndingSymbols' => false
        }.merge(cop_config_overrides)
      end

      let(:cop_config_overrides) { {} }

      it 'registers offense for hash rocket syntax when new is possible' do
        expect_offense(<<~RUBY)
          x = { :a => 0, :b   =>  2}
                ^^^^^ Use the new Ruby 1.9 hash syntax.
                         ^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { a: 0, b: 2}
        RUBY
      end

      it 'registers an offense for mixed syntax when new is possible' do
        expect_offense(<<~RUBY)
          x = { :a => 0, b: 1 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { a: 0, b: 1 }
        RUBY
      end

      it 'registers an offense for hash rockets in method calls' do
        expect_offense(<<~RUBY)
          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          func(3, a: 0)
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

      it 'registers an offense when symbol keys have strings in them' do
        expect_offense(<<~RUBY)
          x = { :"string" => 0 }
                ^^^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { "string": 0 }
        RUBY
      end

      it 'preserves quotes during autocorrection' do
        expect_offense(<<~RUBY)
          { :'&&' => foo }
            ^^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          { '&&': foo }
        RUBY
      end

      context 'if PreferHashRocketsForNonAlnumEndingSymbols is false' do
        it 'registers an offense for hash rockets when symbols end with ?' do
          expect_offense(<<~RUBY)
            x = { :a? => 0 }
                  ^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY

          expect_correction(<<~RUBY)
            x = { a?: 0 }
          RUBY
        end

        it 'registers an offense for hash rockets when symbols end with !' do
          expect_offense(<<~RUBY)
            x = { :a! => 0 }
                  ^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY

          expect_correction(<<~RUBY)
            x = { a!: 0 }
          RUBY
        end
      end

      context 'if PreferHashRocketsForNonAlnumEndingSymbols is true' do
        let(:cop_config_overrides) { { 'PreferHashRocketsForNonAlnumEndingSymbols' => true } }

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
        expect_offense(<<~RUBY)
          x = { :A => 0 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { A: 0 }
        RUBY
      end

      it 'accepts new syntax in a hash literal' do
        expect_no_offenses('x = { a: 0, b: 1 }')
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'autocorrects even if it interferes with SpaceAroundOperators' do
        # Clobbering caused by two cops changing in the same range is dealt with
        # by the autocorrect loop, so there's no reason to avoid a change.
        expect_offense(<<~RUBY)
          { :a=>1, :b=>2 }
            ^^^^ Use the new Ruby 1.9 hash syntax.
                   ^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          { a: 1, b: 2 }
        RUBY
      end

      # Bug: https://github.com/rubocop/rubocop/issues/5019
      it 'autocorrects a missing space when hash is used as argument' do
        expect_offense(<<~RUBY)
          foo:bar => 1
             ^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          foo bar: 1
        RUBY
      end

      context 'when using a return value uses `return`' do
        it 'registers an offense and corrects when not enclosed in parentheses' do
          expect_offense(<<~RUBY)
            return :key => value
                   ^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY

          expect_correction(<<~RUBY)
            return {key: value}
          RUBY
        end

        it 'registers an offense and corrects when enclosed in parentheses' do
          expect_offense(<<~RUBY)
            return {:key => value}
                    ^^^^^^^ Use the new Ruby 1.9 hash syntax.
          RUBY

          expect_correction(<<~RUBY)
            return {key: value}
          RUBY
        end
      end
    end

    context 'with SpaceAroundOperators disabled' do
      let(:config) do
        RuboCop::Config.new('AllCops' => {
                              'TargetRubyVersion' => ruby_version
                            },
                            'Style/HashSyntax' => {
                              'EnforcedStyle' => 'ruby19',
                              'SupportedStyles' => %w[ruby19 hash_rockets],
                              'UseHashRocketsWithSymbolValues' => false
                            },
                            'Layout/SpaceAroundOperators' => {
                              'Enabled' => false
                            })
      end

      it 'autocorrects even if there is no space around =>' do
        expect_offense(<<~RUBY)
          { :a=>1, :b=>2 }
            ^^^^ Use the new Ruby 1.9 hash syntax.
                   ^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          { a: 1, b: 2 }
        RUBY
      end
    end

    context 'configured to use hash rockets when symbol values are found' do
      let(:config) do
        RuboCop::Config.new('AllCops' => {
                              'TargetRubyVersion' => ruby_version
                            },
                            'Style/HashSyntax' => {
                              'EnforcedStyle' => 'ruby19',
                              'SupportedStyles' => %w[ruby19 hash_rockets],
                              'UseHashRocketsWithSymbolValues' => true
                            })
      end

      it 'accepts ruby19 syntax when no elements have symbol values' do
        expect_no_offenses('x = { a: 1, b: 2 }')
      end

      it 'accepts ruby19 syntax when no elements have symbol values in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      it 'registers an offense when any element uses a symbol for the value' do
        expect_offense(<<~RUBY)
          x = { a: 1, b: :c }
                ^^ Use hash rockets syntax.
                      ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { :a => 1, :b => :c }
        RUBY
      end

      it 'registers an offense when any element has a symbol value in method calls' do
        expect_offense(<<~RUBY)
          func(3, b: :c)
                  ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          func(3, :b => :c)
        RUBY
      end

      it 'registers an offense when using hash rockets and no elements have a symbol value' do
        expect_offense(<<~RUBY)
          x = { :a => 1, :b => 2 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
                         ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { a: 1, b: 2 }
        RUBY
      end

      it 'registers an offense for hashes with elements on multiple lines' do
        expect_offense(<<~RUBY)
          x = { a: :b,
                ^^ Use hash rockets syntax.
           c: :d }
           ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { :a => :b,
           :c => :d }
        RUBY
      end

      it 'accepts both hash rockets and ruby19 syntax in the same code' do
        expect_no_offenses(<<~RUBY)
          rocket_required = { :a => :b }
          ruby19_required = { c: 3 }
        RUBY
      end

      it 'autocorrects to hash rockets when all elements have symbol value' do
        expect_offense(<<~RUBY)
          { a: :b, c: :d }
            ^^ Use hash rockets syntax.
                   ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          { :a => :b, :c => :d }
        RUBY
      end

      it 'accepts hash in ruby19 style with no symbol values' do
        expect_no_offenses(<<~RUBY)
          { a: 1, b: 2 }
        RUBY
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
      expect_offense(<<~RUBY)
        x = { a: 0, b: 2}
              ^^ Use hash rockets syntax.
                    ^^ Use hash rockets syntax.
      RUBY

      expect_correction(<<~RUBY)
        x = { :a => 0, :b => 2}
      RUBY
    end

    it 'registers an offense for mixed syntax' do
      expect_offense(<<~RUBY)
        x = { a => 0, b: 1 }
                      ^^ Use hash rockets syntax.
      RUBY

      expect_correction(<<~RUBY)
        x = { a => 0, :b => 1 }
      RUBY
    end

    it 'registers an offense for 1.9 style in method calls' do
      expect_offense(<<~RUBY)
        func(3, a: 0)
                ^^ Use hash rockets syntax.
      RUBY

      expect_correction(<<~RUBY)
        func(3, :a => 0)
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
        expect_offense(<<~RUBY)
          x = { :a => 0, :b => 2 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
                         ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { a: 0, b: 2 }
        RUBY
      end

      it 'registers an offense for mixed syntax when new is possible' do
        expect_offense(<<~RUBY)
          x = { :a => 0, b: 1 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { a: 0, b: 1 }
        RUBY
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'registers an offense for hash rockets in method calls' do
        expect_offense(<<~RUBY)
          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          func(3, a: 0)
        RUBY
      end

      it 'accepts hash rockets when keys have different types' do
        expect_no_offenses('x = { :a => 0, "b" => 1 }')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      it 'registers an offense when keys have different types and styles' do
        expect_offense(<<~RUBY)
          x = { a: 0, "b" => 1 }
                ^^ Don't mix styles in the same hash.
        RUBY
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        expect_correction(<<~RUBY)
          x = { :a => 0, "b" => 1 }
        RUBY
      end

      context 'ruby < 2.2', :ruby21 do
        it 'accepts hash rockets when keys have whitespaces in them' do
          expect_no_offenses('x = { :"t o" => 0, :b => 1 }')
        end

        it 'registers an offense when keys have whitespaces and mix styles' do
          expect_offense(<<~RUBY)
            x = { :"t o" => 0, b: 1 }
                               ^^ Don't mix styles in the same hash.
          RUBY
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys have special symbols in them' do
          expect_no_offenses('x = { :"\\tab" => 1, :b => 1 }')
        end

        it 'registers an offense when keys have special symbols and mix styles' do
          expect_offense(<<~RUBY)
            x = { :"\tab" => 1, b: 1 }
                               ^^ Don't mix styles in the same hash.
          RUBY
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys start with a digit' do
          expect_no_offenses('x = { :"1" => 1, :b => 1 }')
        end

        it 'registers an offense when keys start with a digit and mix styles' do
          expect_offense(<<~RUBY)
            x = { :"1" => 1, b: 1 }
                             ^^ Don't mix styles in the same hash.
          RUBY
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end
      end

      it 'registers an offense when keys have whitespaces in them' do
        expect_offense(<<~RUBY)
          x = { :"t o" => 0 }
                ^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { "t o": 0 }
        RUBY
      end

      it 'registers an offense when keys have special symbols in them' do
        expect_offense(<<~'RUBY')
          x = { :"\tab" => 1 }
                ^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~'RUBY')
          x = { "\tab": 1 }
        RUBY
      end

      it 'registers an offense when keys start with a digit' do
        expect_offense(<<~RUBY)
          x = { :"1" => 1 }
                ^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { "1": 1 }
        RUBY
      end

      it 'accepts new syntax when keys are interpolated string' do
        expect_no_offenses('{"#{foo}": 1, "#{@foo}": 2, "#@foo": 3}')
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
        expect_offense(<<~RUBY)
          x = { a: 1, b: :c }
                ^^ Use hash rockets syntax.
                      ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { :a => 1, :b => :c }
        RUBY
      end

      it 'registers an offense when any element has a symbol value in method calls' do
        expect_offense(<<~RUBY)
          func(3, b: :c)
                  ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          func(3, :b => :c)
        RUBY
      end

      it 'autocorrects to hash rockets when all elements have symbol value' do
        expect_offense(<<~RUBY)
          { a: :b, c: :d }
            ^^ Use hash rockets syntax.
                   ^^ Use hash rockets syntax.
        RUBY

        expect_correction(<<~RUBY)
          { :a => :b, :c => :d }
        RUBY
      end

      it 'accepts new syntax in a hash literal' do
        expect_no_offenses('x = { a: 0, b: 1 }')
      end

      it 'registers offense for hash rocket syntax when new is possible' do
        expect_offense(<<~RUBY)
          x = { :a => 0, :b => 2 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
                         ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY
        expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'hash_rockets')
        expect_correction(<<~RUBY)
          x = { a: 0, b: 2 }
        RUBY
      end

      it 'registers an offense for mixed syntax when new is possible' do
        expect_offense(<<~RUBY)
          x = { :a => 0, b: 1 }
                ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        expect_correction(<<~RUBY)
          x = { a: 0, b: 1 }
        RUBY
      end

      it 'accepts new syntax in method calls' do
        expect_no_offenses('func(3, a: 0)')
      end

      it 'registers an offense for hash rockets in method calls' do
        expect_offense(<<~RUBY)
          func(3, :a => 0)
                  ^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          func(3, a: 0)
        RUBY
      end

      it 'accepts hash rockets when keys have different types' do
        expect_no_offenses('x = { :a => 0, "b" => 1 }')
      end

      it 'accepts an empty hash' do
        expect_no_offenses('{}')
      end

      it 'registers an offense when keys have different types and styles' do
        expect_offense(<<~RUBY)
          x = { a: 0, "b" => 1 }
                ^^ Don't mix styles in the same hash.
        RUBY
        expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        expect_correction(<<~RUBY)
          x = { :a => 0, "b" => 1 }
        RUBY
      end

      context 'ruby < 2.2', :ruby21 do
        it 'accepts hash rockets when keys have whitespaces in them' do
          expect_no_offenses('x = { :"t o" => 0, :b => 1 }')
        end

        it 'registers an offense when keys have whitespaces and mix styles' do
          expect_offense(<<~RUBY)
            x = { :"t o" => 0, b: 1 }
                               ^^ Don't mix styles in the same hash.
          RUBY
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys have special symbols in them' do
          expect_no_offenses('x = { :"\\tab" => 1, :b => 1 }')
        end

        it 'registers an offense when keys have special symbols and mix styles' do
          expect_offense(<<~RUBY)
            x = { :"\tab" => 1, b: 1 }
                               ^^ Don't mix styles in the same hash.
          RUBY
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end

        it 'accepts hash rockets when keys start with a digit' do
          expect_no_offenses('x = { :"1" => 1, :b => 1 }')
        end

        it 'registers an offense when keys start with a digit and mix styles' do
          expect_offense(<<~RUBY)
            x = { :"1" => 1, b: 1 }
                             ^^ Don't mix styles in the same hash.
          RUBY
          expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
        end
      end

      it 'registers an offense when keys have whitespaces in them' do
        expect_offense(<<~RUBY)
          x = { :"t o" => 0 }
                ^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { "t o": 0 }
        RUBY
      end

      it 'registers an offense when keys have special symbols in them' do
        expect_offense(<<~'RUBY')
          x = { :"\tab" => 1 }
                ^^^^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~'RUBY')
          x = { "\tab": 1 }
        RUBY
      end

      it 'registers an offense when keys start with a digit' do
        expect_offense(<<~RUBY)
          x = { :"1" => 1 }
                ^^^^^^^ Use the new Ruby 1.9 hash syntax.
        RUBY

        expect_correction(<<~RUBY)
          x = { "1": 1 }
        RUBY
      end

      it 'accepts new syntax when keys are interpolated string' do
        expect_no_offenses('{"#{foo}": 1, "#{@foo}": 2, "#@foo": 3}')
      end
    end
  end

  context 'configured to enforce no mixed keys' do
    let(:cop_config) { { 'EnforcedStyle' => 'no_mixed_keys' } }

    it 'accepts new syntax in a hash literal' do
      expect_no_offenses('x = { a: 0, b: 1 }')
    end

    it 'accepts the hash rocket syntax when new is possible' do
      expect_no_offenses('x = { :a => 0 }')
    end

    it 'registers an offense for mixed syntax when new is possible' do
      expect_offense(<<~RUBY)
        x = { :a => 0, b: 1 }
                       ^^ Don't mix styles in the same hash.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      expect_correction(<<~RUBY)
        x = { :a => 0, :b => 1 }
      RUBY
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
      expect_offense(<<~RUBY)
        x = { a: 0, "b" => 1 }
              ^^ Don't mix styles in the same hash.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      expect_correction(<<~RUBY)
        x = { :a => 0, "b" => 1 }
      RUBY
    end

    it 'accepts hash rockets when keys have whitespaces in them' do
      expect_no_offenses('x = { :"t o" => 0, :b => 1 }')
    end

    context 'Ruby >= 3.1', :ruby31 do
      it 'registers hash rockets when keys have whitespaces in them and using hash value omission' do
        expect_offense(<<~RUBY)
          {:"t o" => 0, b:}
                        ^^ Don't mix styles in the same hash.
        RUBY

        expect_correction(<<~RUBY)
          {:"t o" => 0, :b => b}
        RUBY
      end
    end

    it 'registers an offense when keys have whitespaces and mix styles' do
      expect_offense(<<~RUBY)
        x = { :"t o" => 0, b: 1 }
                           ^^ Don't mix styles in the same hash.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      expect_correction(<<~RUBY)
        x = { :"t o" => 0, :b => 1 }
      RUBY
    end

    it 'accepts hash rockets when keys have special symbols in them' do
      expect_no_offenses('x = { :"\\tab" => 1, :b => 1 }')
    end

    it 'registers an offense when keys have special symbols and mix styles' do
      expect_offense(<<~RUBY, tab: "\t")
        x = { :"%{tab}ab" => 1, b: 1 }
                _{tab}          ^^ Don't mix styles in the same hash.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      expect_correction(<<~RUBY)
        x = { :"\tab" => 1, :b => 1 }
      RUBY
    end

    it 'accepts hash rockets when keys start with a digit' do
      expect_no_offenses('x = { :"1" => 1, :b => 1 }')
    end

    it 'registers an offense when keys start with a digit and mix styles' do
      expect_offense(<<~RUBY)
        x = { :"1" => 1, b: 1 }
                         ^^ Don't mix styles in the same hash.
      RUBY
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
      expect_correction(<<~RUBY)
        x = { :"1" => 1, :b => 1 }
      RUBY
    end

    it 'accepts old hash rockets style' do
      expect_no_offenses('{ :a => 1, :b => 2 }')
    end

    it 'accepts new hash style' do
      expect_no_offenses('{ a: 1, b: 2 }')
    end

    it 'autocorrects mixed key hashes' do
      expect_offense(<<~RUBY)
        { a: 1, :b => 2 }
                ^^^^^ Don't mix styles in the same hash.
      RUBY

      expect_correction(<<~RUBY)
        { a: 1, b: 2 }
      RUBY
    end
  end

  context 'configured to enforce shorthand syntax style' do
    let(:cop_config) do
      {
        'EnforcedStyle' => enforced_style,
        'SupportedStyles' => %w[ruby19 hash_rockets],
        'EnforcedShorthandSyntax' => 'always'
      }
    end
    let(:enforced_style) { 'ruby19' }

    context 'Ruby >= 3.1', :ruby31 do
      it 'registers and corrects an offense when hash key and hash value are the same' do
        expect_offense(<<~RUBY)
          {foo: foo, bar: bar}
                ^^^ Omit the hash value.
                          ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo:, bar:}
        RUBY
      end

      it 'registers and corrects an offense when hash key and hash value (lvar) are the same' do
        expect_offense(<<~RUBY)
          foo = 'a'
          bar = 'b'

          {foo: foo, bar: bar}
                ^^^ Omit the hash value.
                          ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          foo = 'a'
          bar = 'b'

          {foo:, bar:}
        RUBY
      end

      it 'registers and corrects an offense when hash key and hash value are partially the same' do
        expect_offense(<<~RUBY)
          {foo:, bar: bar, baz: qux}
                      ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo:, bar:, baz: qux}
        RUBY
      end

      it 'registers and corrects an offense when `Hash[foo: foo]`' do
        expect_offense(<<~RUBY)
          Hash[foo: foo]
                    ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          Hash[foo:]
        RUBY
      end

      it 'registers and corrects an offense when `Hash[foo: foo]` and an expression follows' do
        expect_offense(<<~RUBY)
          Hash[foo: foo]
                    ^^^ Omit the hash value.
          do_something
        RUBY

        expect_correction(<<~RUBY)
          Hash[foo:]
          do_something
        RUBY
      end

      it 'registers and corrects an offense when hash key and hash value are the same and it in the method body' do
        expect_offense(<<~RUBY)
          def do_something
            {
              foo: foo,
                   ^^^ Omit the hash value.
              bar: bar
                   ^^^ Omit the hash value.
            }
          end
        RUBY

        expect_correction(<<~RUBY)
          def do_something
            {
              foo:,
              bar:
            }
          end
        RUBY
      end

      it 'registers and corrects an offense when hash key and hash value are the same and it in the method body' \
         'and an expression follows' do
        expect_offense(<<~RUBY)
          def do_something
            {
              foo: foo,
                   ^^^ Omit the hash value.
              bar: bar
                   ^^^ Omit the hash value.
            }
          end
          do_something
        RUBY

        expect_correction(<<~RUBY)
          def do_something
            {
              foo:,
              bar:
            }
          end
          do_something
        RUBY
      end

      it 'does not register an offense when hash values are omitted' do
        expect_no_offenses(<<~RUBY)
          {foo:, bar:}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are not the same' do
        expect_no_offenses(<<~RUBY)
          {foo: bar, bar: foo}
        RUBY
      end

      it 'does not register an offense when symbol hash key and hash value (lvar) are not the same' do
        expect_no_offenses(<<~RUBY)
          foo = 'a'
          bar = 'b'

          {foo: bar, bar: foo}
        RUBY
      end

      it 'registers an offense when hash key and hash value are not the same and method with `[]` is called' do
        expect_offense(<<~RUBY)
          {foo: foo}.do_something[key]
                ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo:}.do_something[key]
        RUBY
      end

      it 'does not register an offense when hash pattern matching' do
        expect_no_offenses(<<~RUBY)
          case pattern
          in {foo: 42}
          in {foo: foo}
          end
        RUBY
      end

      it 'does not register an offense when hash key and hash value are the same but the value ends `!`' do
        # Prevents the following syntax error:
        #
        # $ ruby -cve 'def foo! = puts("hi"); {foo!:}'
        # ruby 3.1.0dev (2021-12-05T10:23:42Z master 19f037e452) [x86_64-darwin19]
        # -e:1: identifier foo! is not valid to get
        expect_no_offenses(<<~RUBY)
          {foo!: foo!}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are the same but the value ends `?`' do
        # Prevents the following syntax error:
        #
        # $ ruby -cve 'def foo? = puts("hi"); {foo?:}'
        # ruby 3.1.0dev (2021-12-05T10:23:42Z master 19f037e452) [x86_64-darwin19]
        # -e:1: identifier foo? is not valid to get
        expect_no_offenses(<<~RUBY)
          {foo?: foo?}
        RUBY
      end

      it 'does not register an offense when symbol hash key and string hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {'foo': 'foo'}
        RUBY
      end

      it 'does not register an offense when method call hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {foo => foo}
        RUBY
      end

      it 'does not register an offense when lvar hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          foo = 42
          {foo => foo}
        RUBY
      end

      it 'registers an offense when without parentheses call expr follows' do
        # Add parentheses to prevent syntax errors shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          foo value: value
                     ^^^^^ Omit the hash value.
          foo arg

          value = 'a'
          foo value: value
                     ^^^^^ Omit the hash value.
          foo arg
        RUBY

        expect_correction(<<~RUBY)
          foo(value:)
          foo arg

          value = 'a'
          foo(value:)
          foo arg
        RUBY
      end

      it 'registers an offense in chained calls' do
        expect_offense(<<~RUBY)
          create(:foo, bar: bar).baz
                            ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          create(:foo, bar:).baz
        RUBY
      end

      it 'registers an offense in chained calls with dispatch keywords' do
        expect_offense(<<~RUBY)
          yield(:foo, bar: bar).baz
                           ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          yield(:foo, bar:).baz
        RUBY
      end

      it 'registers an offense when without parentheses call expr follows after nested method call' do
        # Add parentheses to prevent syntax errors shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          foo bar value: value
                         ^^^^^ Omit the hash value.
          baz
        RUBY

        expect_correction(<<~RUBY)
          foo bar(value:)
          baz
        RUBY
      end

      it 'registers an offense when without parentheses call expr follows after multiple keyword arguments method call' do
        # Add parentheses to prevent syntax errors shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          foo baz: baz, qux: qux
                             ^^^ Omit the hash value.
                   ^^^ Omit the hash value.
          baz
        RUBY

        expect_correction(<<~RUBY)
          foo(baz:, qux:)
          baz
        RUBY
      end

      it 'registers an offense when expression follows hash key assignment' do
        expect_offense(<<~RUBY)
          hash[:key] = { foo: foo }
                              ^^^ Omit the hash value.
          bar
        RUBY

        expect_correction(<<~RUBY)
          hash[:key] = { foo: }
          bar
        RUBY
      end

      it 'registers an offense when expression follows attribute assignment' do
        expect_offense(<<~RUBY)
          object.attr = {foo: foo}
                              ^^^ Omit the hash value.
          pass
        RUBY

        expect_correction(<<~RUBY)
          object.attr = {foo:}
          pass
        RUBY
      end

      it 'registers an offense when expression follows multiple assignments' do
        expect_offense(<<~RUBY)
          foo = bar = do_stuff arg, opt1: opt1,
                                          ^^^^ Omit the hash value.
                                    opt2: opt2
                                          ^^^^ Omit the hash value.
          pass
        RUBY

        expect_correction(<<~RUBY)
          foo = bar = do_stuff(arg, opt1:,
                                    opt2:)
          pass
        RUBY
      end

      it 'registers an offense when one line `if` condition follows (with parentheses)' do
        expect_offense(<<~RUBY)
          foo(value: value) if bar
                     ^^^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          foo(value:) if bar
        RUBY
      end

      it 'registers an offense when one line `if` condition follows super (with parentheses)' do
        expect_offense(<<~RUBY)
          super(value: value) unless foo
                       ^^^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          super(value:) unless foo
        RUBY
      end

      it 'registers an offense in super followed by ivar assignment (without parentheses)' do
        expect_offense(<<~RUBY)
          super value: value, other: other
                                     ^^^^^ Omit the hash value.
                       ^^^^^ Omit the hash value.
          @ivar = ivar
        RUBY

        expect_correction(<<~RUBY)
          super(value:, other:)
          @ivar = ivar
        RUBY
      end

      it 'registers an offense in super followed by expr without parentheses' do
        expect_offense(<<~RUBY)
          super value: value, other: other
                                     ^^^^^ Omit the hash value.
                       ^^^^^ Omit the hash value.
          foo baz
        RUBY

        expect_correction(<<~RUBY)
          super(value:, other:)
          foo baz
        RUBY
      end

      it 'registers an offense when one line `if` condition follows yield (with parentheses)' do
        expect_offense(<<~RUBY)
          yield(value: value) unless foo
                       ^^^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          yield(value:) unless foo
        RUBY
      end

      it 'registers an offense in yield followed by ivar assignment (without parentheses)' do
        expect_offense(<<~RUBY)
          yield value: value, other: other
                                     ^^^^^ Omit the hash value.
                       ^^^^^ Omit the hash value.
          @ivar = ivar
        RUBY

        expect_correction(<<~RUBY)
          yield(value:, other:)
          @ivar = ivar
        RUBY
      end

      it 'registers an offense in yield followed by expr without parentheses' do
        expect_offense(<<~RUBY)
          yield value: value, other: other
                                     ^^^^^ Omit the hash value.
                       ^^^^^ Omit the hash value.
          foo baz
        RUBY

        expect_correction(<<~RUBY)
          yield(value:, other:)
          foo baz
        RUBY
      end

      it 'does not register an offense when one line `if` condition follows (without parentheses)' do
        expect_no_offenses(<<~RUBY)
          foo x, value: value if bar
        RUBY
      end

      it 'does not register an offense when one line `if` condition follows super (without parentheses)' do
        expect_no_offenses(<<~RUBY)
          super x, value: value unless foo
        RUBY
      end

      it 'does not register an offense when one line `if` condition follows (without parentheses) in methods' do
        expect_no_offenses(<<~RUBY)
          def method
            foo x, other:, value: value if bar
          end
        RUBY
      end

      it 'does not register an offense when `return` with one line `if` condition follows (without parentheses)' do
        expect_no_offenses(<<~RUBY)
          return foo value: value if bar
        RUBY
      end

      it 'registers an offense when one line `until` condition follows (with parentheses)' do
        expect_offense(<<~RUBY)
          foo(value: value) until bar
                     ^^^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          foo(value:) until bar
        RUBY
      end

      it 'does not register an offense when one line `until` condition follows (without parentheses)' do
        expect_no_offenses(<<~RUBY)
          foo value: value until bar
        RUBY
      end

      it 'registers an offense when call expr with argument and a block follows' do
        expect_offense(<<~RUBY)
          foo value: value
                     ^^^^^ Omit the hash value.
          foo arg do
            value
          end
        RUBY

        expect_correction(<<~RUBY)
          foo(value:)
          foo arg do
            value
          end
        RUBY
      end

      it 'registers an offense when call expr without arguments and with a block follows' do
        # Add parentheses to prevent syntax semantic changes shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          foo value: value
                     ^^^^^ Omit the hash value.
          bar do
            value
          end
        RUBY

        expect_correction(<<~RUBY)
          foo(value:)
          bar do
            value
          end
        RUBY
      end

      it 'registers an offense when with parentheses call expr follows' do
        # Add parentheses to prevent syntax semantic changes shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          foo value: value
                     ^^^^^ Omit the hash value.
          foo(arg)
        RUBY

        expect_correction(<<~RUBY)
          foo(value:)
          foo(arg)
        RUBY
      end

      it 'registers an offense when with parentheses safe navigation call expr follows' do
        # Add parentheses to prevent syntax semantic changes shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          x&.foo value: value
                        ^^^^^ Omit the hash value.
          foo(arg)
        RUBY

        expect_correction(<<~RUBY)
          x&.foo(value:)
          foo(arg)
        RUBY
      end

      it 'registers an offense when with parentheses call expr follows assignment expr' do
        # Add parentheses to prevent syntax semantic changes shown in the URL: https://bugs.ruby-lang.org/issues/18396
        expect_offense(<<~RUBY)
          var = foo value: value
                           ^^^^^ Omit the hash value.
          foo(arg)
        RUBY

        expect_correction(<<~RUBY)
          var = foo(value:)
          foo(arg)
        RUBY
      end

      it 'registers an offense when hash key and hash value are partially the same' do
        expect_offense(<<~RUBY)
          def do_something
            do_something foo: foo
                              ^^^ Omit the hash value.
            do_something(arg)
          end
        RUBY

        expect_correction(<<~RUBY)
          def do_something
            do_something(foo:)
            do_something(arg)
          end
        RUBY
      end

      it 'registers an offense when hash first arg key and hash value only are the same which has a method call on the next line' do
        expect_offense(<<~RUBY)
          buz foo: foo, bar: 'bar'
                   ^^^ Omit the hash value.

          def buz(foo:, bar:); end
        RUBY

        expect_correction(<<~RUBY)
          buz foo:, bar: 'bar'

          def buz(foo:, bar:); end
        RUBY
      end

      it 'registers an offense in method receiving hash literals' do
        expect_offense(<<~RUBY)
          foo = {bar: bar, baz: :baz, quux: quux}.merge foo
                                            ^^^^ Omit the hash value.
                      ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          foo = {bar:, baz: :baz, quux:}.merge foo
        RUBY
      end

      it 'registers an offense in arguments as method calls with hash omissions' do
        expect_offense(<<~RUBY)
          if condition?
            raise LongLongLongLongError.new 'A long, long, long, long, really long message', foo: foo
                                                                                                  ^^^ Omit the hash value.
          end
        RUBY

        expect_correction(<<~RUBY)
          if condition?
            raise LongLongLongLongError.new('A long, long, long, long, really long message', foo:)
          end
        RUBY
      end

      it 'registers an offense in calls without parentheses but inside parentheses' do
        expect_offense(<<~RUBY)
          (create :foo, bar: bar)
                             ^^^ Omit the hash value.

          pass
        RUBY

        expect_correction(<<~RUBY)
          (create :foo, bar:)

          pass
        RUBY
      end

      context 'when hash rocket syntax' do
        let(:enforced_style) { 'hash_rockets' }

        it 'does not register an offense' do
          expect_no_offenses(<<~RUBY)
            {:foo => foo, :bar => bar}
          RUBY
        end
      end
    end

    context 'Ruby <= 3.0', :ruby30 do
      it 'does not register an offense when hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end
    end
  end

  context 'configured to enforce explicit hash value syntax style' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'ruby19',
        'SupportedStyles' => %w[ruby19 hash_rockets],
        'EnforcedShorthandSyntax' => 'never'
      }
    end

    context 'Ruby >= 3.1', :ruby31 do
      it 'registers and corrects an offense when hash values are omitted' do
        expect_offense(<<~RUBY)
          {foo:, bar:}
           ^^^ Include the hash value.
                 ^^^ Include the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end

      it 'registers and corrects an offense when hash key and hash value are partially the same' do
        expect_offense(<<~RUBY)
          {foo:, bar: bar, baz: qux}
           ^^^ Include the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo: foo, bar: bar, baz: qux}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are not the same' do
        expect_no_offenses(<<~RUBY)
          {foo: bar, bar: foo}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end
    end

    context 'Ruby <= 3.0', :ruby30 do
      it 'does not register an offense when hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end
    end
  end

  context 'configured to accept both shorthand and explicit use of hash literal value' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'ruby19',
        'SupportedStyles' => %w[ruby19 hash_rockets],
        'EnforcedShorthandSyntax' => 'either'
      }
    end

    context 'Ruby >= 3.1', :ruby31 do
      it 'does not register an offense when hash values are omitted' do
        expect_no_offenses(<<~RUBY)
          {foo:, bar:}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are partially the same' do
        expect_no_offenses(<<~RUBY)
          {foo:, bar: bar, baz: qux}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are not the same' do
        expect_no_offenses(<<~RUBY)
          {foo: bar, bar: foo}
        RUBY
      end

      it 'does not register an offense when hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end
    end

    context 'Ruby <= 3.0', :ruby30 do
      it 'does not register an offense when hash key and hash value are the same' do
        expect_no_offenses(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end
    end
  end

  context 'configured to disallow mixing of implicit and explicit hash literal value' do
    let(:cop_config) do
      {
        'EnforcedStyle' => 'ruby19',
        'SupportedStyles' => %w[ruby19 hash_rockets],
        'EnforcedShorthandSyntax' => 'consistent'
      }
    end

    context 'Ruby >= 3.1', :ruby31 do
      it 'does not register an offense when all hash values are omitted' do
        expect_no_offenses(<<~RUBY)
          {foo:, bar:}
        RUBY
      end

      it 'registers an offense when some hash values are omitted but they can all be omitted' do
        expect_offense(<<~RUBY)
          {foo:, bar: bar}
                      ^^^ Do not mix explicit and implicit hash values. Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo:, bar:}
        RUBY
      end

      it 'registers an offense when some hash values are omitted but they cannot all be omitted' do
        expect_offense(<<~RUBY)
          {foo:, bar: baz}
           ^^^ Do not mix explicit and implicit hash values. Include the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo: foo, bar: baz}
        RUBY
      end

      it 'does not register an offense when all hash values are present, but no values can be omitted' do
        expect_no_offenses(<<~RUBY)
          {foo: bar, bar: foo}
        RUBY
      end

      it 'does not register an offense when all hash values are present, but only some values can be omitted' do
        expect_no_offenses(<<~RUBY)
          {foo: baz, bar: bar}
        RUBY
      end

      it 'registers an offense when all hash values are present, but can all be omitted' do
        expect_offense(<<~RUBY)
          {foo: foo, bar: bar}
                ^^^ Omit the hash value.
                          ^^^ Omit the hash value.
        RUBY

        expect_correction(<<~RUBY)
          {foo:, bar:}
        RUBY
      end
    end

    context 'Ruby <= 3.0', :ruby30 do
      it 'does not register an offense when all hash key and hash values are the same' do
        expect_no_offenses(<<~RUBY)
          {foo: foo, bar: bar}
        RUBY
      end
    end
  end
end
