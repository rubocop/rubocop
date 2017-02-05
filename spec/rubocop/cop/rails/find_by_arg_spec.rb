# frozen_string_literal: true

require 'spec_helper'

describe RuboCop::Cop::Rails::FindByArg do
  subject(:cop) { described_class.new }

  shared_examples 'register_offense' do |args|
    it "registers find_by(#{args})" do
      inspect_source(cop, "User.find_by(#{args})")
      expect(cop.offenses.size).to eq(1)
    end

    it "registers find_by!(#{args})" do
      inspect_source(cop, "User.find_by!(#{args})")
      expect(cop.offenses.size).to eq(1)
    end
  end

  it_behaves_like('register_offense', 'id')
  it_behaves_like('register_offense', 'id, name: "Philip"')

  context 'with bang' do
    it 'does not register an offense with hash' do
      inspect_source(cop, 'User.find_by(id: 1)')

      expect(cop.messages).to be_empty
    end
  end

  context 'without bang' do
    it 'does not register an offense with hash' do
      inspect_source(cop, 'User.find_by!(id: 1)')

      expect(cop.messages).to be_empty
    end
  end
end
