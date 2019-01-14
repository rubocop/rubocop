# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Rails::IgnoredSkipActionFilterOption do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when `if` and `only` are used together' do
    expect_offense(<<-RUBY.strip_indent)
      skip_before_action :login_required, only: :show, if: :trusted_origin?
                                                       ^^^^^^^^^^^^^^^^^^^^ `if` option will be ignored when `only` and `if` are used together.
    RUBY
  end

  it 'registers an offense when `if` and `except` are used together' do
    expect_offense(<<-RUBY.strip_indent)
      skip_before_action :login_required, except: :admin, if: :trusted_origin?
                                          ^^^^^^^^^^^^^^ `except` option will be ignored when `if` and `except` are used together.
    RUBY
  end

  it 'does not register an offense when `if` is used only' do
    expect_no_offenses(<<-RUBY.strip_indent)
      skip_before_action :login_required, if: -> { trusted_origin? && action_name == "show" }
    RUBY
  end
end
