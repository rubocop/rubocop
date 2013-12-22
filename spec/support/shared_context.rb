# encoding: utf-8

# `cop_config` must be declared with #let.
shared_context 'config', :config do
  let(:config) do
    # Module#<
    unless described_class < Rubocop::Cop::Cop
      fail '`config` must be used in `describe SomeCopClass do .. end`'
    end

    unless cop_config.is_a?(Hash)
      fail '`cop_config` must be declared with #let'
    end

    cop_name = described_class.cop_name
    hash = {
      cop_name =>
      Rubocop::ConfigLoader.default_configuration[cop_name].merge(cop_config)
    }
    Rubocop::Config.new(hash)
  end
end
