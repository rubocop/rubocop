# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::FilePath do
  subject(:cop) { described_class.new }

  context 'when using Rails.root.join with some path strings' do
    let(:source) { "Rails.root.join('app', 'models', 'user.rb')" }

    it 'does not registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses).to be_empty
    end
  end

  context 'when using File.join with Rails.root' do
    let(:source) { "File.join(Rails.root, 'app', 'models')" }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when using Rails.root.join with slash separated path string' do
    let(:source) { "Rails.root.join('app/models/goober')" }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end

  context 'when using Rails.root called by double quoted string' do
    let(:source) { '"#{Rails.root}/app/models/goober"' }

    it 'registers an offense' do
      inspect_source(cop, source)
      expect(cop.offenses.size).to eq(1)
    end
  end
end
