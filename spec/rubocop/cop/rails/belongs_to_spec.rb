# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::BelongsTo do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense and corrects when specifying `required: false`' do
    expect_offense(<<-RUBY.strip_indent)
      belongs_to :foo, required: false
      ^^^^^^^^^^ You specified `required: false`, in Rails > 5.0 the required option is deprecated and you want to use `optional: true`.
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      belongs_to :foo, optional: true
    RUBY
  end

  it 'registers an offense and corrects when specifying `required: true`' do
    expect_offense(<<-RUBY.strip_indent)
      belongs_to :foo, required: true
      ^^^^^^^^^^ You specified `required: true`, in Rails > 5.0 the required option is deprecated and you want to use `optional: false`. In most configurations, this is the default and you can omit this option altogether
    RUBY

    expect_correction(<<-RUBY.strip_indent)
      belongs_to :foo, optional: false
    RUBY
  end

  it 'registers no offense when setting `optional: true`' do
    expect_no_offenses('belongs_to :foo, optional: true')
  end

  it 'registers no offense when requires: false is not set' do
    expect_no_offenses('belongs_to :foo')
    expect_no_offenses('belongs_to :foo, polymorphic: true')
  end
end
