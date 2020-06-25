# frozen_string_literal: true

RSpec.shared_context 'unbundle', :unbundle do
  let(:ruby) do
    "BUNDLE_GEMFILE=#{RuboCop::ConfigLoader::RUBOCOP_HOME}/Gemfile " \
      'bundle exec ruby'
  end

  around do |example|
    if Bundler.respond_to?(:with_unbundled_env)
      Bundler.with_unbundled_env(&example)
    else
      Bundler.with_clean_env(&example)
    end
  end
end
