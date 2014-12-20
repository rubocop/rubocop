# encoding: utf-8

require 'spec_helper'

describe RuboCop::Cop::Style::WordArray, :config do
  subject(:cop) { described_class.new(config) }
  let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /\A[\p{Word}]+\z/ } }

  it 'registers an offense for arrays of single quoted strings' do
    inspect_source(cop,
                   "['one', 'two', 'three']")
    expect(cop.offenses.size).to eq(1)
    expect(cop.config_to_allow_offenses).to eq('MinSize' => 3)
  end

  it 'registers an offense for arrays of double quoted strings' do
    inspect_source(cop,
                   '["one", "two", "three"]')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for arrays of unicode word characters' do
    inspect_source(cop,
                   '["ВУЗ", "вуз", "中文网"]')
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for arrays with character constants' do
    inspect_source(cop,
                   '["one", ?\n]')
    expect(cop.offenses.size).to eq(1)
  end

  it 'does not register an offense for array of non-words' do
    inspect_source(cop,
                   '["one space", "two", "three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array containing non-string' do
    inspect_source(cop,
                   '["one", "two", 3]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array starting with %w' do
    inspect_source(cop,
                   '%w(one two three)')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array with one element' do
    inspect_source(cop,
                   '["three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array with empty strings' do
    inspect_source(cop,
                   '["", "two", "three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for array with allowed number of strings' do
    cop_config['MinSize'] = 3

    inspect_source(cop,
                   '["one", "two", "three"]')
    expect(cop.offenses).to be_empty
  end

  it 'does not register an offense for an array with comments in it' do
    inspect_source(cop,
                   ['[',
                    '"foo", # comment here',
                    '"bar", # this thing was done because of a bug',
                    '"baz" # do not delete this line',
                    ']'])

    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for an array with comments outside of it' do
    inspect_source(cop,
                   ['[',
                    '"foo",',
                    '"bar",',
                    '"baz"',
                    '] # test'])

    expect(cop.offenses.size).to eq(1)
  end

  it 'auto-corrects an array of words' do
    new_source = autocorrect_source(cop, "['one', %q(two), 'three']")
    expect(new_source).to eq('%w(one two three)')
  end

  it 'auto-corrects an array of words and character constants' do
    new_source = autocorrect_source(cop, '[%{one}, %Q(two), ?\n, ?\t]')
    expect(new_source).to eq('%W(one two \n \t)')
  end

  context 'with a custom WordRegex configuration' do
    let(:cop_config) { { 'MinSize' => 0, 'WordRegex' => /\A[\w@.]+\z/ } }

    it 'registers an offense for arrays of email addresses' do
      inspect_source(cop, "['a@example.com', 'b@example.com']")
      expect(cop.offenses.size).to eq(1)
    end

    it 'auto-corrects an array of email addresses' do
      new_source = autocorrect_source(cop, "['a@example.com', 'b@example.com']")
      expect(new_source).to eq('%w(a@example.com b@example.com)')
    end
  end
end
