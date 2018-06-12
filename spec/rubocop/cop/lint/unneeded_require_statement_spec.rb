# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Lint::UnneededRequireStatement, :config do
  subject(:cop) { described_class.new(config) }

  it "registers an offense when using `require 'enumerator'`" do
    expect_offense(<<-RUBY.strip_indent)
      require 'enumerator'
      ^^^^^^^^^^^^^^^^^^^^ Remove unnecessary `require` statement.
    RUBY
  end

  it 'autocorrects remove unnecessary require statement' do
    new_source = autocorrect_source(<<-RUBY.strip_indent)
      require 'enumerator'
      require 'uri'
    RUBY

    expect(new_source).to eq(<<-RUBY.strip_indent)
      require 'uri'
    RUBY
  end
end
