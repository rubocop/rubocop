# frozen_string_literal: true

describe RuboCop::Cop::Rails::EnvironmentComparison do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using `Rails.env == production`' do
    expect_offense(<<-RUBY.strip_indent)
      Rails.env == 'production'
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Favor `Rails.env.production?` over `Rails.env == 'production'`.
      Rails.env == :development
      ^^^^^^^^^^^^^^^^^^^^^^^^^ Do not compare `Rails.env` with a symbol, it will always evaluate to `false`.
    RUBY
  end

  it 'autocorrects a string' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      Rails.env == 'development'
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      Rails.env.development?
    RUBY
  end

  it 'autocorrects a symbol' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      Rails.env == :test
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      Rails.env.test?
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      Rails.env.production?
      Rails.env.test?
    RUBY
  end
end
