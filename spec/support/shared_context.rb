# encoding: utf-8

# `cop_config` must be declared with #let.
shared_context 'config', :config do
  let(:config) do
    # Module#<
    unless described_class < RuboCop::Cop::Cop
      fail '`config` must be used in `describe SomeCopClass do .. end`'
    end

    fail '`cop_config` must be declared with #let' unless cop_config.is_a?(Hash)

    cop_name = described_class.cop_name
    hash = {
      cop_name =>
      RuboCop::ConfigLoader.default_configuration[cop_name].merge(cop_config)
    }
    RuboCop::Config.new(hash, "#{Dir.pwd}/.rubocop.yml")
  end
end
