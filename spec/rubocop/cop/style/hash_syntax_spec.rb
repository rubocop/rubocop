# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::HashSyntax, :config do
  subject(:cop) { described_class.new(config) }

  context 'configured to enforce ruby19 style' do
    let(:config) do
      RuboCop::Config.new('Style/HashSyntax' => {
                            'EnforcedStyle'   => 'ruby19',
                            'SupportedStyles' => %w(ruby19 hash_rockets)
                          },
                          'Style/SpaceAroundOperators' => {
                            'Enabled' => true
                          })
    end

    it 'registers offense for hash rocket syntax when new is possible' do
      inspect_source(cop, 'x = { :a => 0 }')
      expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
      expect(cop.config_to_allow_offenses)
        .to eq('EnforcedStyle' => 'hash_rockets')
    end

    it 'registers an offense for mixed syntax when new is possible' do
      inspect_source(cop, 'x = { :a => 0, b: 1 }')
      expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for hash rockets in method calls' do
      inspect_source(cop, 'func(3, :a => 0)')
      expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
    end

    it 'accepts hash rockets when keys have different types' do
      inspect_source(cop, 'x = { :a => 0, "b" => 1 }')
      expect(cop.messages).to be_empty
    end

    it 'accepts hash rockets when keys have whitespaces in them' do
      inspect_source(cop, 'x = { :"t o" => 0 }')
      expect(cop.messages).to be_empty
    end

    it 'accepts hash rockets when keys have special symbols in them' do
      inspect_source(cop, 'x = { :"\tab" => 1 }')
      expect(cop.messages).to be_empty
    end

    it 'accepts hash rockets when keys start with a digit' do
      inspect_source(cop, 'x = { :"1" => 1 }')
      expect(cop.messages).to be_empty
    end

    it 'registers offense when keys start with an uppercase letter' do
      inspect_source(cop, 'x = { :A => 0 }')
      expect(cop.messages).to eq(['Use the new Ruby 1.9 hash syntax.'])
    end

    it 'accepts new syntax in a hash literal' do
      inspect_source(cop, 'x = { a: 0, b: 1 }')
      expect(cop.messages).to be_empty
    end

    it 'accepts new syntax in method calls' do
      inspect_source(cop, 'func(3, a: 0)')
      expect(cop.messages).to be_empty
    end

    it 'auto-corrects old to new style' do
      new_source = autocorrect_source(cop, '{ :a => 1, :b   =>  2}')
      expect(new_source).to eq('{ a: 1, b: 2}')
    end

    it 'auto-corrects even if it interferes with SpaceAroundOperators' do
      # Clobbering caused by two cops changing in the same range is dealt with
      # by the auto-correct loop, so there's no reason to avoid a change.
      new_source = autocorrect_source(cop, '{ :a=>1, :b=>2 }')
      expect(new_source).to eq('{ a: 1, b: 2 }')
    end

    context 'with SpaceAroundOperators disabled' do
      let(:config) do
        RuboCop::Config.new('Style/HashSyntax' => {
                              'EnforcedStyle'   => 'ruby19',
                              'SupportedStyles' => %w(ruby19 hash_rockets)
                            },
                            'Style/SpaceAroundOperators' => {
                              'Enabled' => false
                            })
      end

      it 'auto-corrects even if there is no space around =>' do
        new_source = autocorrect_source(cop, '{ :a=>1, :b=>2 }')
        expect(new_source).to eq('{ a: 1, b: 2 }')
      end
    end
  end

  context 'configured to enforce hash rockets style' do
    let(:cop_config) { { 'EnforcedStyle' => 'hash_rockets' } }

    it 'registers offense for Ruby 1.9 style' do
      inspect_source(cop, 'x = { a: 0 }')
      expect(cop.messages).to eq(['Always use hash rockets in hashes.'])
      expect(cop.config_to_allow_offenses).to eq('EnforcedStyle' => 'ruby19')
    end

    it 'registers an offense for mixed syntax' do
      inspect_source(cop, 'x = { :a => 0, b: 1 }')
      expect(cop.messages).to eq(['Always use hash rockets in hashes.'])
      expect(cop.config_to_allow_offenses).to eq('Enabled' => false)
    end

    it 'registers an offense for 1.9 style in method calls' do
      inspect_source(cop, 'func(3, a: 0)')
      expect(cop.messages).to eq(['Always use hash rockets in hashes.'])
    end

    it 'accepts hash rockets in a hash literal' do
      inspect_source(cop, 'x = { :a => 0, :b => 1 }')
      expect(cop.messages).to be_empty
    end

    it 'accepts hash rockets in method calls' do
      inspect_source(cop, 'func(3, :a => 0)')
      expect(cop.messages).to be_empty
    end

    it 'auto-corrects new style to hash rockets' do
      new_source = autocorrect_source(cop, '{ a: 1, b: 2}')
      expect(new_source).to eq('{ :a => 1, :b => 2}')
    end
  end
end
