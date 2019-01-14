# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BelongsTo do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when specifying `required: false`' do
    expect_offense(<<-RUBY.strip_indent)
      belongs_to :foo, required: false
      ^^^^^^^^^^ You specified `required: false`, in Rails > 5.0 the requires option is deprecated and you want to use `optional: true`.
    RUBY
  end

  it 'registers an offense when specifying `required: true`' do
    expect_offense(<<-RUBY.strip_indent)
      belongs_to :foo, required: true
      ^^^^^^^^^^ The use of `required` on belongs_to associations was deprecated in Rails 5. Please use the `optional` flag instead
    RUBY
  end

  it 'auto-corrects `required: false` to `optional: true`' do
    expect(autocorrect_source('belongs_to :foo, required: false'))
      .to eq('belongs_to :foo, optional: true')
    expect(cop.offenses.last.status).to eq(:corrected)
  end

  it 'does not auto-correct `required: true`' do
    code = 'belongs_to :foo, required: true'
    expect(autocorrect_source(code)).to eq(code)
    expect(cop.offenses.last.status).to eq(:uncorrected)
  end

  it 'registers no offense when setting `optional: true`' do
    expect_no_offenses('belongs_to :foo, optional: true')
  end

  it 'registers no offense when requires: false is not set' do
    expect_no_offenses('belongs_to :foo')
    expect_no_offenses('belongs_to :foo, polymorphic: true')
  end
end
