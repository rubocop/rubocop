# frozen_string_literal: true

describe RuboCop::Cop::Rails::OutputSafety do
  subject(:cop) { described_class.new }

  it 'registers an offense for safe_concat methods' do
    source = <<-RUBY.strip_indent
      foo.safe_concat('bar')
    RUBY
    inspect_source(source)
    expect(cop.offenses.size).to eq(1)
  end

  it 'registers an offense for html_safe methods with a receiver and no ' \
     'arguments' do
    source = <<-RUBY.strip_indent
      foo.html_safe
      "foo".html_safe
    RUBY
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts html_safe methods without a receiver' do
    expect_no_offenses('html_safe')
  end

  it 'accepts html_safe methods with arguments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      foo.html_safe one
      "foo".html_safe two
    RUBY
  end

  it 'registers an offense for raw methods without a receiver' do
    source = <<-RUBY.strip_indent
      raw(foo)
      raw "foo"
    RUBY
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts raw methods with a receiver' do
    expect_no_offenses(<<-RUBY.strip_indent)
      foo.raw(foo)
      "foo".raw "foo"
    RUBY
  end

  it 'accepts raw methods without arguments' do
    expect_no_offenses('raw')
  end

  it 'accepts raw methods with more than one arguments' do
    expect_no_offenses('raw one, two')
  end

  it 'accepts comments' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # foo.html_safe
      # raw foo
    RUBY
  end

  it 'does not accept safe_concat methods when wrapped in a safe_join' do
    source = 'safe_join([i18n_text.safe_concat(i18n_text),
              i18n_text.safe_concat(i18n_mode_additional_markup(key))])'
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept raw methods when wrapped in a safe_join' do
    source = 'safe_join([raw(i18n_text),
              raw(i18n_mode_additional_markup(key))])'
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept html_safe methods when wrapped in a safe_join' do
    source = 'safe_join([i18n_text.html_safe,
              i18n_mode_additional_markup(key).html_safe])'
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept html_safe methods wrapped in safe_join not at root' do
    source = 'foo(safe_join([i18n_text.html_safe,
              i18n_mode_additional_markup(key).html_safe]))'
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept raw methods wrapped in a safe_join not at root' do
    source = 'foo(safe_join([raw(i18n_text),
              raw(i18n_mode_additional_markup(key))]))'
    inspect_source(source)
    expect(cop.offenses.size).to eq(2)
  end
end
