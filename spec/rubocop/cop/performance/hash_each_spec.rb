# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Performance::HashEachMethods do
  subject(:cop) { described_class.new }
  let(:hash) { { key: 'value' } }

  it 'registers an offense for Hash#keys.each' do
    inspect_source(cop, 'hash.keys.each { |k| p k }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `each_key` instead of `keys.each`.'])
  end

  it 'registers an offense for Hash#values.each' do
    inspect_source(cop, 'hash.values.each { |v| p v }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `each_value` instead of `values.each`.'])
  end

  it 'registers an offense for Hash#each with unused value' do
    inspect_source(cop, 'hash.each { |k, _v| p k }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `each_key` instead of `each`.'])
  end

  it 'registers an offense for Hash#each with unused key' do
    inspect_source(cop, 'hash.each { |_k, v| p v }')
    expect(cop.offenses.size).to eq(1)
    expect(cop.messages)
      .to eq(['Use `each_value` instead of `each`.'])
  end

  it 'does not register an offense for Hash#each_key' do
    inspect_source(cop, 'hash.each_key { |k| p k }')
    expect(cop.messages).to be_empty
  end

  it 'does not register an offense for Hash#each_value' do
    inspect_source(cop, 'hash.each_value { |v| p v }')
    expect(cop.messages).to be_empty
  end

  it 'does not register an offense for Hash#each if both key/value are used' do
    inspect_source(cop, 'hash.each { |k, v| p "#{k}_#{v}" }')
    expect(cop.messages).to be_empty
  end

  it 'does not register an offense for Hash#each if block takes only one arg' do
    inspect_source(cop, 'hash.each { |kv| p kv }')
    expect(cop.messages).to be_empty
  end

  it 'auto-corrects Hash#keys.each with Hash#each_key' do
    new_source = autocorrect_source(cop, 'hash.keys.each { |k| p k }')
    expect(new_source).to eq('hash.each_key { |k| p k }')
  end

  it 'auto-corrects Hash#values.each with Hash#each_value' do
    new_source = autocorrect_source(cop, 'hash.values.each { |v| p v }')
    expect(new_source).to eq('hash.each_value { |v| p v }')
  end

  it 'auto-corrects Hash#each with unused value argument with Hash#each_key' do
    new_source = autocorrect_source(cop, 'hash.each { |k, _v| p k }')
    expect(new_source).to eq('hash.each_key { |k| p k }')
  end

  it 'auto-corrects Hash#each with unused key argument with Hash#each_value' do
    new_source = autocorrect_source(cop, 'hash.each { |_k, v| p v }')
    expect(new_source).to eq('hash.each_value { |v| p v }')
  end
end
