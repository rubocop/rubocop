# frozen_string_literal: true

describe RuboCop::Cop::Lint::EnableStatement do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when a cop is disabled and never re-enabled' do
    expect_offense(<<-RUBY.strip_indent)
      # rubocop:disable Layout/SpaceAroundOperators
      ^ Re-enable Layout/SpaceAroundOperators cop with `# rubocop:enable` after disabling it.
      x =   0
      # Some other code
    RUBY
  end

  it 'does not register an offense when the disable cop is re-enabled' do
    expect_no_offenses(<<-RUBY.strip_indent)
      # rubocop:disable Layout/SpaceAroundOperators
      x =   0
      # rubocop:enable Layout/SpaceAroundOperators
      # Some other code
    RUBY
  end
end
