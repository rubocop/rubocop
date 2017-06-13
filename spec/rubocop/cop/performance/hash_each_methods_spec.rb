# frozen_string_literal: true

describe RuboCop::Cop::Performance::HashEachMethods do
  subject(:cop) { described_class.new }

  it 'registers an offense for Hash#keys.each' do
    expect_offense(<<-RUBY.strip_indent)
      hash.keys.each { |k| p k }
           ^^^^^^^^^ Use `each_key` instead of `keys.each`.
    RUBY
  end

  it 'registers an offense for Hash#values.each' do
    expect_offense(<<-RUBY.strip_indent)
      hash.values.each { |v| p v }
           ^^^^^^^^^^^ Use `each_value` instead of `values.each`.
    RUBY
  end

  it 'registers an offense for Hash#each with unused value' do
    expect_offense(<<-RUBY.strip_indent)
      hash.each { |k, _v| p k }
      ^^^^^^^^^ Use `each_key` instead of `each`.
    RUBY
  end

  it 'registers an offense for Hash#each with unused key' do
    expect_offense(<<-RUBY.strip_indent)
      hash.each { |_k, v| p v }
      ^^^^^^^^^ Use `each_value` instead of `each`.
    RUBY
  end

  it 'does not register an offense for Hash#each_key' do
    expect_no_offenses('hash.each_key { |k| p k }')
  end

  it 'does not register an offense for Hash#each_value' do
    expect_no_offenses('hash.each_value { |v| p v }')
  end

  it 'does not register an offense for Hash#each if both key/value are used' do
    expect_no_offenses("hash.each { |k, v| p \"\#{k}_\#{v}\" }")
  end

  it 'does not register an offense for Hash#each if block takes only one arg' do
    expect_no_offenses('hash.each { |kv| p kv }')
  end

  it 'auto-corrects Hash#keys.each with Hash#each_key' do
    new_source = autocorrect_source('hash.keys.each { |k| p k }')
    expect(new_source).to eq('hash.each_key { |k| p k }')
  end

  it 'auto-corrects Hash#values.each with Hash#each_value' do
    new_source = autocorrect_source('hash.values.each { |v| p v }')
    expect(new_source).to eq('hash.each_value { |v| p v }')
  end

  it 'auto-corrects Hash#each with unused value argument with Hash#each_key' do
    new_source = autocorrect_source('hash.each { |k, _v| p k }')
    expect(new_source).to eq('hash.each_key { |k| p k }')
  end

  it 'auto-corrects Hash#each with unused key argument with Hash#each_value' do
    new_source = autocorrect_source('hash.each { |_k, v| p v }')
    expect(new_source).to eq('hash.each_value { |v| p v }')
  end
end
