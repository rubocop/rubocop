# frozen_string_literal: true

describe RuboCop::Cop::Rails::OutputSafety do
  subject(:cop) { described_class.new }

  it 'registers an offense for html_safe methods with a receiver and no ' \
     'arguments' do
    source = <<-END.strip_indent
      foo.html_safe
      "foo".html_safe
    END
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts html_safe methods without a receiver' do
    source = 'html_safe'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts html_safe methods with arguments' do
    source = <<-END.strip_indent
      foo.html_safe one
      "foo".html_safe two
    END
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'registers an offense for raw methods without a receiver' do
    source = <<-END.strip_indent
      raw(foo)
      raw "foo"
    END
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'accepts raw methods with a receiver' do
    source = <<-END.strip_indent
      foo.raw(foo)
      "foo".raw "foo"
    END
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts raw methods without arguments' do
    source = 'raw'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts raw methods with more than one arguments' do
    source = 'raw one, two'
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'accepts comments' do
    source = <<-END.strip_indent
      # foo.html_safe
      # raw foo
    END
    inspect_source(cop, source)
    expect(cop.offenses).to be_empty
  end

  it 'does not accept raw methods when wrapped in a safe_join' do
    source = 'safe_join([raw(i18n_text),
              raw(i18n_mode_additional_markup(key))])'
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept html_safe methods when wrapped in a safe_join' do
    source = 'safe_join([i18n_text.html_safe,
              i18n_mode_additional_markup(key).html_safe])'
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept html_safe methods wrapped in safe_join not at root' do
    source = 'foo(safe_join([i18n_text.html_safe,
              i18n_mode_additional_markup(key).html_safe]))'
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end

  it 'does not accept raw methods wrapped in a safe_join not at root' do
    source = 'foo(safe_join([raw(i18n_text),
              raw(i18n_mode_additional_markup(key))]))'
    inspect_source(cop, source)
    expect(cop.offenses.size).to eq(2)
  end
end
