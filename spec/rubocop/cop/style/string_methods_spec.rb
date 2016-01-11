# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RuboCop::Cop::Style::StringMethods, :config do
  cop_config = {
    'PreferredMethods' => {
      'intern' => 'to_sym'
    }
  }

  subject(:cop) { described_class.new(config) }
  let(:cop_config) { cop_config }

  cop_config['PreferredMethods'].each do |method, preferred_method|
    it "registers an offense for #{method}" do
      inspect_source(cop, "'something'.#{method}")
      expect(cop.offenses.size).to eq(1)
      expect(cop.messages)
        .to eq(["Prefer `#{preferred_method}` over `#{method}`."])
      expect(cop.highlights).to eq(%w(intern))
    end
  end
end
