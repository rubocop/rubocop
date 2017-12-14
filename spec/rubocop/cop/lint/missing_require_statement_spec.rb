# frozen_string_literal: true

describe RuboCop::Cop::Lint::MissingRequireStatement do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  # TODO: Write test code
  #
  # For example
  it 'registers an offense when using `#bad_method`' do
    expect_offense(<<-RUBY.strip_indent)
      bad_method
      ^^^^^^^^^^ Use `#good_method` instead of `#bad_method`.
    RUBY
  end

  it 'does not register an offense when using `#good_method`' do
    expect_no_offenses(<<-RUBY.strip_indent)
      good_method
    RUBY
  end
end
