# frozen_string_literal: true

RSpec.shared_context 'cli spec behavior' do
  # Wrap all cli specs in `aggregate_failures` so that the expected and
  # actual results of every expectation per example are shown. This is
  # helpful because it shows information like expected and actual
  # $stdout messages while not using `aggregate_failures` will only
  # show information about expected and actual exit code
  around do |example|
    aggregate_failures(&example)
  end
end
