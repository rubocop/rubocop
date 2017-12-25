# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::HasAndBelongsToMany do
  subject(:cop) { described_class.new }

  it 'registers an offense for has_and_belongs_to_many' do
    expect_offense(<<-RUBY.strip_indent)
      has_and_belongs_to_many :groups
      ^^^^^^^^^^^^^^^^^^^^^^^ Prefer `has_many :through` to `has_and_belongs_to_many`.
    RUBY
  end
end
