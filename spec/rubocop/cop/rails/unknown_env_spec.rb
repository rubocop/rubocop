# frozen_string_literal: true

describe RuboCop::Cop::Rails::UnknownEnv, :config do
  let(:cop_config) do
    {
      'Environments' => %w[
        development
        production
        test
      ]
    }
  end
  subject(:cop) { described_class.new(config) }

  it 'registers an offense for typo of environment name' do
    expect_offense(<<-RUBY)
      Rails.env.proudction?
                ^^^^^^^^^^^ Unknown environment `proudction?`. Did you mean `production?`?
      Rails.env.developpment?
                ^^^^^^^^^^^^^ Unknown environment `developpment?`. Did you mean `development?`?
      Rails.env.something?
                ^^^^^^^^^^ Unknown environment `something?`.
    RUBY
  end

  it 'accepts correct environment name' do
    expect_no_offenses(<<-RUBY)
      Rails.env.production?
    RUBY
  end
end
