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

    hash = { described_class.cop_name => cop_config }
    Rubocop::Config.new(hash)
  end
end
